import Foundation

class TMDBService {
    static let shared = TMDBService()
    
    private let apiKey = "93d946ef8af5b6f7f9d224b771de538d"
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    private let backdropBaseURL = "https://image.tmdb.org/t/p/original"
    
    private func performRequest(endpoint: String, queryItems: [URLQueryItem] = []) async throws -> [Movie] {
        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanKey.isEmpty else {
            print("TMDBService: Chiave API vuota!")
            return []
        }
        
        var components = URLComponents(string: baseURL + endpoint)!
        var items = [URLQueryItem(name: "language", value: "it-IT")] + queryItems
        
        let isBearerToken = cleanKey.hasPrefix("eyJ")
        if !isBearerToken {
            items.append(URLQueryItem(name: "api_key", value: cleanKey))
        }
        components.queryItems = items
        
        guard let url = components.url else { return [] }
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
            return []
        }
        
        let decoded = try JSONDecoder().decode(TMDBResponse.self, from: data)
        print("TMDB ha scaricato \(decoded.results.count) film da \(endpoint)")
        return decoded.results.map { $0.toMovie(imageHost: imageBaseURL, backdropHost: backdropBaseURL) }
    }
    
    func searchMovies(query: String) async throws -> [Movie] {
        try await performRequest(endpoint: "/search/movie", queryItems: [URLQueryItem(name: "query", value: query)])
    }
    
    func fetchTrendingMovies() async throws -> [Movie] {
        try await performRequest(endpoint: "/trending/movie/day")
    }
    
    func fetchTopRatedMovies() async throws -> [Movie] {
        try await performRequest(endpoint: "/movie/top_rated", queryItems: [URLQueryItem(name: "page", value: "1")])
    }
}

struct TMDBResponse: Codable {
    let results: [TMDBMovie]
}

struct TMDBMovie: Codable {
    let id: Int
    let title: String?
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
    
    func toMovie(imageHost: String, backdropHost: String) -> Movie {
        let posterUrl = posterPath != nil ? imageHost + posterPath! : ""
        let backdropUrl = backdropPath != nil ? backdropHost + backdropPath! : posterUrl
        let yearString = releaseDate?.prefix(4).description ?? "2024"
        
        return Movie(
            title: title ?? "Titolo Sconosciuto",
            year: yearString,
            director: "TMDB Official",
            runtime: 135,
            rating: voteAverage ?? 0.0,
            posterName: posterUrl,
            backdropName: backdropUrl,
            synopsis: (overview?.isEmpty == false) ? overview! : "Nessuna sinossi disponibile in italiano su TMDB."
        )
    }
}
