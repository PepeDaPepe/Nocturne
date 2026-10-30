import Foundation

struct Movie: Identifiable, Hashable {
    let id = UUID()
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
