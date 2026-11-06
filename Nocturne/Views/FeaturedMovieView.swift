import SwiftUI

struct FeaturedMovieView: View {
    let movie: Movie
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // 1. SFONDO DINAMICO DA TMDB O ASSETS
            Color.theme.surfaceElevated
                .overlay(
                    MovieImageView(source: movie.backdropName)
                )
                .overlay(
                    LinearGradient(
                        stops: [
                            .init(color: Color.theme.background.opacity(0.35), location: 0.0),
                            .init(color: Color.theme.background.opacity(0.1), location: 0.4),
                            .init(color: Color.theme.background.opacity(0.95), location: 0.85),
                            .init(color: Color.theme.background, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipped()
            
            // 2. CONTENUTO DELLA CARD
            VStack(alignment: .leading, spacing: 0) {
                
                // Barra superiore: Badge "IN EVIDENZA OGGI" + Bottone Share
                HStack {
                    Text("IN EVIDENZA OGGI")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.theme.background.opacity(0.85))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.theme.textPrimary)
                            .frame(width: 34, height: 34)
                            .background(Color.theme.background.opacity(0.75))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                            )
                    }
                }
                
                Spacer()
                
                // Blocco inferiore: Metadati, Titolo, Trama, Bottoni
                VStack(alignment: .leading, spacing: LayoutInfo.spaceSM) {
                    
                    HStack(spacing: LayoutInfo.spaceSM) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color.theme.primaryCyan)
                                .font(.system(size: 11))
                            Text(String(format: "%.1f", movie.rating))
                                .font(.system(size: 13, weight: .bold))
                                .monospacedDigit()
                                .foregroundColor(Color.theme.primaryCyan)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.theme.primaryCyan.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        
                        Text("\(movie.year) • \(movie.runtime / 60)h \(movie.runtime % 60)m")
                            .font(.system(size: 13, weight: .medium))
                            .monospacedDigit()
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Text("4K Atmos")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color.theme.primaryCyan)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.theme.surfaceElevated.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .stroke(Color.theme.borderActive, lineWidth: 0.5)
                            )
                    }
                    
                    Text(movie.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.theme.textPrimary)
                        .lineLimit(1)
                    
                    Text(movie.synopsis)
                        .font(.system(size: 14))
                        .foregroundColor(Color.theme.textSecondary)
                        .lineLimit(2)
                        .padding(.bottom, 4)
                    
                    HStack(spacing: LayoutInfo.spaceMD) {
                        Button(action: {}) {
                            HStack(spacing: 8) {
                                Image(systemName: "bookmark.fill")
                                Text("Aggiungi a Watchlist")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.theme.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.theme.primaryCyan)
                            .clipShape(RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusButton, style: .continuous))
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color.theme.textPrimary)
                                .frame(width: 46, height: 46)
                                .background(Color.theme.surfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusButton, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusButton, style: .continuous)
                                        .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                                )
                        }
                    }
                }
            }
            .padding(LayoutInfo.spaceLG)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
        )
        .padding(.horizontal, LayoutInfo.gutterMobile)
    }
}

#Preview {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        FeaturedMovieView(movie: Movie.featuredDune)
    }
    .preferredColorScheme(.dark)
}
