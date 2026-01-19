import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    @State private var selectedTab = 0
    @Namespace private var animation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                FeedView(dataManager: dataManager)
                    .tag(0)
                
                StatsView(dataManager: dataManager)
                    .tag(1)
                
                CalendarView(dataManager: dataManager)
                    .tag(2)
                
                SettingsView(dataManager: dataManager)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            customTabBar
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(showOnboarding: $showOnboarding)
        }
        .onAppear {
            if !hasSeenOnboarding {
                showOnboarding = true
                hasSeenOnboarding = true
            }
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab.rawValue,
                    animation: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab.rawValue
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: Color.black.opacity(0.08), radius: 20, y: -5)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }
}

enum TabItem: Int, CaseIterable {
    case feed = 0
    case stats = 1
    case calendar = 2
    case settings = 3
    
    var icon: String {
        switch self {
        case .feed: return "camera.viewfinder"
        case .stats: return "chart.bar.fill"
        case .calendar: return "calendar"
        case .settings: return "gearshape.fill"
        }
    }
    
    var title: String {
        switch self {
        case .feed: return "Feed"
        case .stats: return "Stats"
        case .calendar: return "Archive"
        case .settings: return "Settings"
        }
    }
}

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(AppTheme.headerGradient)
                            .frame(width: 48, height: 32)
                            .matchedGeometryEffect(id: "TAB_BG", in: animation)
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSelected ? .white : Color.adaptiveSecondaryText)
                }
                .frame(height: 32)
                
                Text(tab.title)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? AppTheme.accent : Color.adaptiveSecondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
