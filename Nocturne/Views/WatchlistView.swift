import SwiftUI
import SwiftData

struct WatchlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedMovieEntry.addedDate, order: .reverse) private var allEntries: [SavedMovieEntry]
    
    @State private var selectedSegment: Int = 0
    @State private var filterText: String = ""
    
    var filteredEntries: [SavedMovieEntry] {
        allEntries.filter { entry in
            let matchesTab = (selectedSegment == 0) ? entry.isInWatchlist : entry.isWatched
            let matchesSearch = filterText.trimmingCharacters(in: .whitespaces).isEmpty
                || entry.title.localizedCaseInsensitiveContains(filterText)
                || entry.director.localizedCaseInsensitiveContains(filterText)
            return matchesTab && matchesSearch
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LayoutInfo.spaceLG) {
                        
                        // 1. HEADER WATCHLIST
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "film")
                                    .foregroundColor(Color.theme.primaryCyan)
                                Text("WATCHLIST")
                                    .font(.system(size: 18, weight: .bold, design: .serif))
                                    .tracking(1.0)
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                            Spacer()
                            HStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color.theme.textSecondary)
                                Circle()
                                    .fill(Color.theme.primaryCyan)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "person")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color.theme.background)
                                    )
                            }
                        }
                        
                        // 2. SELETTORE "Da Vedere" / "Film Visti"
                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    selectedSegment = 0
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "bookmark")
                                    Text("Da Vedere")
                                }
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(selectedSegment == 0 ? Color.theme.primaryCyan : Color.theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(selectedSegment == 0 ? Color.theme.surfaceElevated : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                    selectedSegment = 1
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle")
                                    Text("Film Visti")
                                }
                                .font(.system(size: 14, weight: .bold, design: .serif))
                                .foregroundColor(selectedSegment == 1 ? Color.theme.primaryCyan : Color.theme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(selectedSegment == 1 ? Color.theme.surfaceElevated : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                        .padding(4)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        
                        // 3. CONTATORE SWIFTDATA DINAMICO + ORDINA RECENTI
                        HStack {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color.theme.primaryCyan)
                                    .frame(width: 8, height: 8)
                                Text("\(filteredEntries.count) film salvati in SwiftData")
                                    .font(.system(size: 13, weight: .bold, design: .serif))
                                    .monospacedDigit()
                                    .foregroundColor(Color.theme.textPrimary)
                            }
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.arrow.down")
                                Text("RECENTI")
                            }
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.theme.primaryCyan)
                        }
                        
                        // 4. BARRA DI FILTRO
                        HStack(spacing: 10) {
                            Image(systemName: "line.3.horizontal.decrease")
                                .foregroundColor(Color.theme.textSecondary)
                            TextField("Filtra per titolo, regista o tag...", text: $filterText)
                                .font(.system(size: 14))
                                .foregroundColor(Color.theme.textPrimary)
                        }
                        .padding(12)
                        .background(Color.theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
                        )
                        
                        // 5. LISTA DELLE CARD SWIFTDATA
                        VStack(spacing: LayoutInfo.spaceMD) {
                            ForEach(filteredEntries) { entry in
                                WatchlistCardRow(
                                    entry: entry,
                                    onToggleWatched: {
                                        withAnimation {
                                            entry.isWatched.toggle()
                                            entry.isInWatchlist = !entry.isWatched
                                            if entry.isWatched && entry.watchedDate == nil {
                                                entry.watchedDate = Date()
                                                if entry.userRating == 0 { entry.userRating = 4.5 }
                                            }
                                            try? modelContext.save()
                                        }
                                    },
                                    onDelete: {
                                        withAnimation {
                                            modelContext.delete(entry)
                                            try? modelContext.save()
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, LayoutInfo.gutterMobile)
                    .padding(.top, LayoutInfo.spaceSM)
                    .padding(.bottom, 100)
                }
            }
            
        }
    }
}
struct WatchlistCardRow: View {
    let entry: SavedMovieEntry
    var onToggleWatched: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: LayoutInfo.spaceMD) {
            NavigationLink(destination: MovieDetailView(movie: entry.toMovie())) {
                ZStack(alignment: .topLeading) {
                    MovieImageView(source: entry.posterName)
                        .posterStyle()
                        .frame(width: 82, height: 123)
                    
                    Text("4K HDR")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color.theme.primaryCyan)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.theme.background.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(4)
                }
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(entry.title)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundColor(Color.theme.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text(entry.year)
                        .font(.system(size: 12, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(Color.theme.textSecondary)
                }
                
                Text("\(entry.director) • Cinema")
                    .font(.system(size: 13))
                    .foregroundColor(Color.theme.textSecondary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                    Text(entry.addedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12))
                }
                .foregroundColor(Color.theme.textSecondary)
                .padding(.top, 2)
                
                HStack(spacing: 8) {
                    Button(action: onToggleWatched) {
                        HStack(spacing: 6) {
                            Image(systemName: entry.isWatched ? "checkmark.circle.fill" : "checkmark.circle")
                            Text(entry.isWatched ? "Già Visto" : "Segna Visto")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.theme.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color.theme.primaryCyan)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                            .foregroundColor(Color.theme.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(Color.theme.surfaceElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(12)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.theme.borderHairline, lineWidth: 0.5)
        )
    }
}

#Preview {
    WatchlistView()
        .modelContainer(for: SavedMovieEntry.self, inMemory: true)
        .preferredColorScheme(.dark)
}
