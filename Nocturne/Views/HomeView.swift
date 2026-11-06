import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = MovieCatalogViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LayoutInfo.spaceXL) {
                        
                        HomeHeaderView()
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView("Sincronizzazione TMDB Live...")
                                    .tint(Color.theme.primaryCyan)
                                    .foregroundColor(Color.theme.textSecondary)
                                Spacer()
                            }
                            .padding(.vertical, 60)
                        } else if let featured = viewModel.featuredMovie {
                            NavigationLink(destination: MovieDetailView(movie: featured)) {
                                FeaturedMovieView(movie: featured)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // TUTTI I GENERI TMDB INTERATTIVE
                        GenreFilterView(
                            genres: viewModel.genres,
                            selectedGenre: viewModel.selectedGenre,
                            onSelectGenre: { genre in
                                Task {
                                    await viewModel.selectGenre(genre)
                                }
                            }
                        )
                        
                        // Se hai toccato un genere specifico, mostra subito il carosello di quel genere
                        if let activeGenre = viewModel.selectedGenre {
                            if viewModel.isLoadingGenre {
                                HStack {
                                    Spacer()
                                    ProgressView("Caricamento \(activeGenre.name)...")
                                        .tint(Color.theme.primaryCyan)
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                            } else {
                                MovieCarouselView(
                                    title: "Genere: \(activeGenre.name)",
                                    subtitle: "Catalogo TMDB filtrato per \(activeGenre.name)",
                                    movies: viewModel.genreMovies
                                )
                            }
                        }
                        
                        MovieCarouselView(
                            title: "In Tendenza Oggi",
                            subtitle: "Classifica live giornaliera TMDB",
                            movies: viewModel.trendingMovies
                        )
                        
                        MovieCarouselView(
                            title: "Top 250 Ufficiale",
                            subtitle: "All-Time Hall of Fame TMDB",
                            movies: viewModel.topRatedMovies
                        )
                        
                        // CONSIGLIATI PER TE (Basato sui veri dati SwiftData dell'utente)
                        RecommendedSectionView()
                        
                        CommunityFeedView()
                    }
                    .padding(.top, LayoutInfo.spaceSM)
                    .padding(.bottom, 100)
                }
            }
            .task {
                await viewModel.loadHomeCatalog()
            }
        }
    }
}

struct HomeHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "film.stack")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.theme.primaryCyan)
                    
                    Text("HOME")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .tracking(1.2)
                        .foregroundColor(Color.theme.textPrimary)
                }
                Spacer()
            }
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.theme.primaryCyan)
                            .frame(width: 6, height: 6)
                        
                        Text("TMDB SYNC LIVE")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(Color.theme.primaryCyan)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.theme.surfaceElevated)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.theme.borderActive, lineWidth: 0.5)
                    )
                    
                    Text("Scopri")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(Color.theme.textPrimary)
                }
                Spacer()
            }
        }
        .padding(.horizontal, LayoutInfo.gutterMobile)
    }
}
