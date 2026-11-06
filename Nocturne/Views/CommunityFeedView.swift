import SwiftUI
import SwiftData

struct CommunityFeedView: View {
    @Query(sort: \SavedMovieEntry.watchedDate, order: .reverse) private var savedEntries: [SavedMovieEntry]
    @AppStorage("profile_name") private var profileName: String = "Il Tuo Profilo"
    
    private var loggedReviews: [SavedMovieEntry] {
        savedEntries.filter { $0.isWatched }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Attività & Recensioni")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text(loggedReviews.isEmpty ? "Registra un film con + Log per vederlo qui" : "I tuoi ultimi film recensiti")
                        .font(.system(size: 13))
                        .foregroundColor(Color.theme.textSecondary)
                }
                Spacer()
            }
            
            if loggedReviews.isEmpty {
                HStack {
                    Image(systemName: "text.bubble")
                        .foregroundColor(Color.theme.primaryCyan)
                    Text("Nessuna recensione ancora registrata. Tocca + Log in basso per scrivere la prima!")
                        .font(.system(size: 13))
                        .foregroundColor(Color.theme.textSecondary)
                }
                .padding(LayoutInfo.spaceLG)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(spacing: LayoutInfo.spaceMD) {
                    ForEach(loggedReviews.prefix(5)) { entry in
                        NavigationLink(destination: MovieDetailView(movie: entry.toMovie())) {
                            UserLoggedReviewCard(entry: entry, userName: profileName)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, LayoutInfo.gutterMobile)
    }
}

struct UserLoggedReviewCard: View {
    let entry: SavedMovieEntry
    let userName: String
    
    var body: some View {
        HStack(alignment: .top, spacing: LayoutInfo.spaceMD) {
            MovieImageView(source: entry.posterName)
                .posterStyle()
                .frame(width: 48, height: 72)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(userName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.theme.textPrimary)
                    Spacer()
                    if let date = entry.watchedDate {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 11))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
                
                HStack(spacing: 6) {
                    Text(entry.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.theme.primaryCyan)
                        .lineLimit(1)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<Int(entry.userRating.rounded()), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.theme.tertiaryGlow)
                        }
                    }
                }
                
                if !entry.reviewText.isEmpty {
                    Text("“\(entry.reviewText)”")
                        .font(.system(size: 13))
                        .foregroundColor(Color.theme.textSecondary)
                        .lineLimit(3)
                }
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
}
