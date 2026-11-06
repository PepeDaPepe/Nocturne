import SwiftUI

struct GenreFilterView: View {
    let genres: [TMDBGenre]
    let selectedGenre: TMDBGenre?
    var onSelectGenre: (TMDBGenre?) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceSM) {
            Text("ESPLORA GENERI TMDB")
                .font(.system(size: 10, weight: .bold))
                .tracking(0.8)
                .foregroundColor(Color.theme.textSecondary)
                .padding(.horizontal, LayoutInfo.gutterMobile)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LayoutInfo.spaceSM) {
                    // Pillola "Tutti" per resettare il filtro
                    genrePill(
                        title: "Tutti i Generi",
                        icon: "sparkles",
                        isSelected: selectedGenre == nil
                    ) {
                        onSelectGenre(nil)
                    }
                    
                    // Tutti i generi ufficiali scaricati da TMDB
                    ForEach(genres) { genre in
                        genrePill(
                            title: genre.name,
                            icon: iconForGenre(genre.name),
                            isSelected: selectedGenre?.id == genre.id
                        ) {
                            onSelectGenre(genre)
                        }
                    }
                }
                .padding(.horizontal, LayoutInfo.gutterMobile)
            }
        }
    }
    
    @ViewBuilder
    private func genrePill(title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 14)
            .frame(height: 32)
            .foregroundColor(isSelected ? Color.theme.primaryCyan : Color.theme.textSecondary)
            .background(isSelected ? Color.theme.primaryCyan.opacity(0.15) : Color.theme.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.theme.borderActive : Color.theme.borderHairline, lineWidth: 0.5)
            )
        }
    }
    
    private func iconForGenre(_ name: String) -> String {
        let lower = name.lowercased()
        if lower.contains("fantascienza") { return "sparkles" }
        if lower.contains("azione") || lower.contains("avventura") { return "flame" }
        if lower.contains("horror") || lower.contains("thriller") { return "eye" }
        if lower.contains("commedia") { return "face.smiling" }
        if lower.contains("animazione") { return "paintbrush" }
        if lower.contains("romance") || lower.contains("dramma") { return "heart" }
        if lower.contains("crime") || lower.contains("mistero") { return "magnifyingglass" }
        return "film"
    }
}
