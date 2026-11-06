import SwiftUI
import SwiftData

struct SearchView: View {
    @StateObject private var viewModel = MovieCatalogViewModel()
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "Tutti"
    
    let categories = ["Tutti", "Film", "Registi", "Attori"]
    
    @State private var recentSearches = [
        "Denis Villeneuve",
        "Christopher Nolan",
        "Blade Runner",
        "Interstellar"
    ]
    
    private let genreColumns = [
        GridItem(.flexible(), spacing: LayoutInfo.spaceMD),
        GridItem(.flexible(), spacing: LayoutInfo.spaceMD)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LayoutInfo.spaceXL) {
                        
                        // HEADER SUPERIORE
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "movieclapper")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.theme.primaryCyan)
                                
                                Text("Cerca")
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, LayoutInfo.gutterMobile)
                        
                        // BARRA DI RICERCA LIVE + CATEGORIE INTERATTIVE
                        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.theme.primaryCyan)
                                
                                TextField("Cerca \(selectedCategory.lowercased()) su TMDB...", text: $searchText)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.theme.textPrimary)
                                    .submitLabel(.search)
                                
                                if !searchText.isEmpty {
                                    Button(action: { searchText = "" }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(Color.theme.textSecondary)
                                            .frame(width: 22, height: 22)
                                            .background(Color.theme.surfaceElevated)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(.leading, 14)
                            .padding(.trailing, 12)
                            .frame(height: 48)
                            .background(Color.theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                            )
                            .padding(.horizontal, LayoutInfo.gutterMobile)
                            
                            // Pillole Categoria (Tutti, Film, Registi, Attori)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(categories, id: \.self) { category in
                                        let isSelected = (selectedCategory == category)
                                        
                                        Button(action: {
                                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                                selectedCategory = category
                                            }
                                        }) {
                                            Text(category)
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(isSelected ? Color.theme.background : Color.theme.textSecondary)
                                                .padding(.horizontal, 16)
                                                .frame(height: 32)
                                                .background(isSelected ? Color.theme.primaryCyan : Color.theme.surface)
                                                .clipShape(Capsule())
                                                .overlay(
                                                    Capsule()
                                                        .stroke(isSelected ? Color.clear : Color.theme.borderHairline, lineWidth: 0.5)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal, LayoutInfo.gutterMobile)
                            }
                        }
                        
                        // RICERCHE RAPIDE
                        if !recentSearches.isEmpty {
                            VStack(alignment: .leading, spacing: LayoutInfo.spaceSM) {
                                HStack {
                                    Text("RICERCHE CONSIGLIATE")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(0.8)
                                        .foregroundColor(Color.theme.textSecondary)
                                    Spacer()
                                    Button("Cancella") {
                                        withAnimation { recentSearches.removeAll() }
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.theme.primaryCyan)
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(recentSearches, id: \.self) { term in
                                            recentChip(term: term)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, LayoutInfo.gutterMobile)
                        }
                        
                        // RISULTATI DI RICERCA DA TMDB
                        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(searchText.isEmpty ? "Popolari su TMDB" : "Risultati (\(selectedCategory))")
                                    .font(.system(size: 19, weight: .bold, design: .serif))
                                    .foregroundColor(Color.theme.textPrimary)
                                
                                Text("\(viewModel.searchResults.count) titoli")
                                    .font(.system(size: 12))
                                    .monospacedDigit()
                                    .foregroundColor(Color.theme.textSecondary)
                                Spacer()
                            }
                            
                            VStack(spacing: LayoutInfo.spaceMD) {
                                ForEach(viewModel.searchResults.prefix(8)) { movie in
                                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                                        SearchResultRowCard(movie: movie)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, LayoutInfo.gutterMobile)
                        
                        // TUTTI I GENERI UFFICIALI TMDB CLICCABILI
                        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                            HStack(alignment: .bottom) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryCyan)
                                    
                                    Text("Tutti i Generi TMDB")
                                        .font(.system(size: 18, weight: .bold, design: .serif))
                                        .foregroundColor(Color.theme.textPrimary)
                                }
                                Spacer()
                                Text("\(viewModel.genres.count) cataloghi")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                            
                            LazyVGrid(columns: genreColumns, spacing: LayoutInfo.spaceMD) {
                                ForEach(viewModel.genres) { genre in
                                    NavigationLink(
                                        destination: GenreCatalogDestinationView(genre: genre)
                                    ) {
                                        ZStack(alignment: .bottomLeading) {
                                            LinearGradient(
                                                colors: [
                                                    Color.theme.primaryCyan.opacity(0.18),
                                                    Color.theme.surface
                                                ],
                                                startPoint: .topTrailing,
                                                endPoint: .bottomLeading
                                            )
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(genre.name)
                                                    .font(.system(size: 17, weight: .bold, design: .serif))
                                                    .foregroundColor(Color.theme.textPrimary)
                                                
                                                Text("Esplora su TMDB →")
                                                    .font(.system(size: 11, weight: .semibold))
                                                    .foregroundColor(Color.theme.primaryCyan)
                                            }
                                            .padding(14)
                                        }
                                        .frame(height: 86)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, LayoutInfo.gutterMobile)
                    }
                    .padding(.top, LayoutInfo.spaceSM)
                    .padding(.bottom, 100)
                }
            }
            // Ricerca automatica quando cambi testo O quando tocchi Film / Registi / Attori
            .task(id: "\(searchText)-\(selectedCategory)") {
                try? await Task.sleep(nanoseconds: 250_000_000)
                await viewModel.performSearch(query: searchText, category: selectedCategory)
            }
        }
    }
    
    @ViewBuilder
    private func recentChip(term: String) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                if term == "Denis Villeneuve" || term == "Christopher Nolan" {
                    selectedCategory = "Registi"
                }
                searchText = term
            }) {
                Text(term)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.theme.textPrimary)
            }
            
            Button(action: {
                withAnimation { recentSearches.removeAll { $0 == term } }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 30)
        .background(Color.theme.surface)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
        )
    }
}

// Vista che scarica i film reali del genere cliccato in SearchView
struct GenreCatalogDestinationView: View {
    let genre: TMDBGenre
    @State private var movies: [Movie] = []
    
    var body: some View {
        ExpandedMovieListView(
            title: genre.name,
            subtitle: "CATALOGO UFFICIALE TMDB",
            badgeTitle: genre.name,
            movies: movies,
            showRank: false
        )
        .task {
            movies = (try? await TMDBService.shared.fetchMoviesByGenre(genreId: genre.id)) ?? []
        }
    }
}

struct SearchResultRowCard: View {
    let movie: Movie
    @Environment(\.modelContext) private var modelContext
    @Query private var savedEntries: [SavedMovieEntry]
    
    private var existingEntry: SavedMovieEntry? {
        savedEntries.first(where: { $0.title == movie.title })
    }
    
    private var inWatchlist: Bool {
        existingEntry?.isInWatchlist == true
    }
    
    var body: some View {
        HStack(spacing: LayoutInfo.spaceMD) {
            MovieImageView(source: movie.posterName)
                .posterStyle()
                .frame(width: 78, height: 117)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(1)
                
                Text("\(movie.year) • \(movie.director)")
                    .font(.system(size: 13))
                    .monospacedDigit()
                    .foregroundColor(Color.theme.textSecondary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color.theme.primaryCyan)
                    
                    Text(String(format: "%.1f", movie.rating))
                        .font(.system(size: 12, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(Color.theme.textPrimary)
                }
                .padding(.top, 2)
                
                Spacer(minLength: 4)
                
                HStack {
                    Text("TMDB")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.6)
                        .foregroundColor(Color.theme.primaryCyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.theme.primaryCyan.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    
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
                        HStack(spacing: 5) {
                            Image(systemName: inWatchlist ? "bookmark.fill" : "plus.square.on.square")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color.theme.primaryCyan)
                            Text(inWatchlist ? "Salvato" : "Watchlist")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(inWatchlist ? Color.theme.primaryCyan : Color.theme.textSecondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.theme.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(inWatchlist ? Color.theme.primaryCyan : Color.theme.borderHairline, lineWidth: 0.5)
                        )
                    }
                }
            }
        }
        .padding(12)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
        )
    }
}
