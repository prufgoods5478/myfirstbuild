
import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    let message: String
    
    init(message: String = "Загрузка...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Анимированные круги
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(AppTheme.accent.opacity(0.3))
                        .frame(width: 16, height: 16)
                        .offset(x: isAnimating ? 20 : -20)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            .frame(height: 40)
            
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color.adaptiveSecondaryText)
        }
        .onAppear {
            isAnimating = true
        }
    }
}


struct SkeletonView: View {
    @State private var shimmer = false
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 12) {
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.adaptiveSecondaryText.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: shimmer ? 200 : -200)
            )
            .clipped()
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    shimmer = true
                }
            }
    }
}


struct SkeletonCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Фото placeholder
            SkeletonView(cornerRadius: 0)
                .frame(height: 280)
            
            // Информация placeholder
            HStack(spacing: 12) {
                SkeletonView()
                    .frame(width: 80, height: 32)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    SkeletonView()
                        .frame(width: 50, height: 16)
                    SkeletonView()
                        .frame(width: 70, height: 12)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
    }
}

#Preview {
    VStack(spacing: 30) {
        LoadingView()
        SkeletonCardView()
            .padding(.horizontal, 20)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.adaptiveBackground)
}


