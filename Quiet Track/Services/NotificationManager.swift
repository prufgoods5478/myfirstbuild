import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var morningReminderEnabled = false
    @Published var eveningReminderEnabled = false
    
    private let center = UNUserNotificationCenter.current()
    
    private let morningIdentifier = "tracelog_morning_reminder"
    private let eveningIdentifier = "tracelog_evening_reminder"
    
    private init() {
        checkAuthorization()
        loadSettings()
    }
    
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted {
                    self?.loadSettings()
                }
            }
        }
    }
    
    func checkAuthorization() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func loadSettings() {
        morningReminderEnabled = UserDefaults.standard.bool(forKey: "morning_reminder")
        eveningReminderEnabled = UserDefaults.standard.bool(forKey: "evening_reminder")
        
        if morningReminderEnabled {
            scheduleMorningReminder()
        }
        if eveningReminderEnabled {
            scheduleEveningReminder()
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(morningReminderEnabled, forKey: "morning_reminder")
        UserDefaults.standard.set(eveningReminderEnabled, forKey: "evening_reminder")
    }
    
    func toggleMorningReminder() {
        morningReminderEnabled.toggle()
        saveSettings()
        
        if morningReminderEnabled {
            scheduleMorningReminder()
        } else {
            cancelReminder(identifier: morningIdentifier)
        }
    }
    
    private func scheduleMorningReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Good morning! ☀️"
        content.body = "Capture your first trace of the day"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: morningIdentifier, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func toggleEveningReminder() {
        eveningReminderEnabled.toggle()
        saveSettings()
        
        if eveningReminderEnabled {
            scheduleEveningReminder()
        } else {
            cancelReminder(identifier: eveningIdentifier)
        }
    }
    
    private func scheduleEveningReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Evening moment 🌙"
        content.body = "Capture the last trace of the day"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: eveningIdentifier, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    private func cancelReminder(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
        morningReminderEnabled = false
        eveningReminderEnabled = false
        saveSettings()
    }
}
