import SwiftUI
import SwiftData

struct FeaturedMovieView: View {
    let movie: Movie
    @Environment(\.modelContext) private var modelContext
    @Query private var savedEntries: [SavedMovieEntry]
    
    private var existingEntry: SavedMovieEntry? {
        savedEntries.first(where: { $0.title == movie.title })
    }
    
    private var isInWatchlist: Bool {
        existingEntry?.isInWatchlist == true
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.theme.surfaceElevated
                .overlay(
                    MovieImageView(source: movie.backdropName)
                )
                .overlay(
                    LinearGradient(
                        stops: [
                            .init(color: Color.theme.background.opacity(0.35), location: 0.0),
                            .init(color: Color.theme.background.opacity(0.1), location: 0.4),
                            .init(color: Color.theme.background.opacity(0.95), location: 0.85),
                            .init(color: Color.theme.background, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipped()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("IN EVIDENZA OGGI")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.theme.background.opacity(0.85))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                    
                    Spacer()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: LayoutInfo.spaceSM) {
                    HStack(spacing: LayoutInfo.spaceSM) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.theme.primaryCyan)
                                .font(.system(size: 11))
                            Text(String(format: "%.1f", movie.rating))
                                .font(.system(size: 13, weight: .bold))
                                .monospacedDigit()
                                .foregroundColor(Color.theme.primaryCyan)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.theme.primaryCyan.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        
                        Text(movie.year)
                            .font(.system(size: 13, weight: .medium))
                            .monospacedDigit()
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Text("TMDB LIVE")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.theme.primaryCyan)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.theme.surfaceElevated.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .stroke(Color.theme.borderActive, lineWidth: 0.5)
                            )
                    }
                    
                    Text(movie.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.theme.textPrimary)
                        .lineLimit(1)
                    
                    Text(movie.synopsis)
                        .font(.system(size: 14))
                        .foregroundColor(Color.theme.textSecondary)
                        .lineLimit(2)
                        .padding(.bottom, 4)
                    
                    HStack(spacing: LayoutInfo.spaceMD) {
                        Button(action: {
                            toggleWatchlist()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: isInWatchlist ? "checkmark.circle.fill" : "bookmark.fill")
                                Text(isInWatchlist ? "Nella tua Watchlist" : "Aggiungi a Watchlist")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.theme.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.theme.primaryCyan)
                            .clipShape(RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusButton, style: .continuous))
                        }
                    }
                }
            }
            .padding(LayoutInfo.spaceLG)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
        )
        .padding(.horizontal, LayoutInfo.gutterMobile)
    }
    
    private func toggleWatchlist() {
        if let entry = existingEntry {
            entry.isInWatchlist.toggle()
        } else {
            let newEntry = SavedMovieEntry(movie: movie, isInWatchlist: true, isWatched: false)
            modelContext.insert(newEntry)
        }
        try? modelContext.save()
    }
}
