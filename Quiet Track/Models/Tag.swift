import Foundation
import SwiftUI
import Combine

struct Tag: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var icon: String
    var name: String
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        icon: String,
        name: String,
        isDefault: Bool = false
    ) {
        self.id = id
        self.icon = icon
        self.name = name
        self.isDefault = isDefault
    }
    
    static let defaultTags: [Tag] = [
        Tag(icon: "briefcase.fill", name: "Work", isDefault: true),
        Tag(icon: "cup.and.saucer.fill", name: "Coffee", isDefault: true),
        Tag(icon: "book.fill", name: "Reading", isDefault: true),
        Tag(icon: "bubble.left.and.bubble.right.fill", name: "Social", isDefault: true),
        Tag(icon: "figure.walk", name: "Movement", isDefault: true),
        Tag(icon: "sparkles", name: "Cleaning", isDefault: true),
        Tag(icon: "headphones", name: "Focus", isDefault: true),
        Tag(icon: "fork.knife", name: "Food", isDefault: true),
        Tag(icon: "cart.fill", name: "Shopping", isDefault: true),
        Tag(icon: "heart.fill", name: "Moment", isDefault: true)
    ]
}

struct MoodColor: Identifiable, Equatable {
    let id = UUID()
    let hex: String
    let name: String
    
    var color: Color {
        Color(hex: hex) ?? .gray
    }
    
    static let presets: [MoodColor] = [
        MoodColor(hex: "#4ECDC4", name: "Calm"),
        MoodColor(hex: "#FF6B6B", name: "Energy"),
        MoodColor(hex: "#FFE66D", name: "Joy"),
        MoodColor(hex: "#95E1D3", name: "Fresh"),
        MoodColor(hex: "#F38181", name: "Warm"),
        MoodColor(hex: "#AA96DA", name: "Creative"),
        MoodColor(hex: "#A8D8EA", name: "Light"),
        MoodColor(hex: "#FCBAD3", name: "Soft"),
        MoodColor(hex: "#2D3436", name: "Focus"),
        MoodColor(hex: "#74B9FF", name: "Clear")
    ]
}
