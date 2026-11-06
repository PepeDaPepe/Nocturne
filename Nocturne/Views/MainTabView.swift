import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var showQuickLog: Bool = false
    @State private var tabResetID: UUID = UUID() // Permette di tornare indietro toccando di nuovo l'icona del Tab
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // CONTENUTO DELLE PAGINE
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                        .id(tabResetID)
                case 1:
                    SearchView()
                        .id(tabResetID)
                case 3:
                    WatchlistView()
                        .id(tabResetID)
                case 4:
                    ProfileView()
                        .id(tabResetID)
                default:
                    HomeView()
                        .id(tabResetID)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // CUSTOM TAB BAR
            NocturneTabBar(
                selectedTab: $selectedTab,
                onReselectTab: {
                    // Se clicchi sul tab già aperto (es. Home mentre sei nei dettagli), torna alla radice
                    tabResetID = UUID()
                },
                onLogTap: {
                    showQuickLog = true
                }
            )
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showQuickLog) {
            LogMovieSheet(movie: nil)
        }
    }
}

struct NocturneTabBar: View {
    @Binding var selectedTab: Int
    var onReselectTab: () -> Void
    var onLogTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.theme.borderHairline)
                .frame(height: 0.5)
            
            HStack(spacing: 0) {
                tabButton(index: 0, icon: "movieclapper", activeIcon: "movieclapper.fill", title: "Home")
                tabButton(index: 1, icon: "magnifyingglass", activeIcon: "magnifyingglass", title: "Cerca")
                logCenterButton()
                tabButton(index: 3, icon: "bookmark", activeIcon: "bookmark.fill", title: "Watchlist")
                tabButton(index: 4, icon: "person.crop.circle", activeIcon: "person.crop.circle.fill", title: "Profilo")
            }
            .padding(.top, 8)
            .padding(.bottom, 6)
            .frame(height: 60)
        }
        .background(
            ZStack {
                Color.theme.background.opacity(0.78)
                Rectangle().fill(.ultraThinMaterial)
            }
            .ignoresSafeArea(edges: .bottom)
        )
    }
    
    @ViewBuilder
    private func tabButton(index: Int, icon: String, activeIcon: String, title: String) -> some View {
        let isSelected = (selectedTab == index)
        
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                if selectedTab == index {
                    onReselectTab()
                } else {
                    selectedTab = index
                }
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? activeIcon : icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Color.theme.primaryCyan : Color.theme.textTertiary)
                
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? Color.theme.primaryCyan : Color.theme.textTertiary)
                
                Circle()
                    .fill(isSelected ? Color.theme.primaryCyan : Color.clear)
                    .frame(width: 4, height: 4)
                    .shadow(color: isSelected ? Color.theme.primaryCyan.opacity(0.8) : .clear, radius: 3)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func logCenterButton() -> some View {
        Button(action: {
            onLogTap()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.theme.surfaceElevated)
                        .frame(width: 34, height: 34)
                        .overlay(
                            Circle()
                                .stroke(Color.theme.primaryCyan.opacity(0.4), lineWidth: 0.5)
                        )
                    
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.theme.primaryCyan)
                }
                
                Text("Log")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.theme.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
