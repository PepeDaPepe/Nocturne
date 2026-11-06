import Foundation
import SwiftData

@Model
final class SavedMovieEntry {
    @Attribute(.unique) var title: String
    var year: String
    var director: String
    var runtime: Int
    var tmdbRating: Double
    var posterName: String
    var backdropName: String
    var synopsis: String
    
    // Stati utente (Watchlist e Diario)
    var isInWatchlist: Bool
    var isWatched: Bool
    var userRating: Double
    var isLiked: Bool
    var isRewatch: Bool
    var reviewText: String
    var hasSpoilers: Bool
    var watchTag: String // es. "IMAX", "Sala", "Riveduto"
    var addedDate: Date
    var watchedDate: Date?
    
    init(
        movie: Movie,
        isInWatchlist: Bool = true,
        isWatched: Bool = false,
        userRating: Double = 0.0,
        isLiked: Bool = false,
        isRewatch: Bool = false,
        reviewText: String = "",
        hasSpoilers: Bool = false,
        watchTag: String = "IMAX",
        addedDate: Date = Date(),
        watchedDate: Date? = nil
    ) {
        self.title = movie.title
        self.year = movie.year
        self.director = movie.director
        self.runtime = movie.runtime
        self.tmdbRating = movie.rating
        self.posterName = movie.posterName
        self.backdropName = movie.backdropName
        self.synopsis = movie.synopsis
        self.isInWatchlist = isInWatchlist
        self.isWatched = isWatched
        self.userRating = userRating
        self.isLiked = isLiked
        self.isRewatch = isRewatch
        self.reviewText = reviewText
        self.hasSpoilers = hasSpoilers
        self.watchTag = watchTag
        self.addedDate = addedDate
        self.watchedDate = watchedDate
    }
    
    // Riconverte il record del database in un oggetto Movie per aprire MovieDetailView
    func toMovie() -> Movie {
        Movie(
            title: title,
            year: year,
            director: director,
            runtime: runtime,
            rating: tmdbRating,
            posterName: posterName,
            backdropName: backdropName,
            synopsis: synopsis,
            isWatchlisted: isInWatchlist
        )
    }
}
