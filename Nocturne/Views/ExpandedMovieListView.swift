import SwiftUI

struct ExpandedMovieListView: View {
    let title: String
    let subtitle: String
    let badgeTitle: String
    let movies: [Movie]
    var showRank: Bool = true
    
    @State private var isGridView: Bool = true
    
    private let columns = [
        GridItem(.flexible(), spacing: LayoutInfo.spaceMD),
        GridItem(.flexible(), spacing: LayoutInfo.spaceMD),
        GridItem(.flexible(), spacing: LayoutInfo.spaceMD)
    ]
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: LayoutInfo.spaceLG) {
                    
                    // 1. SOTTOTITOLO DINAMICO
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.theme.primaryCyan)
                                .frame(width: 6, height: 6)
                            Text(subtitle.uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        Spacer()
                        Text(badgeTitle)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.theme.primaryCyan)
                    }
                    
                    // 2. BARRA CONTROLLI (Switch Griglia/Lista + Ordina Voto TMDB)
                    HStack {
                        HStack(spacing: 4) {
                            Button(action: { isGridView = true }) {
                                Image(systemName: "square.grid.2x2")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(isGridView ? Color.theme.background : Color.theme.textSecondary)
                                    .frame(width: 34, height: 30)
                                    .background(isGridView ? Color.theme.primaryCyan : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            }
                            Button(action: { isGridView = false }) {
                                Image(systemName: "rectangle.grid.1x2")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(!isGridView ? Color.theme.background : Color.theme.textSecondary)
                                    .frame(width: 34, height: 30)
                                    .background(!isGridView ? Color.theme.primaryCyan : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            }
                        }
                        .padding(3)
                        .background(Color.theme.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Text("Voto TMDB")
                                    .font(.system(size: 12, weight: .medium))
                                Image(systemName: "arrowtriangle.down.fill")
                                    .font(.system(size: 8))
                            }
                            .foregroundColor(Color.theme.textPrimary)
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                            .background(Color.theme.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            
                            Button(action: {}) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.theme.textPrimary)
                                    .frame(width: 34, height: 34)
                                    .background(Color.theme.surfaceElevated)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                    
                    // 3. GRIGLIA A 3 COLONNE CON FILM CLICCABILI
                    LazyVGrid(columns: columns, spacing: LayoutInfo.spaceLG) {
                        ForEach(Array(movies.enumerated()), id: \.element.id) { index, movie in
                            NavigationLink(destination: MovieDetailView(movie: movie)) {
                                MovieImageView(source: movie.posterName)
                                    .posterStyle()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // 4. FOOTER PROGRESSO DINAMICO
                    VStack(spacing: 12) {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.theme.surfaceElevated)
                                .frame(width: 140, height: 4)
                            Capsule()
                                .fill(Color.theme.primaryCyan)
                                .frame(width: 40, height: 4)
                        }
                        
                        Text("Visualizzati \(movies.count) film in \(title)")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Text("TMDB LIVE SYNC")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(Color.theme.primaryCyan)
                        
                        Button(action: {}) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Carica altri film")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color.theme.primaryCyan)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.theme.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                            )
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, LayoutInfo.spaceXL)
                }
                .padding(.horizontal, LayoutInfo.gutterMobile)
                .padding(.bottom, 90)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DynamicGridPosterCell: View {
    let movie: Movie
    let rank: Int?
    @State private var isSaved: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                Color.theme.surfaceElevated
                    .overlay(
                        Image(movie.posterName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    )
                    .posterStyle()
                
                VStack {
                    HStack {
                        if let rank = rank {
                            Text("#\(rank)")
                                .font(.system(size: 10, weight: .bold))
                                .monospacedDigit()
                                .foregroundColor(Color.theme.primaryCyan)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.theme.background.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        
                        Spacer()
                        
                        Button(action: { isSaved.toggle() }) {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(isSaved ? Color.theme.primaryCyan : Color.theme.textPrimary)
                                .frame(width: 24, height: 24)
                                .background(Color.theme.background.opacity(0.85))
                                .clipShape(Circle())
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        HStack(spacing: 3) {
                            Image(systemName: "star")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color.theme.primaryCyan)
                            Text(String(format: "%.1f", movie.rating))
                                .font(.system(size: 11, weight: .bold))
                                .monospacedDigit()
                                .foregroundColor(Color.theme.textPrimary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.theme.background.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Spacer()
                    }
                }
                .padding(6)
            }
            
            Text(movie.title)
                .font(.system(size: 13, weight: .bold, design: .serif))
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(1)
            
            Text(movie.year)
                .font(.system(size: 11))
                .monospacedDigit()
                .foregroundColor(Color.theme.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        ExpandedMovieListView(
            title: "Top 250 Ufficiale",
            subtitle: "ALL-TIME HALL OF FAME",
            badgeTitle: "Top 250 Ufficiale",
            movies: Movie.sampleTop250Preview,
            showRank: true
        )
    }
    .preferredColorScheme(.dark)
}
