import SwiftUI

struct MovieImageView: View {
    let source: String
    
    var body: some View {
        if source.hasPrefix("http"), let url = URL(string: source) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Color.theme.surfaceElevated
                        .overlay(
                            ProgressView()
                                .tint(Color.theme.primaryCyan)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderView
                @unknown default:
                    placeholderView
                }
            }
        } else if !source.isEmpty, let uiImage = UIImage(named: source) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        Color.theme.surfaceElevated
            .overlay(
                Image(systemName: "film")
                    .font(.system(size: 22))
                    .foregroundColor(Color.theme.textTertiary)
            )
    }
}
