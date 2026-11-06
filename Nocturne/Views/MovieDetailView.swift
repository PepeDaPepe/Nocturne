import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @State private var isWatchlisted: Bool = false
    @State private var showLogSheet: Bool = false
    @State private var quickRating: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: LayoutInfo.spaceXL) {
                    
                    // 1. HEADER BACKDROP + LOCANDINA 2:3 E TITOLO
                    ZStack(alignment: .bottomLeading) {
                        MovieImageView(source: movie.backdropName)
                        
                        HStack(alignment: .bottom, spacing: LayoutInfo.spaceLG) {
                            // Locandina 2:3
                            MovieImageView(source: movie.posterName)
                            
                            // Metadati principali
                            VStack(alignment: .leading, spacing: 6) {
                                Text("DIRECTED BY \(movie.director.uppercased())")
                                    .font(.system(size: 10, weight: .bold))
                                    .tracking(0.8)
                                    .foregroundColor(Color.theme.primaryCyan)
                                
                                Text(movie.title)
                                    .font(.system(size: 26, weight: .bold))
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
                    
                    // 2. PULSANTI DI AZIONE (Registra + Watchlist)
                    HStack(spacing: LayoutInfo.spaceMD) {
                        Button(action: {
                            showLogSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Registra o Recensisci")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.theme.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(Color.theme.primaryCyan)
                            .clipShape(RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusButton, style: .continuous))
                        }
                        
                        Button(action: {
                            isWatchlisted.toggle()
                        }) {
                            Image(systemName: isWatchlisted ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(isWatchlisted ? Color.theme.primaryCyan : Color.theme.textPrimary)
                                .frame(width: 46, height: 46)
                                .background(Color.theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusButton, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: LayoutInfo.cornerRadiusButton, style: .continuous)
                                        .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                                )
                        }
                    }
                    .padding(.horizontal, LayoutInfo.gutterMobile)
                    
                    // 3. VALUTAZIONE RAPIDA CON STELLE
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
                    
                    // 5. RECENSIONI SUL FILM
                    CommunityFeedView()
                }
                .padding(.bottom, 110)
            }
        }
        .sheet(isPresented: $showLogSheet) {
            LogMovieSheet(movie: movie)
        }
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movie: Movie.featuredDune)
    }
    .preferredColorScheme(.dark)
}
//
//  MovieDetailView.swift
//  Nocturne
//
//  Created by d7 on 06/11/26.
//

