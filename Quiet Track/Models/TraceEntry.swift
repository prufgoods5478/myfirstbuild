import Foundation
import SwiftUI
import Combine

struct TraceEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let timestamp: Date
    var tagIcon: String
    var colorHex: String
    let photoPath: String
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        tagIcon: String,
        colorHex: String,
        photoPath: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.tagIcon = tagIcon
        self.colorHex = colorHex
        self.photoPath = photoPath
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .gray
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: timestamp)
    }
    
    var dayPeriod: DayPeriod {
        let hour = Calendar.current.component(.hour, from: timestamp)
        switch hour {
        case 5..<12: return .morning
        case 12..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }
}

enum DayPeriod: String, CaseIterable, Codable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case night = "Night"
    
    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .morning: return Color(hex: "#FFB347") ?? .orange
        case .afternoon: return Color(hex: "#FFD700") ?? .yellow
        case .evening: return Color(hex: "#FF6B6B") ?? .red
        case .night: return Color(hex: "#4A5568") ?? .gray
        }
    }
}
