import SwiftUI
import SwiftData

struct RecommendedSectionView: View {
    let movies: [Movie]
    
    private let tags = [
        "Sci-Fi d'Autore",
        "Cult Consigliato",
        "Visione Imperdibile",
        "Fotografia & Regia",
        "Selezione Cinefili"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
            
            // Intestazione
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Consigliati per Te")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text("Basato sui tuoi film registrati")
                        .font(.system(size: 13))
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Personalizza")
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.theme.primaryCyan)
                }
            }
            .padding(.horizontal, LayoutInfo.gutterMobile)
            
            // Carosello orizzontale dinamico
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LayoutInfo.spaceMD) {
                    ForEach(Array(movies.enumerated()), id: \.element.id) { index, movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            RecommendedCard(
                                movie: movie,
                                tag: tags[index % tags.count],
                                matchPercentage: max(85, 98 - (index * 2))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, LayoutInfo.gutterMobile)
            }
        }
    }
}

struct RecommendedCard: View {
    let movie: Movie
    let tag: String
    let matchPercentage: Int
    
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
            
            // Locandina da TMDB con badge "% MATCH" e pulsante Watchlist
            ZStack {
                MovieImageView(source: movie.posterName)
                    .posterStyle()
                
                VStack {
                    HStack {
                        Text("\(matchPercentage)% MATCH")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.5)
                            .monospacedDigit()
                            .foregroundColor(Color.theme.primaryCyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.theme.background.opacity(0.85))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.theme.borderActive, lineWidth: 0.5)
                            )
                        
                        Spacer()
                        
                        Button(action: {
                            if let entry = existingEntry {
                                entry.isInWatchlist.toggle()
                            } else {
                                let newEntry = SavedMovieEntry(movie: movie, isInWatchlist: true, isWatched: false)
                                modelContext.insert(newEntry)
                            }
                            try? modelContext.save()
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
                }
                .padding(8)
            }
            .frame(width: 156, height: 234)
            
            // Testi e metriche sotto la locandina
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(1)
                
                Text(tag)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.theme.primaryCyan)
                    .lineLimit(1)
                
                HStack {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.theme.primaryCyan)
                        Text(String(format: "%.1f", movie.rating))
                            .font(.system(size: 12, weight: .semibold))
                            .monospacedDigit()
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("\(movie.runtime) min")
                        .font(.system(size: 12, weight: .regular))
                        .monospacedDigit()
                        .foregroundColor(Color.theme.textSecondary)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .padding(8)
        .frame(width: 172)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
        )
    }
}
