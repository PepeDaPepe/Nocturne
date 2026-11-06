import SwiftUI
import SwiftData

struct MovieDetailView: View {
    let movie: Movie
    @Environment(\.modelContext) private var modelContext
    @Query private var savedEntries: [SavedMovieEntry]
    
    @State private var showLogSheet: Bool = false
    @State private var quickRating: Double = 0.0
    
    private var existingEntry: SavedMovieEntry? {
        savedEntries.first(where: { $0.title == movie.title })
    }
    
    private var isWatchlisted: Bool {
        existingEntry?.isInWatchlist == true
    }
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: LayoutInfo.spaceXL) {
                    
                    // 1. HEADER BACKDROP + LOCANDINA 2:3 E TITOLO
                    ZStack(alignment: .bottomLeading) {
                        Color.theme.surfaceElevated
                            .overlay(
                                MovieImageView(source: movie.backdropName)
                            )
                            .overlay(
                                LinearGradient(
                                    colors: [
                                        Color.theme.background.opacity(0.2),
                                        Color.theme.background.opacity(0.85),
                                        Color.theme.background
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipped()
                            .frame(height: 300)
                        
                        HStack(alignment: .bottom, spacing: LayoutInfo.spaceLG) {
                            MovieImageView(source: movie.posterName)
                                .posterStyle()
                                .frame(width: 105, height: 157.5)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("CATALOGO TMDB")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(0.8)
                                    .foregroundColor(Color.theme.primaryCyan)
                                
                                Text(movie.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color.theme.textPrimary)
                                
                                HStack(spacing: 8) {
                                    Text(movie.year)
                                    Text("•")
                                    Text("RUNTIME \(movie.runtime)M")
                                        .tracking(0.8)
                                }
                                .font(.system(size: 11, weight: .bold))
                                .monospacedDigit()
                                .foregroundColor(Color.theme.textSecondary)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.theme.tertiaryGlow)
                                    Text(String(format: "%.1f", movie.rating))
                                        .font(.system(size: 14, weight: .bold))
                                        .monospacedDigit()
                                        .foregroundColor(Color.theme.textPrimary)
                                    Text("Media TMDB")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                .padding(.top, 2)
                            }
                        }
                        .padding(.horizontal, LayoutInfo.gutterMobile)
                    }
                    
                    // 2. PULSANTI DI AZIONE (Registra + Watchlist collegato a SwiftData)
                    HStack(spacing: LayoutInfo.spaceMD) {
                        Button(action: {
                            showLogSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: existingEntry?.isWatched == true ? "pencil.circle.fill" : "plus.circle.fill")
                                Text(existingEntry?.isWatched == true ? "Modifica Recensione" : "Registra o Recensisci")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.theme.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.theme.primaryCyan)
                            .clipShape(RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusButton, style: .continuous))
                        }
                        
                        Button(action: {
                            toggleWatchlist()
                        }) {
                            Image(systemName: isWatchlisted ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(isWatchlisted ? Color.theme.primaryCyan : Color.theme.textPrimary)
                                .frame(width: 46, height: 46)
                                .background(Color.theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusButton, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusButton, style: .continuous)
                                        .stroke(isWatchlisted ? Color.theme.primaryCyan : Color.theme.borderHairline, lineWidth: 0.5)
                                )
                        }
                    }
                    .padding(.horizontal, LayoutInfo.gutterMobile)
                    
                    // 3. VALUTAZIONE RAPIDA CON STELLE (Salva in SwiftData)
                    VStack(alignment: .leading, spacing: LayoutInfo.spaceSM) {
                        Text("LA TUA VALUTAZIONE RAPIDA")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(Color.theme.textSecondary)
                        
                        HStack {
                            InteractiveStarRatingView(rating: $quickRating, starSize: 26)
                            Spacer()
                            if quickRating > 0 {
                                Text(String(format: "%.1f ★", quickRating))
                                    .font(.system(size: 14, weight: .bold))
                                    .monospacedDigit()
                                    .foregroundColor(Color.theme.tertiaryGlow)
                            } else {
                                Text("Tocca o trascina")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.theme.textTertiary)
                            }
                        }
                        .padding(LayoutInfo.spaceMD)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                    }
                    .padding(.horizontal, LayoutInfo.gutterMobile)
                    .onChange(of: quickRating) { _, newValue in
                        guard newValue > 0 else { return }
                        saveQuickRating(newValue)
                    }
                    
                    // 4. SINOSSI
                    VStack(alignment: .leading, spacing: LayoutInfo.spaceSM) {
                        Text("SINOSSI")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Text(movie.synopsis)
                            .font(.system(size: 15))
                            .lineSpacing(4)
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    .padding(.horizontal, LayoutInfo.gutterMobile)
                    
                    // 5. LA TUA RECENSIONE SALVATA IN SWIFTDATA (se presente)
                    if let entry = existingEntry, entry.isWatched {
                        VStack(alignment: .leading, spacing: LayoutInfo.spaceSM) {
                            Text("IL TUO LOG SU QUESTO FILM")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(Color.theme.primaryCyan)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(Color.theme.tertiaryGlow)
                                        Text(String(format: "%.1f / 5.0", entry.userRating))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color.theme.textPrimary)
                                    }
                                    if entry.isLiked {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(Color.theme.primaryCyan)
                                    }
                                    Spacer()
                                    Text(entry.watchTag)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryCyan)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.theme.primaryCyan.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                                
                                if !entry.reviewText.isEmpty {
                                    Text("“\(entry.reviewText)”")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.theme.textSecondary)
                                        .lineSpacing(3)
                                }
                            }
                            .padding(LayoutInfo.spaceMD)
                            .background(Color.theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.theme.borderActive, lineWidth: 0.5)
                            )
                        }
                        .padding(.horizontal, LayoutInfo.gutterMobile)
                    }
                }
                .padding(.bottom, 110)
            }
        }
        .onAppear {
            if let rating = existingEntry?.userRating, rating > 0 {
                quickRating = rating
            }
        }
        .sheet(isPresented: $showLogSheet) {
            LogMovieSheet(movie: movie)
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
    
    private func saveQuickRating(_ value: Double) {
        if let entry = existingEntry {
            entry.userRating = value
            entry.isWatched = true
            if entry.watchedDate == nil { entry.watchedDate = Date() }
        } else {
            let newEntry = SavedMovieEntry(
                movie: movie,
                isInWatchlist: false,
                isWatched: true,
                userRating: value,
                watchedDate: Date()
            )
            modelContext.insert(newEntry)
        }
        try? modelContext.save()
    }
}
