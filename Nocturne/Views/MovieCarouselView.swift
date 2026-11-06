import SwiftUI
import SwiftData

struct MovieCarouselView: View {
    let title: String
    let subtitle: String
    let movies: [Movie]
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
            
            // Intestazione della sezione con "Vedi tutti >" dinamico
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Spacer()
                
                NavigationLink(
                    destination: ExpandedMovieListView(
                        title: title,
                        subtitle: subtitle,
                        badgeTitle: title,
                        movies: movies,
                        showRank: true
                    )
                ) {
                    HStack(spacing: 4) {
                        Text("Vedi tutti")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.theme.primaryCyan)
                }
            }
            .padding(.horizontal, LayoutInfo.gutterMobile)
            
            // Lista orizzontale delle locandine cliccabili
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: LayoutInfo.spaceMD) {
                    ForEach(movies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            MoviePosterCard(movie: movie)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, LayoutInfo.gutterMobile)
            }
        }
    }
}

struct MoviePosterCard: View {
    let movie: Movie
    @Environment(\.modelContext) private var modelContext
    @Query private var savedEntries: [SavedMovieEntry]
    
    private var existingEntry: SavedMovieEntry? {
        savedEntries.first(where: { $0.title == movie.title })
    }
    
    private var isSaved: Bool {
        existingEntry?.isInWatchlist == true
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceSM) {
            
            ZStack {
                MovieImageView(source: movie.posterName)
                    .posterStyle()
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            toggleWatchlist()
                        }) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(isSaved ? Color.theme.primaryCyan : Color.theme.textPrimary)
                                .frame(width: 26, height: 26)
                                .background(Color.theme.background.opacity(0.85))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                                )
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundColor(Color.theme.primaryCyan)
                            
                            Text(String(format: "%.1f", movie.rating))
                                .font(.system(size: 11, weight: .bold))
                                .monospacedDigit()
                                .foregroundColor(Color.theme.textPrimary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.theme.background.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                        
                        Spacer()
                    }
                }
                .padding(8)
            }
            .frame(width: 135, height: 202.5)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(movie.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(1)
                
                Text("\(movie.year) • \(movie.director)")
                    .font(.system(size: 12, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(Color.theme.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: 135, alignment: .leading)
        }
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
#Preview {
    NavigationStack {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            MovieCarouselView(
                title: "I Più Votati",
                subtitle: "Classifica generale cinefili",
                movies: Movie.sampleTopRated
            )
        }
    }
    .preferredColorScheme(.dark)
}
