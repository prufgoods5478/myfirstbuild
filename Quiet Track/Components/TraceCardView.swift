
import SwiftUI

struct TraceCardView: View {
    let trace: TraceEntry
    let tag: Tag?
    var onDelete: (() -> Void)?
    
    @State private var isAppeared = false
    @State private var showDeleteConfirm = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo
            ZStack(alignment: .topTrailing) {
                photoView
                
                // Mood color
                Circle()
                    .fill(trace.color)
                    .frame(width: 24, height: 24)
                    .shadow(color: trace.color.opacity(0.5), radius: 8, y: 2)
                    .padding(12)
            }
            
            // Info
            HStack(spacing: 12) {
                // Tag
                if let tag = tag {
                    HStack(spacing: 6) {
                        Image(systemName: tag.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.adaptivePrimaryText)
                        
                        Text(tag.name)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color.adaptiveSecondaryText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.adaptiveBackground)
                    )
                }
                
                Spacer()
                
                // Time
                VStack(alignment: .trailing, spacing: 2) {
                    Text(trace.formattedTime)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.adaptivePrimaryText)
                    
                    Text(trace.formattedDate)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.adaptiveSecondaryText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color.adaptiveCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 8)
        .opacity(isAppeared ? 1 : 0)
        .offset(y: isAppeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAppeared = true
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog("Delete this trace?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete?()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    @ViewBuilder
    private var photoView: some View {
        if let image = PhotoManager.shared.loadPhotoAsImage(from: trace.photoPath) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 280)
                .clipped()
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 280)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                )
        }
    }
}

struct MiniTraceCardView: View {
    let trace: TraceEntry
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image = PhotoManager.shared.loadPhotoAsImage(from: trace.photoPath) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray.opacity(0.2)
            }
            
            // Color
            Circle()
                .fill(trace.color)
                .frame(width: 10, height: 10)
                .padding(4)
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    VStack {
        TraceCardView(
            trace: TraceEntry(
                tagIcon: "cup.and.saucer.fill",
                colorHex: "#4ECDC4",
                photoPath: ""
            ),
            tag: Tag.defaultTags[1]
        )
        .padding()
    }
    .background(Color.adaptiveBackground)
}
