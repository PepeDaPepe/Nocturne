import Foundation

struct TMDBGenre: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
}

struct Movie: Identifiable, Hashable {
    let id = UUID()
    var tmdbId: Int = 0
    let title: String
    let year: String
    let director: String
    let runtime: Int
    let rating: Double
    let posterName: String
    let backdropName: String
    let synopsis: String
    var isWatchlisted: Bool = false
}

extension Movie {
    static let featuredDune = Movie(
        tmdbId: 693134,
        title: "Dune: Parte Due",
        year: "2024",
        director: "Denis Villeneuve",
        runtime: 166,
        rating: 8.8,
        posterName: "dune_backdrop",
        backdropName: "dune_backdrop",
        synopsis: "Paul Atreides si unisce a Chani e ai Fremen mentre trama la vendetta contro i cospiratori che hanno distrutto la sua famiglia."
    )
    
    static let sampleTopRated: [Movie] = []
    static let sampleTop250Preview: [Movie] = []
}
