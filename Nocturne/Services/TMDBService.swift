import Foundation

class TMDBService {
    static let shared = TMDBService()
    
    private let apiKey = "8639a3faae3096f27a6ddf3f44d2529"
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    private let backdropBaseURL = "https://image.tmdb.org/t/p/original"
    
    private func makeRequest(endpoint: String, queryItems: [URLQueryItem] = []) async throws -> Data {
        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanKey.isEmpty else { throw URLError(.userAuthenticationRequired) }
        
        var components = URLComponents(string: baseURL + endpoint)!
        var items = [URLQueryItem(name: "language", value: "it-IT")] + queryItems
        
        let isBearerToken = cleanKey.hasPrefix("eyJ")
        if !isBearerToken {
            items.append(URLQueryItem(name: "api_key", value: cleanKey))
        }
        components.queryItems = items
        
        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        if isBearerToken {
            request.setValue("Bearer \(cleanKey)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("Errore TMDB (HTTP \(httpResponse.statusCode)): \(body)")
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    private func performMovieRequest(endpoint: String, queryItems: [URLQueryItem] = []) async throws -> [Movie] {
        let data = try await makeRequest(endpoint: endpoint, queryItems: queryItems)
        let decoded = try JSONDecoder().decode(TMDBResponse.self, from: data)
        return decoded.results.map { $0.toMovie(imageHost: imageBaseURL, backdropHost: backdropBaseURL) }
    }
    
    // Scarica tutti i generi ufficiali di TMDB
    func fetchOfficialGenres() async throws -> [TMDBGenre] {
        let data = try await makeRequest(endpoint: "/genre/movie/list")
        let decoded = try JSONDecoder().decode(TMDBGenreResponse.self, from: data)
        return decoded.genres
    }
    
    // Scarica i film filtrati per un genere specifico
    func fetchMoviesByGenre(genreId: Int) async throws -> [Movie] {
        try await performMovieRequest(
            endpoint: "/discover/movie",
            queryItems: [
                URLQueryItem(name: "with_genres", value: String(genreId)),
                URLQueryItem(name: "sort_by", value: "popularity.desc")
            ]
        )
    }
    
    // Cerca per categoria (Tutti, Film, Registi, Attori)
    func searchByCategory(query: String, category: String) async throws -> [Movie] {
        if category == "Registi" || category == "Attori" {
            let data = try await makeRequest(
                endpoint: "/search/person",
                queryItems: [URLQueryItem(name: "query", value: query)]
            )
            let personResponse = try JSONDecoder().decode(TMDBPersonSearchResponse.self, from: data)
            guard let firstPerson = personResponse.results.first else { return [] }
            
            // Scarica la filmografia completa di quel regista o attore su TMDB
            let filterKey = (category == "Registi") ? "with_crew" : "with_cast"
            let discovered = try await performMovieRequest(
                endpoint: "/discover/movie",
                queryItems: [
                    URLQueryItem(name: filterKey, value: String(firstPerson.id)),
                    URLQueryItem(name: "sort_by", value: "vote_count.desc")
                ]
            )
            if !discovered.isEmpty { return discovered }
            
            return (firstPerson.knownFor ?? []).map {
                $0.toMovie(imageHost: imageBaseURL, backdropHost: backdropBaseURL, customDirector: firstPerson.name)
            }
        } else {
            return try await searchMovies(query: query)
        }
    }
    
    // Scarica i film consigliati da TMDB basandosi su un film visto/salvato dall'utente
    func fetchRecommendations(basedOnTitle title: String) async throws -> [Movie] {
        let searchMatches = try await searchMovies(query: title)
        guard let firstMatch = searchMatches.first, firstMatch.tmdbId > 0 else { return [] }
        
        let recs = try await performMovieRequest(endpoint: "/movie/\(firstMatch.tmdbId)/recommendations")
        if !recs.isEmpty { return recs }
        return try await performMovieRequest(endpoint: "/movie/\(firstMatch.tmdbId)/similar")
    }
    
    func searchMovies(query: String) async throws -> [Movie] {
        try await performMovieRequest(endpoint: "/search/movie", queryItems: [URLQueryItem(name: "query", value: query)])
    }
    
    func fetchTrendingMovies() async throws -> [Movie] {
        try await performMovieRequest(endpoint: "/trending/movie/day")
    }
    
    func fetchTopRatedMovies() async throws -> [Movie] {
        try await performMovieRequest(endpoint: "/movie/top_rated", queryItems: [URLQueryItem(name: "page", value: "1")])
    }
}

// Modelli JSON TMDB
struct TMDBGenreResponse: Codable {
    let genres: [TMDBGenre]
}

struct TMDBResponse: Codable {
    let results: [TMDBMovie]
}

struct TMDBPersonSearchResponse: Codable {
    let results: [TMDBPerson]
}

struct TMDBPerson: Codable {
    let id: Int
    let name: String
    let knownFor: [TMDBMovie]?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case knownFor = "known_for"
    }
}

struct TMDBMovie: Codable {
    let id: Int
    let title: String?
    let name: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, name, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
    
    func toMovie(imageHost: String, backdropHost: String, customDirector: String? = nil) -> Movie {
        let posterUrl = posterPath != nil ? imageHost + posterPath! : ""
        let backdropUrl = backdropPath != nil ? backdropHost + backdropPath! : posterUrl
        let yearString = releaseDate?.prefix(4).description ?? "2024"
        let displayTitle = title ?? name ?? "Titolo Sconosciuto"
        
        return Movie(
            tmdbId: id,
            title: displayTitle,
            year: yearString,
            director: customDirector ?? "TMDB Official",
            runtime: 135,
            rating: voteAverage ?? 0.0,
            posterName: posterUrl,
            backdropName: backdropUrl,
            synopsis: (overview?.isEmpty == false) ? overview! : "Nessuna sinossi disponibile in italiano su TMDB."
        )
    }
}
