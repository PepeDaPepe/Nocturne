import SwiftUI
import SwiftData

struct LogMovieSheet: View {
    let initialMovie: Movie?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var savedEntries: [SavedMovieEntry]
    
    // Film selezionato (passato dalla scheda film oppure scelto cercando su TMDB)
    @State private var selectedMovie: Movie? = nil
    @State private var searchQuery: String = ""
    @State private var searchResults: [Movie] = []
    @State private var isSearching: Bool = false
    
    // Campi del Log
    @State private var userRating: Double = 4.0
    @State private var isLiked: Bool = false
    @State private var isRewatch: Bool = false
    @State private var reviewText: String = ""
    @State private var hasSpoilers: Bool = false
    @State private var shareInCineClub: Bool = true
    @State private var watchedDate: Date = Date()
    @State private var selectedTag: String = "Sala"
    
    init(movie: Movie? = nil) {
        self.initialMovie = movie
        _selectedMovie = State(initialValue: movie)
    }
    
    var ratingDescription: String {
        switch userRating {
        case 4.5...5.0: return "Capolavoro epico"
        case 4.0..<4.5: return "Eccellente"
        case 3.0..<4.0: return "Buon film"
        case 2.0..<3.0: return "Mediocre"
        default: return "Deludente"
        }
    }
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. TOP BAR
                HStack {
                    Button("Annulla") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Capsule()
                            .fill(Color.theme.textTertiary)
                            .frame(width: 36, height: 4)
                        Text(selectedMovie == nil ? "Scegli Film da Registrare" : "Registra Visione")
                            .font(.system(size: 17, weight: .bold, design: .serif))
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    
                    Spacer()
                    
                    if selectedMovie != nil {
                        Button(action: { saveLogAndDismiss() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Salva")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(Color.theme.background)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.theme.primaryCyan)
                            .clipShape(Capsule())
                        }
                    } else {
                        Color.clear.frame(width: 65, height: 32)
                    }
                }
                .padding(.horizontal, LayoutInfo.gutterMobile)
                .padding(.vertical, 12)
                
                // 2. SE NON C'È UN FILM SELEZIONATO, MOSTRA LA RICERCA LIVE TMDB
                if let movie = selectedMovie {
                    logFormView(for: movie)
                } else {
                    moviePickerSearchView
                }
            }
        }
        .onAppear {
            if let movie = selectedMovie {
                loadExistingEntryIfPresent(for: movie)
            }
        }
    }
    
    // MARK: - Vista 1: Ricerca del film su TMDB quando premi "+ Log" dalla TabBar
    private var moviePickerSearchView: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.theme.primaryCyan)
                
                TextField("Cerca il film che hai visto...", text: $searchQuery)
                    .font(.system(size: 15))
                    .foregroundColor(Color.theme.textPrimary)
                    .autocorrectionDisabled()
                
                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.theme.borderActive, lineWidth: 0.5)
            )
            .padding(.horizontal, LayoutInfo.gutterMobile)
            
            if isSearching {
                HStack {
                    Spacer()
                    ProgressView("Ricerca su TMDB...")
                        .tint(Color.theme.primaryCyan)
                    Spacer()
                }
                .padding(.top, 40)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: LayoutInfo.spaceSM) {
                    ForEach(searchResults) { item in
                        Button(action: {
                            withAnimation {
                                selectedMovie = item
                                loadExistingEntryIfPresent(for: item)
                            }
                        }) {
                            HStack(spacing: LayoutInfo.spaceMD) {
                                MovieImageView(source: item.posterName)
                                    .posterStyle()
                                    .frame(width: 50, height: 75)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.system(size: 16, weight: .bold, design: .serif))
                                        .foregroundColor(Color.theme.textPrimary)
                                        .lineLimit(1)
                                    
                                    Text(item.year)
                                        .font(.system(size: 13))
                                        .monospacedDigit()
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color.theme.primaryCyan)
                            }
                            .padding(10)
                            .background(Color.theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, LayoutInfo.gutterMobile)
                .padding(.bottom, 30)
            }
        }
        .task(id: searchQuery) {
            let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                isSearching = true
                searchResults = (try? await TMDBService.shared.fetchTrendingMovies()) ?? []
                isSearching = false
            } else {
                try? await Task.sleep(nanoseconds: 300_000_000)
                isSearching = true
                searchResults = (try? await TMDBService.shared.searchMovies(query: trimmed)) ?? []
                isSearching = false
            }
        }
    }
    
    // MARK: - Vista 2: Modulo di Registrazione e Recensione
    private func logFormView(for movie: Movie) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: LayoutInfo.spaceLG) {
                
                // CARD RIEPILOGO FILM (con tasto "Cambia" se aperto dal tab + Log)
                HStack(spacing: LayoutInfo.spaceMD) {
                    MovieImageView(source: movie.posterName)
                        .posterStyle()
                        .frame(width: 68, height: 102)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text(movie.year)
                                .font(.system(size: 11, weight: .bold))
                                .monospacedDigit()
                                .foregroundColor(Color.theme.primaryCyan)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.theme.primaryCyan.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            
                            if initialMovie == nil {
                                Spacer()
                                Button("Cambia film") {
                                    withAnimation {
                                        selectedMovie = nil
                                    }
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color.theme.primaryCyan)
                            }
                        }
                        
                        Text(movie.title)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Text("Valutazione TMDB: \(String(format: "%.1f", movie.rating)) ★")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    Spacer()
                }
                .padding(LayoutInfo.spaceMD)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                )
                
                // CARD VOTO PERSONALE + STELLE + MI PIACE
                VStack(spacing: LayoutInfo.spaceMD) {
                    HStack {
                        Text("VOTO PERSONALE")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Spacer()
                        
                        Button(action: { isLiked.toggle() }) {
                            HStack(spacing: 6) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                Text("Mi Piace")
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.theme.primaryCyan)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.theme.primaryCyan.opacity(0.12))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.theme.borderActive, lineWidth: 0.5)
                            )
                        }
                    }
                    
                    InteractiveStarRatingView(rating: $userRating, starSize: 34)
                        .padding(.vertical, 4)
                    
                    HStack(spacing: 10) {
                        HStack(spacing: 2) {
                            Text(String(format: "%.1f", userRating))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.theme.primaryCyan)
                            Text("/ 5.0")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        .monospacedDigit()
                        
                        Text(ratingDescription)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.theme.textSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.theme.surfaceElevated)
                            .clipShape(Capsule())
                    }
                }
                .padding(LayoutInfo.spaceLG)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                )
                
                // DATA DI VISIONE
                HStack(spacing: LayoutInfo.spaceMD) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.theme.surfaceElevated)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "calendar")
                                .foregroundColor(Color.theme.primaryCyan)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Data di Visione")
                            .font(.system(size: 11))
                            .foregroundColor(Color.theme.textSecondary)
                        DatePicker("", selection: $watchedDate, displayedComponents: .date)
                            .labelsHidden()
                            .tint(Color.theme.primaryCyan)
                    }
                    Spacer()
                }
                .padding(LayoutInfo.spaceMD)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                )
                
                // PRIMA VISIONE / REWATCH
                HStack(spacing: 0) {
                    Button(action: { isRewatch = false }) {
                        Text("Prima Visione")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(!isRewatch ? Color.theme.primaryCyan : Color.theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(!isRewatch ? Color.theme.surfaceElevated : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    
                    Button(action: { isRewatch = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Rewatch")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isRewatch ? Color.theme.primaryCyan : Color.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(isRewatch ? Color.theme.surfaceElevated : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(4)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                // PILLOLE TAGS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        tagPill(icon: "film", text: "Sala Cinema", tagValue: "Sala")
                        tagPill(icon: "tv", text: "Sala IMAX", tagValue: "IMAX")
                        tagPill(icon: "house", text: "Streaming / Casa", tagValue: "Casa")
                    }
                }
                
                // DIARIO & RECENSIONE
                VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                    HStack {
                        Label("Diario & Recensione", systemImage: "text.alignleft")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.theme.textPrimary)
                        Spacer()
                    }
                    
                    ZStack(alignment: .topLeading) {
                        if reviewText.isEmpty {
                            Text("Scrivi la tua recensione su \(movie.title)...")
                                .font(.system(size: 14))
                                .foregroundColor(Color.theme.textTertiary)
                                .padding(14)
                        }
                        TextEditor(text: $reviewText)
                            .font(.system(size: 14))
                            .foregroundColor(Color.theme.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 110)
                            .padding(8)
                    }
                    .background(Color.theme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    
                    HStack {
                        Image(systemName: "eye.slash")
                            .foregroundColor(Color.theme.textSecondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Contiene Spoiler")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.theme.textPrimary)
                            Text("Avvisa i lettori prima di mostrare il testo")
                                .font(.system(size: 11))
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        Spacer()
                        Toggle("", isOn: $hasSpoilers)
                            .labelsHidden()
                            .tint(Color.theme.primaryCyan)
                    }
                }
                .padding(LayoutInfo.spaceMD)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                )
                
                // BOTTONE FINALE "CONFERMA E ARCHIVIA"
                Button(action: { saveLogAndDismiss() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "movieclapper")
                        Text("Conferma e Archivia")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.theme.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.theme.primaryCyan)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, LayoutInfo.gutterMobile)
        }
    }
    
    // Se il film era già stato salvato in precedenza, carica voto e recensione esistenti
    private func loadExistingEntryIfPresent(for movie: Movie) {
        if let existing = savedEntries.first(where: { $0.title == movie.title }) {
            if existing.userRating > 0 { userRating = existing.userRating }
            isLiked = existing.isLiked
            isRewatch = existing.isRewatch
            reviewText = existing.reviewText
            hasSpoilers = existing.hasSpoilers
            selectedTag = existing.watchTag
            if let date = existing.watchedDate { watchedDate = date }
        }
    }
    
    private func saveLogAndDismiss() {
        guard let movie = selectedMovie else { return }
        
        if let existing = savedEntries.first(where: { $0.title == movie.title }) {
            existing.isWatched = true
            existing.isInWatchlist = false
            existing.userRating = userRating
            existing.isLiked = isLiked
            existing.isRewatch = isRewatch
            existing.reviewText = reviewText
            existing.hasSpoilers = hasSpoilers
            existing.watchTag = selectedTag
            existing.watchedDate = watchedDate
        } else {
            let newEntry = SavedMovieEntry(
                movie: movie,
                isInWatchlist: false,
                isWatched: true,
                userRating: userRating,
                isLiked: isLiked,
                isRewatch: isRewatch,
                reviewText: reviewText,
                hasSpoilers: hasSpoilers,
                watchTag: selectedTag,
                watchedDate: watchedDate
            )
            modelContext.insert(newEntry)
        }
        try? modelContext.save()
        dismiss()
    }
    
    @ViewBuilder
    private func tagPill(icon: String, text: String, tagValue: String) -> some View {
        let isActive = (selectedTag == tagValue)
        Button(action: { selectedTag = tagValue }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(text)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .frame(height: 30)
            .foregroundColor(isActive ? Color.theme.primaryCyan : Color.theme.textSecondary)
            .background(isActive ? Color.theme.primaryCyan.opacity(0.15) : Color.theme.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.theme.borderActive : Color.theme.borderHairline, lineWidth: 0.5)
            )
        }
    }
}
