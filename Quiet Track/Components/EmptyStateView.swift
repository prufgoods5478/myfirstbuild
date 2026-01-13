
import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Иконка с анимацией
            ZStack {
                Circle()
                    .fill(Color.adaptiveSecondaryText.opacity(0.08))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color.adaptiveSecondaryText.opacity(0.5))
            }
            
            // Текст
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color.adaptivePrimaryText)
                
                Text(message)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Color.adaptiveSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Кнопка действия
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text(actionTitle)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(AppTheme.headerGradient)
                    )
                    .shadow(color: AppTheme.accent.opacity(0.4), radius: 12, y: 6)
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "camera.viewfinder",
        title: "Пока пусто",
        message: "Оставь первый след дня",
        actionTitle: "Добавить",
        action: {}
    )
}


