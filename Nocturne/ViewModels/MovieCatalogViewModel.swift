import SwiftUI

@MainActor
class MovieCatalogViewModel: ObservableObject {
    @Published var featuredMovie: Movie? = nil
    @Published var trendingMovies: [Movie] = []
    @Published var topRatedMovies: [Movie] = []
    
    // Gestione Generi TMDB
    @Published var genres: [TMDBGenre] = []
    @Published var selectedGenre: TMDBGenre? = nil // nil = "Tutti"
    @Published var genreMovies: [Movie] = []
    @Published var isLoadingGenre: Bool = false
    
    // Gestione Ricerca
    @Published var searchResults: [Movie] = []
    @Published var isLoading: Bool = false
    
    func loadHomeCatalog() async {
        guard trendingMovies.isEmpty else { return }
        isLoading = true
        do {
            async let trendingTask = TMDBService.shared.fetchTrendingMovies()
            async let topRatedTask = TMDBService.shared.fetchTopRatedMovies()
            async let genresTask = TMDBService.shared.fetchOfficialGenres()
            
            let (trending, topRated, fetchedGenres) = try await (trendingTask, topRatedTask, genresTask)
            
            self.trendingMovies = trending
            self.topRatedMovies = topRated
            self.genres = fetchedGenres
            self.featuredMovie = trending.first
        } catch {
            print("Errore caricamento catalogo TMDB: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func selectGenre(_ genre: TMDBGenre?) async {
        selectedGenre = genre
        guard let genre = genre else {
            genreMovies = []
            return
        }
        isLoadingGenre = true
        do {
            genreMovies = try await TMDBService.shared.fetchMoviesByGenre(genreId: genre.id)
        } catch {
            print("Errore filtro genere: \(error.localizedDescription)")
        }
        isLoadingGenre = false
    }
    
    func performSearch(query: String, category: String = "Tutti") async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            if genres.isEmpty {
                genres = (try? await TMDBService.shared.fetchOfficialGenres()) ?? []
            }
            if trendingMovies.isEmpty {
                trendingMovies = (try? await TMDBService.shared.fetchTrendingMovies()) ?? []
            }
            searchResults = trendingMovies
            return
        }
        
        do {
            if genres.isEmpty {
                genres = (try? await TMDBService.shared.fetchOfficialGenres()) ?? []
            }
            self.searchResults = try await TMDBService.shared.searchByCategory(query: trimmed, category: category)
        } catch {
            print("Errore ricerca TMDB: \(error.localizedDescription)")
        }
    }
}
