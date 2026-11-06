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
                        
                        // 1. HEADER SUPERIORE (Navbar + Scopri)
                        HomeHeaderView()
                        
                        // 2. CARD IN EVIDENZA DINAMICA DA TMDB
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
                        
                        // 3. GENERI DI TENDENZA (Pillole)
                        GenreFilterView()
                        
                        // 4. IN TENDENZA OGGI (Carosello TMDB)
                        MovieCarouselView(
                            title: "In Tendenza Oggi",
                            subtitle: "Classifica live giornaliera TMDB",
                            movies: viewModel.trendingMovies
                        )
                        
                        // 5. TOP 250 UFFICIALE (Carosello TMDB)
                        MovieCarouselView(
                            title: "Top 250 Ufficiale",
                            subtitle: "All-Time Hall of Fame TMDB",
                            movies: viewModel.topRatedMovies
                        )
                        
                        // 6. CONSIGLIATI PER TE (Dinamico da TMDB)
                        RecommendedSectionView(movies: Array(viewModel.topRatedMovies.reversed()))
                        
                        // 7. ATTIVITÀ COMMUNITY
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

// MARK: - Componente Header Superiore ("HOME" + "TMDB SYNC LIVE" + "Scopri")
struct HomeHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
            
            // Riga 1: Logo HOME + Cerca e Profilo
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
                
                HStack(spacing: LayoutInfo.spaceMD) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    
                    Button(action: {}) {
                        Circle()
                            .fill(Color.theme.primaryCyan)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.theme.background)
                            )
                    }
                }
            }
            
            // Riga 2: Badge "TMDB SYNC LIVE" + Titolo "Scopri" + Avatar verificato
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
                
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.theme.surfaceElevated)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "person.crop.square.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(8)
                                .foregroundColor(Color.theme.textSecondary)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.theme.primaryCyan, lineWidth: 1)
                        )
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.theme.primaryCyan)
                        .background(Circle().fill(Color.theme.background))
                        .offset(x: 4, y: 4)
                }
            }
        }
        .padding(.horizontal, LayoutInfo.gutterMobile)
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
}
