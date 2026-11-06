import SwiftUI

@MainActor
class MovieCatalogViewModel: ObservableObject {
    @Published var featuredMovie: Movie? = nil
    @Published var trendingMovies: [Movie] = []
    @Published var topRatedMovies: [Movie] = []
    @Published var searchResults: [Movie] = []
    @Published var isLoading: Bool = false
    
    func loadHomeCatalog() async {
        guard trendingMovies.isEmpty else { return }
        isLoading = true
        do {
            async let trendingTask = TMDBService.shared.fetchTrendingMovies()
            async let topRatedTask = TMDBService.shared.fetchTopRatedMovies()
            
            let (trending, topRated) = try await (trendingTask, topRatedTask)
            
            self.trendingMovies = trending
            self.topRatedMovies = topRated
            self.featuredMovie = trending.first
        } catch {
            print("Errore caricamento catalogo TMDB: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func performSearch(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = trendingMovies
            return
        }
        
        do {
            self.searchResults = try await TMDBService.shared.searchMovies(query: trimmed)
        } catch {
            print("Errore ricerca TMDB: \(error.localizedDescription)")
        }
    }
}
