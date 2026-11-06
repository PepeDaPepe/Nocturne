import SwiftUI
import SwiftData

struct RecommendedSectionView: View {
    @Query(sort: \SavedMovieEntry.addedDate, order: .reverse) private var savedEntries: [SavedMovieEntry]
    
    @State private var recommendedMovies: [Movie] = []
    @State private var isLoading: Bool = false
    
    // Sceglie il film "seme" su cui basare i consigli (priorità ai film votati >= 3.5, altrimenti l'ultimo in Watchlist)
    private var seedEntry: SavedMovieEntry? {
        if let bestWatched = savedEntries.filter({ $0.isWatched && $0.userRating >= 3.5 }).sorted(by: { $0.userRating > $1.userRating }).first {
            return bestWatched
        }
        return savedEntries.first
    }
    
    private let tags = [
        "Affine ai tuoi gusti",
        "Consigliato da TMDB",
        "Stile & Atmosfera",
        "Scelta Cinefila",
        "Regia Correlata"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
            
            // Intestazione dinamica
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Consigliati per Te")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    if let seed = seedEntry {
                        Text("Perché ti interessa \(seed.title) • \(savedEntries.count) film nel tuo archivio")
                            .font(.system(size: 13))
                            .foregroundColor(Color.theme.primaryCyan)
                            .lineLimit(1)
                    } else {
                        Text("In attesa dei tuoi primi film salvati o recensiti")
                            .font(.system(size: 13))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, LayoutInfo.gutterMobile)
            
            // Stato 1: L'utente non ha ancora nessun film in Watchlist o Diario
            if savedEntries.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 22))
                            .foregroundColor(Color.theme.primaryCyan)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sblocca i tuoi Consigli Personalizzati")
                                .font(.system(size: 15, weight: .bold, design: .serif))
                                .foregroundColor(Color.theme.textPrimary)
                            
                            Text("Non hai ancora registrato nessun film. Aggiungi un titolo alla Watchlist o vota un film con + Log: useremo quel film per trovare titoli affini su TMDB.")
                                .font(.system(size: 13))
                                .foregroundColor(Color.theme.textSecondary)
                                .lineSpacing(2)
                        }
                    }
                }
                .padding(LayoutInfo.spaceLG)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.theme.borderActive, lineWidth: 0.5)
                )
                .padding(.horizontal, LayoutInfo.gutterMobile)
            } else if isLoading {
                HStack {
                    Spacer()
                    ProgressView("Analisi dei tuoi gusti su TMDB...")
                        .tint(Color.theme.primaryCyan)
                        .font(.system(size: 13))
                    Spacer()
                }
                .padding(.vertical, 30)
            } else {
                // Stato 2: Carosello reale basato sui film dell'utente
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: LayoutInfo.spaceMD) {
                        ForEach(Array(recommendedMovies.enumerated()), id: \.element.id) { index, movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                RecommendedCard(
                                    movie: movie,
                                    tag: tags[index % tags.count],
                                    matchPercentage: max(84, 98 - (index * 2))
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, LayoutInfo.gutterMobile)
                }
            }
        }
        .task(id: seedEntry?.title) {
            guard let seed = seedEntry else {
                recommendedMovies = []
                return
            }
            isLoading = true
            let recs = (try? await TMDBService.shared.fetchRecommendations(basedOnTitle: seed.title)) ?? []
            // Esclude i film che hai già visto/salvato
            let savedTitles = Set(savedEntries.map { $0.title })
            recommendedMovies = recs.filter { !savedTitles.contains($0.title) }
            isLoading = false
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
                    Text(movie.year)
                        .font(.system(size: 12))
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
