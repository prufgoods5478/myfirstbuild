
import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "camera.viewfinder",
            title: "Capture Traces",
            description: "Take photos of objects that accompany your actions",
            color: Color(hex: "#4ECDC4") ?? .teal
        ),
        OnboardingPage(
            icon: "tag.fill",
            title: "Add Tags",
            description: "Categorize your traces with simple icons",
            color: Color(hex: "#FF6B6B") ?? .red
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "Track Your Day",
            description: "View statistics and history of your traces",
            color: Color(hex: "#FFE66D") ?? .yellow
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.adaptiveBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Indicators
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? pages[currentPage].color : Color.adaptiveSecondaryText.opacity(0.2))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 40)
                
                // Button
                Button {
                    if currentPage < pages.count - 1 {
                        withAnimation(.spring(response: 0.4)) {
                            currentPage += 1
                        }
                    } else {
                        withAnimation(.spring(response: 0.5)) {
                            showOnboarding = false
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        
                        Image(systemName: currentPage < pages.count - 1 ? "chevron.right" : "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [pages[currentPage].color, pages[currentPage].color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: pages[currentPage].color.opacity(0.4), radius: 16, y: 8)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
                
                // Skip
                if currentPage < pages.count - 1 {
                    Button {
                        withAnimation(.spring(response: 0.5)) {
                            showOnboarding = false
                        }
                    } label: {
                        Text("Skip")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Color.adaptiveSecondaryText)
                    }
                    .padding(.bottom, 30)
                } else {
                    Spacer()
                        .frame(height: 50)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}


struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}


struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                // Background circles
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 220, height: 220)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 160, height: 160)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 70, weight: .light))
                    .foregroundColor(page.color)
                    .scaleEffect(isAnimating ? 1 : 0.5)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: isAnimating)
            
            // Text
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.adaptivePrimaryText)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                
                Text(page.description)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(Color.adaptiveSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
            }
            .animation(.spring(response: 0.6).delay(0.2), value: isAnimating)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
