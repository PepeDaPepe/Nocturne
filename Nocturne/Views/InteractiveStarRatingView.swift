import SwiftUI

struct InteractiveStarRatingView: View {
    @Binding var rating: Double // Valore da 0.0 a 5.0 (step di 0.5)
    var starSize: CGFloat = 28
    
    private let unselectedColor = Color(hex: "1E293B")
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { index in
                starImage(for: Double(index))
                    .font(.system(size: starSize, weight: .semibold))
                    .foregroundColor(rating >= Double(index) - 0.5 ? Color.theme.tertiaryGlow : unselectedColor)
                    .shadow(
                        color: rating >= Double(index) - 0.5 ? Color.theme.tertiaryGlow.opacity(0.4) : .clear,
                        radius: 6
                    )
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    updateRating(at: value.location.x)
                }
        )
    }
    
    private func starImage(for starIndex: Double) -> Image {
        if rating >= starIndex {
            return Image(systemName: "star.fill")
        } else if rating >= starIndex - 0.5 {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star.fill")
        }
    }
    
    private func updateRating(at locationX: CGFloat) {
        let totalWidth = (starSize * 5) + (8 * 4)
        let clampedX = max(0, min(locationX, totalWidth))
        let rawRating = (clampedX / totalWidth) * 5.0
        // Arrotonda al mezzo punto più vicino (0.5, 1.0, 1.5, ..., 5.0)
        let steppedRating = (rawRating * 2).rounded() / 2
        
        if steppedRating != rating {
            rating = steppedRating
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

#Preview {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        InteractiveStarRatingView(rating: .constant(4.5))
    }
    .preferredColorScheme(.dark)
}
