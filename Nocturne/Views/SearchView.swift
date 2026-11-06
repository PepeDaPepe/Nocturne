import SwiftUI

struct FeaturedGenreCardItem: Identifiable {
    let id = UUID()
    let name: String
    let countText: String
}

struct SearchView: View {
    @StateObject private var viewModel = MovieCatalogViewModel()
    @State private var searchText: String = "Blade Runner"
    @State private var selectedCategory: String = "Tutti"
    
    let categories = ["Tutti", "Film", "Registi", "Attori", "Cineforum"]
    
    @State private var recentSearches = [
        "Denis Villeneuve",
        "Christopher Nolan",
        "Cyberpunk 2077",
        "A24"
    ]
    
    let featuredGenres: [FeaturedGenreCardItem] = [
        FeaturedGenreCardItem(name: "Cyberpunk", countText: "142 film"),
        FeaturedGenreCardItem(name: "Neo-Noir", countText: "98 film"),
        FeaturedGenreCardItem(name: "Psicologico", countText: "215 film"),
        FeaturedGenreCardItem(name: "D'Autore", countText: "380 film")
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
                        
                        // 1. HEADER SUPERIORE ("Cerca")
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
                            
                            HStack(spacing: 14) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.theme.textSecondary)
                                
                                Circle()
                                    .fill(Color.theme.surfaceElevated)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "person.circle")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.theme.primaryCyan)
                                    )
                            }
                        }
                        .padding(.horizontal, LayoutInfo.gutterMobile)
                        
                        // 2. BARRA DI RICERCA LIVE + FILTRI
                        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.theme.primaryCyan)
                                
                                TextField("Cerca film su TMDB...", text: $searchText)
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
                                
                                Button(action: {}) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryCyan)
                                        .frame(width: 32, height: 32)
                                        .background(Color.theme.primaryCyan.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(Color.theme.borderActive, lineWidth: 0.5)
                                        )
                                }
                            }
                            .padding(.leading, 14)
                            .padding(.trailing, 8)
                            .frame(height: 48)
                            .background(Color.theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                            )
                            .padding(.horizontal, LayoutInfo.gutterMobile)
                            
                            // Pillole Categoria
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
                        
                        // 3. RICERCHE RECENTI (Cliccabili per cercare subito)
                        if !recentSearches.isEmpty {
                            VStack(alignment: .leading, spacing: LayoutInfo.spaceSM) {
                                HStack {
                                    HStack(spacing: 6) {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color.theme.textSecondary)
                                        Text("RICERCHE RECENTI")
                                            .font(.system(size: 11, weight: .bold))
                                            .tracking(0.8)
                                            .foregroundColor(Color.theme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button("Cancella tutto") {
                                        withAnimation {
                                            recentSearches.removeAll()
                                        }
                                    }
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.theme.primaryCyan)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        ForEach(recentSearches.prefix(2), id: \.self) { term in
                                            recentChip(term: term)
                                        }
                                    }
                                    if recentSearches.count > 2 {
                                        HStack(spacing: 8) {
                                            ForEach(recentSearches.dropFirst(2), id: \.self) { term in
                                                recentChip(term: term)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, LayoutInfo.gutterMobile)
                        }
                        
                        // 4. RISULTATI DI RICERCA DA TMDB
                        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                            HStack(alignment: .bottom) {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("Risultati")
                                        .font(.system(size: 19, weight: .bold, design: .serif))
                                        .foregroundColor(Color.theme.textPrimary)
                                    
                                    Text("\(viewModel.searchResults.count) titoli trovati")
                                        .font(.system(size: 12))
                                        .monospacedDigit()
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    HStack(spacing: 4) {
                                        Text("Rilevanza")
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color.theme.primaryCyan)
                                }
                            }
                            
                            VStack(spacing: LayoutInfo.spaceMD) {
                                ForEach(viewModel.searchResults) { movie in
                                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                                        SearchResultRowCard(movie: movie)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, LayoutInfo.gutterMobile)
                        
                        // 5. GENERI IN EVIDENZA
                        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                            HStack(alignment: .bottom) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color.theme.primaryCyan)
                                    
                                    Text("Generi in Evidenza")
                                        .font(.system(size: 18, weight: .bold, design: .serif))
                                        .foregroundColor(Color.theme.textPrimary)
                                }
                                
                                Spacer()
                                
                                Text("Esplora cataloghi")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                            
                            LazyVGrid(columns: genreColumns, spacing: LayoutInfo.spaceMD) {
                                ForEach(featuredGenres) { genre in
                                    NavigationLink(
                                        destination: ExpandedMovieListView(
                                            title: genre.name,
                                            subtitle: "Catalogo Genere",
                                            badgeTitle: genre.countText,
                                            movies: viewModel.searchResults,
                                            showRank: false
                                        )
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
                                                
                                                Text(genre.countText)
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .monospacedDigit()
                                                    .foregroundColor(Color.theme.primaryCyan)
                                            }
                                            .padding(14)
                                        }
                                        .frame(height: 92)
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
            // Esegue automaticamente la ricerca su TMDB ogni volta che cambia il testo
            .task(id: searchText) {
                try? await Task.sleep(nanoseconds: 300_000_000) // Attende 0.3s mentre digiti
                await viewModel.performSearch(query: searchText)
            }
        }
    }
    
    @ViewBuilder
    private func recentChip(term: String) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                searchText = term
            }) {
                Text(term)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.theme.textPrimary)
            }
            
            Button(action: {
                withAnimation {
                    recentSearches.removeAll { $0 == term }
                }
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

struct SearchResultRowCard: View {
    let movie: Movie
    @State private var inWatchlist: Bool = false
    
    var body: some View {
        HStack(spacing: LayoutInfo.spaceMD) {
            ZStack(alignment: .topTrailing) {
                MovieImageView(source: movie.posterName)
                    .posterStyle()
                    .frame(width: 78, height: 117)
                
                Text("4K")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color.theme.primaryCyan)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.theme.background.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(5)
            }
            
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
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color.theme.primaryCyan)
                        }
                    }
                    
                    Text(String(format: "%.1f", movie.rating))
                        .font(.system(size: 12, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text("(TMDB)")
                        .font(.system(size: 11))
                        .foregroundColor(Color.theme.textSecondary)
                }
                .padding(.top, 2)
                
                Spacer(minLength: 4)
                
                HStack {
                    Text("CINEMA")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.6)
                        .foregroundColor(Color.theme.primaryCyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.theme.primaryCyan.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    
                    Spacer()
                    
                    Button(action: { inWatchlist.toggle() }) {
                        HStack(spacing: 5) {
                            Image(systemName: inWatchlist ? "bookmark.fill" : "plus.square.on.square")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color.theme.primaryCyan)
                            Text("Watchlist")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.theme.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
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

#Preview {
    SearchView()
        .preferredColorScheme(.dark)
}
