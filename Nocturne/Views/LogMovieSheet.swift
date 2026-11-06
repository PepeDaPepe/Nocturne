import SwiftUI
import SwiftData

struct LogMovieSheet: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var savedEntries: [SavedMovieEntry]
    
    @State private var userRating: Double = 4.5
    @State private var isLiked: Bool = true
    @State private var isRewatch: Bool = false
    @State private var reviewText: String = ""
    @State private var hasSpoilers: Bool = false
    @State private var shareInCineClub: Bool = true
    @State private var watchedDate: Date = Date()
    @State private var selectedTag: String = "IMAX"
    
    var ratingDescription: String {
        switch userRating {
        case 4.5...5.0: return "Capolavoro epico"
        case 4.0..<4.5: return "Eccellente"
        case 3.0..<4.0: return "Buon film"
        case 2.0..<3.0: return "Mediocre"
        default: return "Deludente"
        }
    }
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. TOP BAR ("Annulla" - "Registra Visione" - "✓ Salva")
                HStack {
                    Button("Annulla") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Capsule()
                            .fill(Color.theme.textTertiary)
                            .frame(width: 36, height: 4)
                        Text("Registra Visione")
                            .font(.system(size: 17, weight: .bold, design: .serif))
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    
                    Spacer()
                    
                    Button(action: { saveLogAndDismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                            Text("Salva")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(Color.theme.background)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.theme.primaryCyan)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, LayoutInfo.gutterMobile)
                .padding(.vertical, 12)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LayoutInfo.spaceLG) {
                        
                        // 2. CARD RIEPILOGO FILM
                        HStack(spacing: LayoutInfo.spaceMD) {
                            MovieImageView(source: movie.posterName)
                                .posterStyle()
                                .frame(width: 68, height: 102)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 6) {
                                    Text(movie.year)
                                        .font(.system(size: 11, weight: .bold))
                                        .monospacedDigit()
                                        .foregroundColor(Color.theme.primaryCyan)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.theme.primaryCyan.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                    
                                    Text("• \(movie.runtime / 60)h \(movie.runtime % 60)m")
                                        .font(.system(size: 12, weight: .medium))
                                        .monospacedDigit()
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                
                                Text(movie.title)
                                    .font(.system(size: 20, weight: .bold, design: .serif))
                                    .foregroundColor(Color.theme.textPrimary)
                                
                                Text(movie.director)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.theme.textSecondary)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.system(size: 11))
                                    Text("4K Laser IMAX • Formato 1.43:1")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(Color.theme.primaryCyan)
                                .padding(.top, 2)
                            }
                            Spacer()
                        }
                        .padding(LayoutInfo.spaceMD)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                        
                        // 3. CARD VOTO PERSONALE + STELLE + MI PIACE
                        VStack(spacing: LayoutInfo.spaceMD) {
                            HStack {
                                Text("VOTO PERSONALE")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(0.8)
                                    .foregroundColor(Color.theme.textSecondary)
                                
                                Spacer()
                                
                                Button(action: { isLiked.toggle() }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: isLiked ? "heart.fill" : "heart")
                                        Text("Mi Piace")
                                    }
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color.theme.primaryCyan)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.theme.primaryCyan.opacity(0.12))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.theme.borderActive, lineWidth: 0.5)
                                    )
                                }
                            }
                            
                            InteractiveStarRatingView(rating: $userRating, starSize: 34)
                                .padding(.vertical, 4)
                            
                            HStack(spacing: 10) {
                                HStack(spacing: 2) {
                                    Text(String(format: "%.1f", userRating))
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color.theme.primaryCyan)
                                    Text("/ 5.0")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                .monospacedDigit()
                                
                                Text(ratingDescription)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.theme.textSecondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.theme.surfaceElevated)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(LayoutInfo.spaceLG)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                        
                        // 4. DATA DI VISIONE
                        HStack(spacing: LayoutInfo.spaceMD) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.theme.surfaceElevated)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "calendar")
                                        .foregroundColor(Color.theme.primaryCyan)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Data di Visione")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.theme.textSecondary)
                                DatePicker("", selection: $watchedDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .tint(Color.theme.primaryCyan)
                            }
                            Spacer()
                        }
                        .padding(LayoutInfo.spaceMD)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                        
                        // 5. SWITCH PRIMA VISIONE / REWATCH
                        HStack(spacing: 0) {
                            Button(action: { isRewatch = false }) {
                                Text("Prima Visione")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(!isRewatch ? Color.theme.primaryCyan : Color.theme.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(!isRewatch ? Color.theme.surfaceElevated : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            
                            Button(action: { isRewatch = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Rewatch (2ª)")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(isRewatch ? Color.theme.primaryCyan : Color.theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(isRewatch ? Color.theme.surfaceElevated : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                        .padding(4)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                        
                        // 6. PILLOLE TAGS
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                tagPill(icon: "film", text: "Cinema Arcadia", tagValue: "Sala")
                                tagPill(icon: "tv", text: "Sala Energia IMAX", tagValue: "IMAX")
                                tagPill(icon: "arrow.counterclockwise", text: "Riveduto a casa", tagValue: "Riveduto")
                            }
                        }
                        
                        // 7. DIARIO & RECENSIONE + SPOILER TOGGLE
                        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                            HStack {
                                Label("Diario & Recensione", systemImage: "text.alignleft")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color.theme.textPrimary)
                                Spacer()
                                Text("Markdown Supportato")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if reviewText.isEmpty {
                                    Text("Scrivi la tua recensione su \(movie.title)...")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.theme.textTertiary)
                                        .padding(14)
                                }
                                TextEditor(text: $reviewText)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.theme.textPrimary)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 110)
                                    .padding(8)
                            }
                            .background(Color.theme.background)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            
                            HStack {
                                Image(systemName: "eye.slash")
                                    .foregroundColor(Color.theme.textSecondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Contiene Spoiler")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color.theme.textPrimary)
                                    Text("Nascondi il testo ai cinefili che non l'hanno visto")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                Spacer()
                                Toggle("", isOn: $hasSpoilers)
                                    .labelsHidden()
                                    .tint(Color.theme.primaryCyan)
                            }
                        }
                        .padding(LayoutInfo.spaceMD)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                        
                        // 8. CONDIVIDI NEL FEED + SWIFTDATA LOCALE
                        VStack(spacing: 14) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(Color.theme.primaryCyan)
                                    .frame(width: 28)
                                Text("Condividi nel feed CineClub")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.theme.textPrimary)
                                Spacer()
                                Toggle("", isOn: $shareInCineClub)
                                    .labelsHidden()
                                    .tint(Color.theme.primaryCyan)
                            }
                            
                            Divider().background(Color.theme.borderHairline)
                            
                            HStack {
                                Image(systemName: "cylinder.split.1x2")
                                    .foregroundColor(Color.theme.primaryCyan)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Salva in SwiftData locale")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color.theme.textPrimary)
                                    Text("Offline Instant Cache")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "checkmark.icloud.fill")
                                    .foregroundColor(Color.theme.primaryCyan)
                            }
                        }
                        .padding(LayoutInfo.spaceMD)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                        
                        // 9. BOTTONE FINALE "CONFERMA E ARCHIVIA"
                        Button(action: { saveLogAndDismiss() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "movieclapper")
                                Text("Conferma e Archivia")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.theme.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.theme.primaryCyan)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, LayoutInfo.gutterMobile)
                }
            }
        }
    }
    
    // Funzione che salva o aggiorna il film in SwiftData
    private func saveLogAndDismiss() {
        let finalReview = reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Visione registrata nel diario di Nocturne."
            : reviewText
        
        if let existing = savedEntries.first(where: { $0.title == movie.title }) {
            existing.isWatched = true
            existing.isInWatchlist = false
            existing.userRating = userRating
            existing.isLiked = isLiked
            existing.isRewatch = isRewatch
            existing.reviewText = finalReview
            existing.hasSpoilers = hasSpoilers
            existing.watchTag = selectedTag
            existing.watchedDate = watchedDate
        } else {
            let newEntry = SavedMovieEntry(
                movie: movie,
                isInWatchlist: false,
                isWatched: true,
                userRating: userRating,
                isLiked: isLiked,
                isRewatch: isRewatch,
                reviewText: finalReview,
                hasSpoilers: hasSpoilers,
                watchTag: selectedTag,
                watchedDate: watchedDate
            )
            modelContext.insert(newEntry)
        }
        try? modelContext.save()
        dismiss()
    }
    
    @ViewBuilder
    private func tagPill(icon: String, text: String, tagValue: String) -> some View {
        let isActive = (selectedTag == tagValue)
        Button(action: { selectedTag = tagValue }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                Text(text)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 12)
            .frame(height: 30)
            .foregroundColor(isActive ? Color.theme.primaryCyan : Color.theme.textSecondary)
            .background(isActive ? Color.theme.primaryCyan.opacity(0.15) : Color.theme.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isActive ? Color.theme.borderActive : Color.theme.borderHairline, lineWidth: 0.5)
            )
        }
    }
}

#Preview {
    LogMovieSheet(movie: Movie.featuredDune)
        .modelContainer(for: SavedMovieEntry.self, inMemory: true)
        .preferredColorScheme(.dark)
}
