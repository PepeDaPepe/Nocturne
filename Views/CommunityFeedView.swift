import SwiftUI

struct CommunityReview: Identifiable {
    let id = UUID()
    let userName: String
    let userInitials: String
    let timeAgo: String
    let movieTitle: String
    let rating: Int
    let reviewText: String
    let likesCount: Int
    let commentsCount: Int
}

struct CommunityFeedView: View {
    let reviews: [CommunityReview] = [
        CommunityReview(
            userName: "Elena B.",
            userInitials: "EB",
            timeAgo: "2h fa",
            movieTitle: "Dune: Parte Due",
            rating: 5,
            reviewText: "“Capolavoro visivo e sonoro. Il montaggio nel terzo atto è puro ritmo operistico. La visione IMAX è...”",
            likesCount: 48,
            commentsCount: 12
        ),
        CommunityReview(
            userName: "Marco Rossi",
            userInitials: "MR",
            timeAgo: "4h fa",
            movieTitle: "Past Lives",
            rating: 5,
            reviewText: "“L'In-Yun spiegato con una delicatezza disarmante. Quegli ultimi due minuti di camminata silenziosa...”",
            likesCount: 31,
            commentsCount: 5
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
            
            // Intestazione
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Attività Community")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text("Dai cinefili che segui")
                        .font(.system(size: 13))
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    // Azione Feed Completo
                }) {
                    HStack(spacing: 4) {
                        Text("Feed completo")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.theme.primaryCyan)
                }
            }
            
            // Lista verticale delle card recensione
            VStack(spacing: LayoutInfo.spaceMD) {
                ForEach(reviews) { review in
                    ReviewCardView(review: review)
                }
            }
        }
        .padding(.horizontal, LayoutInfo.gutterMobile)
    }
}

struct ReviewCardView: View {
    let review: CommunityReview
    @State private var isLiked: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: LayoutInfo.spaceMD) {
            
            // Avatar Utente
            Circle()
                .fill(Color.theme.surfaceElevated)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(review.userInitials)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.theme.primaryCyan)
                )
                .overlay(
                    Circle()
                        .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                )
            
            // Contenuto Recensione
            VStack(alignment: .leading, spacing: 6) {
                
                // Nome utente e timestamp
                HStack {
                    Text(review.userName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Spacer()
                    
                    Text(review.timeAgo)
                        .font(.system(size: 12))
                        .monospacedDigit()
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                // Film recensito + Stelline con bagliore (Tertiary Glow)
                HStack(spacing: 6) {
                    Text(review.movieTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.theme.primaryCyan)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<review.rating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.theme.tertiaryGlow)
                                .shadow(color: Color.theme.tertiaryGlow.opacity(0.4), radius: 6, x: 0, y: 0)
                        }
                    }
                }
                
                // Testo della recensione
                Text(review.reviewText)
                    .font(.system(size: 14))
                    .foregroundColor(Color.theme.textSecondary)
                    .lineSpacing(3)
                    .lineLimit(2)
                    .padding(.top, 2)
                
                // Bottoni Like e Commenti
                HStack(spacing: LayoutInfo.spaceLG) {
                    Button(action: {
                        isLiked.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? Color.theme.primaryCyan : Color.theme.textSecondary)
                            Text("\(review.likesCount + (isLiked ? 1 : 0))")
                                .monospacedDigit()
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        .font(.system(size: 12))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                        Text("\(review.commentsCount)")
                            .monospacedDigit()
                    }
                    .font(.system(size: 12))
                    .foregroundColor(Color.theme.textSecondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(LayoutInfo.spaceLG)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
        )
    }
}

#Preview {
    ZStack {
        Color.theme.background.ignoresSafeArea()
        CommunityFeedView()
    }
    .preferredColorScheme(.dark)
}
