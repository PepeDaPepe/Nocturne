import SwiftUI

struct RankedMovie: Identifiable {
    let id = UUID()
    let rank: Int
    let title: String
    let year: String
    let rating: Double
    let posterName: String
}

struct ExpandedMovieListView: View {
    @State private var isGridView: Bool = true
    
    let rankedMovies: [RankedMovie] = [
        RankedMovie(rank: 1, title: "Le ali della libertà", year: "1994", rating: 9.3, posterName: "shawshank_poster"),
        RankedMovie(rank: 2, title: "Il padrino", year: "1972", rating: 9.2, posterName: "godfather_poster"),
        RankedMovie(rank: 3, title: "Il cavaliere oscuro", year: "2008", rating: 9.0, posterName: "darkknight_poster"),
        RankedMovie(rank: 4, title: "Il padrino - Parte II", year: "1974", rating: 9.0, posterName: "godfather2_poster"),
        RankedMovie(rank: 5, title: "La parola ai giurati", year: "1957", rating: 9.0, posterName: "angrymen_poster"),
        RankedMovie(rank: 6, title: "Schindler's List", year: "1993", rating: 9.0, posterName: "schindler_poster"),
        RankedMovie(rank: 7, title: "Pulp Fiction", year: "1994", rating: 8.9, posterName: "pulpfiction_poster"),
        RankedMovie(rank: 8, title: "La città incantata", year: "2001", rating: 8.9, posterName: "spirited_poster"),
        RankedMovie(rank: 9, title: "Il buono, il brutto, il cattivo", year: "1966", rating: 8.8, posterName: "goodbadugly_poster")
    ]
    
    // Griglia fissa a 3 colonne con spaziatura 12px come da DESIGN.md
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
                    
                    // 1. SOTTOTITOLO HALL OF FAME
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.theme.primaryCyan)
                                .frame(width: 6, height: 6)
                            Text("ALL-TIME HALL OF FAME")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        Spacer()
                        Text("Top 250 Ufficiale")
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
                    
                    // 3. GRIGLIA A 3 COLONNE
                    LazyVGrid(columns: columns, spacing: LayoutInfo.spaceLG) {
                        ForEach(rankedMovies) { item in
                            RankedPosterCell(item: item)
                        }
                    }
                    
                    // 4. FOOTER PROGRESSO ("Visualizzati 24 di 250 film" + Bottone)
                    VStack(spacing: 12) {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.theme.surfaceElevated)
                                .frame(width: 140, height: 4)
                            Capsule()
                                .fill(Color.theme.primaryCyan)
                                .frame(width: 28, height: 4)
                        }
                        
                        Text("Visualizzati 24 di 250 film")
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
        .navigationTitle("Film Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RankedPosterCell: View {
    let item: RankedMovie
    @State private var isSaved: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack {
                Color.theme.surfaceElevated
                    .overlay(
                        Image(item.posterName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    )
                    .posterStyle()
                
                VStack {
                    // Riga superiore: Rank (#1) + Segnalibro
                    HStack {
                        Text("#\(item.rank)")
                            .font(.system(size: 10, weight: .bold))
                            .monospacedDigit()
                            .foregroundColor(Color.theme.primaryCyan)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.theme.background.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
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
                    
                    // Riga inferiore: Voto con stella
                    HStack {
                        HStack(spacing: 3) {
                            Image(systemName: "star")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(Color.theme.primaryCyan)
                            Text(String(format: "%.1f", item.rating))
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
            
            Text(item.title)
                .font(.system(size: 13, weight: .bold, design: .serif))
                .foregroundColor(Color.theme.textPrimary)
                .lineLimit(1)
            
            Text(item.year)
                .font(.system(size: 11))
                .monospacedDigit()
                .foregroundColor(Color.theme.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        ExpandedMovieListView()
    }
    .preferredColorScheme(.dark)
}
