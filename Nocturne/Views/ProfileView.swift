import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedMovieEntry.watchedDate, order: .reverse) private var allEntries: [SavedMovieEntry]
    
    // Dati del profilo personalizzabili dall'utente
    @AppStorage("profile_name") private var profileName: String = "Crea il tuo Profilo"
    @AppStorage("profile_handle") private var profileHandle: String = "@nuovo_cinefilo"
    @AppStorage("profile_location") private var profileLocation: String = "Italia"
    @AppStorage("profile_bio") private var profileBio: String = "Tocca 'Modifica Profilo' per inserire il tuo nome, il tuo @username e la tua biografia cinematografica."
    
    @State private var showEditProfile: Bool = false
    @State private var selectedTab: String = "Diario"
    let profileTabs = ["Diario", "Recensioni", "Watchlist"]
    
    // Calcoli dinamici da SwiftData
    private var watchedMovies: [SavedMovieEntry] {
        allEntries.filter { $0.isWatched }
    }
    
    private var watchlistedMovies: [SavedMovieEntry] {
        allEntries.filter { $0.isInWatchlist }
    }
    
    private var watchedThisYearCount: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return watchedMovies.filter { entry in
            guard let date = entry.watchedDate else { return false }
            return Calendar.current.component(.year, from: date) == currentYear
        }.count
    }
    
    private var favoriteMovies: [SavedMovieEntry] {
        let liked = watchedMovies.filter { $0.isLiked }
            .sorted { $0.userRating > $1.userRating }
        if !liked.isEmpty {
            return Array(liked.prefix(4))
        }
        return Array(watchedMovies.sorted { $0.userRating > $1.userRating }.prefix(4))
    }
    
    private var averageRating: Double {
        let rated = watchedMovies.filter { $0.userRating > 0 }
        guard !rated.isEmpty else { return 0.0 }
        let sum = rated.reduce(0.0) { $0 + $1.userRating }
        return sum / Double(rated.count)
    }
    
    // Calcola l'altezza delle 10 barre (da 0.5 a 5.0 stelle)
    private var ratingDistributionHeights: [CGFloat] {
        let buckets: [Double] = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]
        let counts = buckets.map { bucket in
            watchedMovies.filter { abs($0.userRating - bucket) < 0.25 }.count
        }
        let maxCount = max(counts.max() ?? 1, 1)
        return counts.map { count in
            max(8, CGFloat(count) / CGFloat(maxCount) * 90)
        }
    }
    
    var body: some View {
        NavigationStack {
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
                            Button(action: { showEditProfile = true }) {
                                Image(systemName: "gearshape")
                                    .foregroundColor(Color.theme.primaryCyan)
                            }
                        }
                        
                        // 2. CARD BIO UTENTE DINAMICA
                        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                            HStack(spacing: LayoutInfo.spaceMD) {
                                ZStack(alignment: .bottomTrailing) {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.theme.surfaceElevated)
                                        .frame(width: 68, height: 68)
                                        .overlay(
                                            Text(String(profileName.prefix(2)).uppercased())
                                                .font(.system(size: 22, weight: .bold, design: .serif))
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
                                    Text(profileName)
                                        .font(.system(size: 20, weight: .bold, design: .serif))
                                        .foregroundColor(Color.theme.textPrimary)
                                    
                                    Text(profileHandle)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color.theme.primaryCyan)
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "mappin.and.ellipse")
                                        Text("\(profileLocation) • CineClub")
                                    }
                                    .font(.system(size: 11))
                                    .foregroundColor(Color.theme.textSecondary)
                                }
                            }
                            
                            Text(profileBio)
                                .font(.system(size: 13))
                                .foregroundColor(Color.theme.textSecondary)
                                .lineSpacing(3)
                            
                            Button(action: { showEditProfile = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil")
                                    Text("Modifica Profilo")
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color.theme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(Color.theme.surfaceElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                        .padding(LayoutInfo.spaceLG)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                        
                        // 3. BARRA STATISTICHE REALI DA SWIFTDATA
                        HStack(spacing: 4) {
                            statColumn(value: "\(watchedMovies.count)", label: "FILM\nVISTI", isHighlighted: false)
                            statColumn(value: "\(watchedThisYearCount)", label: "QUEST'ANNO", isHighlighted: true)
                            statColumn(value: "\(watchlistedMovies.count)", label: "WATCHLIST", isHighlighted: false)
                            statColumn(value: "\(watchedMovies.filter { !$0.reviewText.isEmpty }.count)", label: "RECENSIONI", isHighlighted: false)
                        }
                        .padding(8)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                        
                        // 4. I TUOI FILM PREFERITI (Dinamici dai film a cui hai messo Mi Piace / Voto più alto)
                        VStack(alignment: .leading, spacing: LayoutInfo.spaceMD) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(Color.theme.primaryCyan)
                                    Text("I Tuoi Film Preferiti")
                                        .font(.system(size: 17, weight: .bold, design: .serif))
                                        .foregroundColor(Color.theme.textPrimary)
                                }
                                Spacer()
                            }
                            
                            if favoriteMovies.isEmpty {
                                Text("I film che registri con il cuore 'Mi Piace' e i voti più alti appariranno qui.")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.theme.textSecondary)
                                    .padding(LayoutInfo.spaceMD)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.theme.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            } else {
                                HStack(spacing: 8) {
                                    ForEach(favoriteMovies) { fav in
                                        NavigationLink(destination: MovieDetailView(movie: fav.toMovie())) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                ZStack(alignment: .topTrailing) {
                                                    MovieImageView(source: fav.posterName)
                                                        .posterStyle()
                                                    
                                                    Text(String(format: "%.1f ★", fav.userRating))
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
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        
                        // 5. DISTRIBUZIONE VOTI REALE
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
                                    Text(String(format: "%.1f ★", averageRating))
                                        .font(.system(size: 12, weight: .bold))
                                        .monospacedDigit()
                                        .foregroundColor(Color.theme.primaryCyan)
                                }
                            }
                            
                            let bars = ratingDistributionHeights
                            HStack(alignment: .bottom, spacing: 6) {
                                ForEach(0..<bars.count, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                                        .fill(i >= 7 ? Color.theme.primaryCyan : Color.theme.surfaceElevated)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: bars[i])
                                }
                            }
                            .frame(height: 95)
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
                        
                        // 6. TABS DIARIO / RECENSIONI / WATCHLIST
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
                        
                        // 7. LISTA REALE DEL DIARIO DA SWIFTDATA
                        let entriesToShow = (selectedTab == "Watchlist")
                            ? watchlistedMovies
                            : (selectedTab == "Recensioni" ? watchedMovies.filter { !$0.reviewText.isEmpty } : watchedMovies)
                        
                        if entriesToShow.isEmpty {
                            Text("Nessun film presente in '\(selectedTab)'. Usa il pulsante + Log in basso o aggiungi film dal catalogo TMDB!")
                                .font(.system(size: 13))
                                .foregroundColor(Color.theme.textSecondary)
                                .padding(LayoutInfo.spaceLG)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } else {
                            VStack(spacing: LayoutInfo.spaceMD) {
                                ForEach(entriesToShow) { entry in
                                    NavigationLink(destination: MovieDetailView(movie: entry.toMovie())) {
                                        ProfileDiaryRow(
                                            entry: entry,
                                            onDelete: {
                                                modelContext.delete(entry)
                                                try? modelContext.save()
                                            }
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, LayoutInfo.gutterMobile)
                    .padding(.top, LayoutInfo.spaceSM)
                    .padding(.bottom, 100)
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet(
                    name: $profileName,
                    handle: $profileHandle,
                    location: $profileLocation,
                    bio: $profileBio
                )
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

// MARK: - Riga del Diario collegata a SavedMovieEntry
struct ProfileDiaryRow: View {
    let entry: SavedMovieEntry
    var onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: LayoutInfo.spaceMD) {
            MovieImageView(source: entry.posterName)
                .posterStyle()
                .frame(width: 64, height: 96)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.title)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(Color.theme.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    if let date = entry.watchedDate {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 11))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
                
                HStack(spacing: 6) {
                    Text("\(entry.year) •")
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.textSecondary)
                    
                    if entry.userRating > 0 {
                        HStack(spacing: 2) {
                            ForEach(0..<Int(entry.userRating.rounded()), id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color.theme.tertiaryGlow)
                            }
                            Text(String(format: "%.1f", entry.userRating))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.theme.primaryCyan)
                        }
                    }
                    
                    if entry.isLiked {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.theme.primaryCyan)
                    }
                }
                
                if !entry.reviewText.isEmpty {
                    Text("“\(entry.reviewText)”")
                        .font(.system(size: 13))
                        .foregroundColor(Color.theme.textSecondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(entry.watchTag)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.theme.primaryCyan)
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(Color.theme.textTertiary)
                    }
                }
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

// MARK: - Finestra Modale Creazione / Modifica Profilo
struct EditProfileSheet: View {
    @Binding var name: String
    @Binding var handle: String
    @Binding var location: String
    @Binding var bio: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: LayoutInfo.spaceLG) {
                        profileField(title: "NOME VISUALIZZATO", text: $name, placeholder: "Es. Matteo Visconti")
                        profileField(title: "USERNAME (@)", text: $handle, placeholder: "Es. @cinefilo_doc")
                        profileField(title: "CITTÀ / PAESE", text: $location, placeholder: "Es. Milano, IT")
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("BIOGRAFIA CINEFILA")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(Color.theme.textSecondary)
                            
                            TextEditor(text: $bio)
                                .font(.system(size: 14))
                                .foregroundColor(Color.theme.textPrimary)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color.theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                                )
                        }
                    }
                    .padding(LayoutInfo.gutterMobile)
                }
            }
            .navigationTitle("Modifica Profilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.theme.primaryCyan)
                }
            }
        }
    }
    
    @ViewBuilder
    private func profileField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .tracking(0.8)
                .foregroundColor(Color.theme.textSecondary)
            
            TextField(placeholder, text: text)
                .font(.system(size: 15))
                .foregroundColor(Color.theme.textPrimary)
                .padding(12)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                )
        }
    }
}
