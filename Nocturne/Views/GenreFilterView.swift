import SwiftUI

struct GenreItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
}

struct GenreFilterView: View {
    // Genere attualmente selezionato
    @State private var selectedGenre: String = "Fantascienza"
    
    let genres: [GenreItem] = [
        GenreItem(name: "Fantascienza", icon: "sparkles"),
        GenreItem(name: "Thriller Noir", icon: "eye"),
        GenreItem(name: "Dramma", icon: "theatermasks"),
        GenreItem(name: "Horror", icon: "moon.stars"),
        GenreItem(name: "Animazione", icon: "film.stack")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceSM) {
            // Titolo sezione in stile caption-caps
            Text("GENERI DI TENDENZA")
                .font(.system(size: 10, weight: .bold))
                .tracking(0.8)
                .foregroundColor(Color.theme.textSecondary)
                .padding(.horizontal, LayoutInfo.gutterMobile)
            
            // Carosello orizzontale delle pillole
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LayoutInfo.spaceSM) {
                    ForEach(genres) { genre in
                        let isSelected = (selectedGenre == genre.name)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedGenre = genre.name
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: genre.icon)
                                    .font(.system(size: 11, weight: .semibold))
                                Text(genre.name)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 30)
                            .foregroundColor(isSelected ? Color.theme.primaryCyan : Color.theme.textSecondary)
                            .background(
                                isSelected
                                ? Color.theme.primaryCyan.opacity(0.15)
                                : Color.theme.surface
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        isSelected ? Color.theme.primaryCyan : Color.theme.borderHairline,
                                        lineWidth: 0.5
                                    )
                            )
                        }
                    }
                }
                .padding(.horizontal, LayoutInfo.gutterMobile)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        GenreFilterView()
    }
    .preferredColorScheme(.dark)
}
