import SwiftUI

struct ProfileView: View {
    @State private var selectedTab: String = "Diario"
    let profileTabs = ["Diario", "Recensioni (64)", "Liste (12)", "Stats"]
    
    let favoriteMovies: [(title: String, year: String, poster: String)] = [
        ("Blade Runner 2049", "2017", "bladerunner_poster"),
        ("2001: Odissea nello spazio", "1968", "odissea_poster"),
        ("Interstellar", "2014", "interstellar_poster"),
        ("Past Lives", "2023", "pastlives_poster")
    ]
    
    // Altezze barre dell'istogramma voti (da ½ stella a 5 stelle)
    let ratingBars: [CGFloat] = [8, 12, 18, 26, 38, 52, 74, 96, 84, 62]
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: LayoutInfo.spaceXL) {
                    
                    // 1. TOP HEADER BAR
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "movieclapper")
                                .foregroundColor(Color.theme.primaryCyan)
                            Text("Profilo Utente")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(Color.theme.textPrimary)
                        }
                        Spacer()
                        HStack(spacing: 14) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.theme.textSecondary)
                            Circle()
                                .fill(Color.theme.surfaceElevated)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "person.circle")
                                        .foregroundColor(Color.theme.primaryCyan)
                                )
                        }
                    }
                    
                    // 2. CARD BIO UTENTE (Matteo Visconti)
                    VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                        HStack(spacing: LayoutInfo.spaceMD) {
                            ZStack(alignment: .bottomTrailing) {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.theme.surfaceElevated)
                                    .frame(width: 68, height: 68)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(Color.theme.primaryCyan)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color.theme.primaryCyan, lineWidth: 1.5)
                                    )
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.theme.primaryCyan)
                                    .background(Circle().fill(Color.theme.background))
                                    .offset(x: 4, y: 4)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Matteo Visconti")
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(Color.theme.textPrimary)
                                
                                Text("@cinefilo_doc")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color.theme.primaryCyan)
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("Milano, IT  •")
                                    Image(systemName: "calendar")
                                    Text("Membro dal 2021")
                                }
                                .font(.system(size: 11))
                                .foregroundColor(Color.theme.textSecondary)
                            }
                        }
                        
                        Text("Cinefilo, appassionato di Sci-Fi d'autore e Denis Villeneuve. Recensisco ogni film che vedo con occhio critico e passione.")
                            .font(.system(size: 13))
                            .foregroundColor(Color.theme.textSecondary)
                            .lineSpacing(3)
                        
                        HStack(spacing: 8) {
                            Button(action: {}) {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil")
                                    Text("Modifica Profilo")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.theme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(Color.theme.surfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "shareplay")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.theme.textPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.theme.surfaceElevated)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.theme.textPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(Color.theme.surfaceElevated)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                    .padding(LayoutInfo.spaceLG)
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                    )
                    
                    // 3. BARRA STATISTICHE A 5 COLONNE
                    HStack(spacing: 4) {
                        statColumn(value: "142", label: "FILM\nVISTI", isHighlighted: false)
                        statColumn(value: "38", label: "NEL 2024", isHighlighted: true)
                        statColumn(value: "42", label: "WATCHLIST", isHighlighted: false)
                        statColumn(value: "1.2k", label: "FOLLOWER", isHighlighted: false)
                        statColumn(value: "480", label: "FOLLOWING", isHighlighted: false)
                    }
                    .padding(8)
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                    )
                    
                    // 4. I 4 FILM PREFERITI
                    VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "heart")
                                    .foregroundColor(Color.theme.primaryCyan)
                                Text("I 4 Film Preferiti")
                                    .font(.system(size: 17, weight: .bold, design: .serif))
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                            Spacer()
                            HStack(spacing: 4) {
                                Text("Modifica")
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.theme.primaryCyan)
                        }
                        
                        HStack(spacing: 8) {
                            ForEach(favoriteMovies, id: \.title) { fav in
                                VStack(alignment: .leading, spacing: 4) {
                                    ZStack(alignment: .topTrailing) {
                                        Color.theme.surfaceElevated
                                            .overlay(
                                                Image(fav.poster)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            )
                                            .posterStyle()
                                        
                                        Text("5.0 ★")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundColor(Color.theme.primaryCyan)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(Color.theme.background.opacity(0.85))
                                            .clipShape(RoundedRectangle(cornerRadius: 3))
                                            .padding(4)
                                    }
                                    
                                    Text(fav.title)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(Color.theme.textPrimary)
                                        .lineLimit(1)
                                    
                                    Text(fav.year)
                                        .font(.system(size: 10))
                                        .monospacedDigit()
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                    // 5. DISTRIBUZIONE VOTI (Grafico a barre)
                    VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(Color.theme.primaryCyan)
                                Text("Distribuzione Voti")
                                    .font(.system(size: 16, weight: .bold, design: .serif))
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                            Spacer()
                            HStack(spacing: 2) {
                                Text("Media:")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.theme.textSecondary)
                                Text("4.1 ★")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color.theme.primaryCyan)
                            }
                        }
                        
                        // Istogramma
                        HStack(alignment: .bottom, spacing: 6) {
                            ForEach(0..<ratingBars.count, id: \.self) { i in
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(i >= 7 ? Color.theme.primaryCyan : Color.theme.surfaceElevated)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: ratingBars[i])
                            }
                        }
                        .frame(height: 100)
                        .padding(.top, 8)
                        
                        HStack {
                            Text("½ ★")
                            Spacer()
                            Text("2½ ★")
                            Spacer()
                            Text("5 ★")
                        }
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.theme.textSecondary)
                    }
                    .padding(LayoutInfo.spaceLG)
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                    )
                    
                    // 6. TABS DIARIO / RECENSIONI / LISTE / STATS
                    HStack(spacing: 0) {
                        ForEach(profileTabs, id: \.self) { tab in
                            let isSelected = (selectedTab == tab)
                            Button(action: { selectedTab = tab }) {
                                Text(tab)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(isSelected ? Color.theme.primaryCyan : Color.theme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 36)
                                    .background(isSelected ? Color.theme.surfaceElevated : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                    .padding(4)
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    
                    // 7. VOCI DEL DIARIO
                    VStack(spacing: LayoutInfo.spaceMD) {
                        ProfileDiaryRow(
                            title: "Oppenheimer",
                            year: "2023",
                            dateText: "Ieri",
                            quote: "“Montaggio sonoro impressionante e prova monumentale di Cillian Murphy. Il terzo atto n...”",
                            likes: 24,
                            comments: 6,
                            tag: "Riveduto",
                            posterName: "oppenheimer_poster"
                        )
                        
                        ProfileDiaryRow(
                            title: "Past Lives",
                            year: "2023",
                            dateText: "12 Mag",
                            quote: "“Uno dei migliori drammi romantici del decennio. Il concetto di 'In-Yun' trattato con una delicatez...”",
                            likes: 48,
                            comments: 14,
                            tag: "Sala",
                            posterName: "pastlives_poster"
                        )
                        
                        ProfileDiaryRow(
                            title: "Dune: Parte Due",
                            year: "2024",
                            dateText: "4 Mag",
                            quote: "“Cinema di proporzioni bibliche. La sequenza del verme delle sabbie e la fotografia monocroma s...”",
                            likes: 31,
                            comments: 9,
                            tag: "IMAX",
                            posterName: "dune_backdrop"
                        )
                    }
                    
                    Button(action: {}) {
                        HStack(spacing: 6) {
                            Text("Vedi Tutto il Diario (142 Film)")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.theme.primaryCyan)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
                .padding(.horizontal, LayoutInfo.gutterMobile)
                .padding(.top, LayoutInfo.spaceSM)
                .padding(.bottom, 100)
            }
        }
    }
    
    @ViewBuilder
    private func statColumn(value: String, label: String, isHighlighted: Bool) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .monospacedDigit()
                .foregroundColor(isHighlighted ? Color.theme.primaryCyan : Color.theme.textPrimary)
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(isHighlighted ? Color.theme.primaryCyan : Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isHighlighted ? Color.theme.surfaceElevated : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct ProfileDiaryRow: View {
    let title: String
    let year: String
    let dateText: String
    let quote: String
    let likes: Int
    let comments: Int
    let tag: String
    let posterName: String
    
    var body: some View {
        HStack(alignment: .top, spacing: LayoutInfo.spaceMD) {
            Color.theme.surfaceElevated
                .overlay(
                    Image(posterName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
                .posterStyle()
                .frame(width: 64, height: 96)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(Color.theme.textPrimary)
                    Spacer()
                    Text(dateText)
                        .font(.system(size: 11))
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                HStack(spacing: 6) {
                    Text("\(year)  •")
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.textSecondary)
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.theme.tertiaryGlow)
                        }
                    }
                }
                
                Text(quote)
                    .font(.system(size: 13))
                    .foregroundColor(Color.theme.textSecondary)
                    .lineLimit(2)
                
                HStack(spacing: 14) {
                    Label("\(likes)", systemImage: "heart")
                    Label("\(comments)", systemImage: "bubble.right")
                    Spacer()
                    Text(tag)
                        .font(.system(size: 11, weight: .medium))
                }
                .font(.system(size: 11))
                .foregroundColor(Color.theme.textSecondary)
                .padding(.top, 2)
            }
        }
        .padding(12)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
        )
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}
