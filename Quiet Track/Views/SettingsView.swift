
import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager: DataManager
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showTagEditor = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color.adaptivePrimaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Appearance
                    appearanceSection
                    
                    // Notifications
                    notificationsSection
                    
                    // Tags
                    tagsSection
                    
                    // About
                    aboutSection
                    
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .scrollIndicators(.hidden)
            .background(Color.adaptiveBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $showTagEditor) {
                TagEditorView(dataManager: dataManager)
            }
        }
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        SettingsSection(title: "Appearance", icon: "paintbrush.fill") {
            HStack {
                Label {
                    Text("Dark Mode")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.adaptivePrimaryText)
                } icon: {
                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(isDarkMode ? .purple : .orange)
                }
                
                Spacer()
                
                Toggle("", isOn: $isDarkMode)
                    .tint(AppTheme.accent)
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        SettingsSection(title: "Notifications", icon: "bell.fill") {
            VStack(spacing: 16) {
                // Request permission
                if !notificationManager.isAuthorized {
                    Button {
                        notificationManager.requestAuthorization()
                    } label: {
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundColor(AppTheme.accent)
                            Text("Enable Notifications")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.accent)
                        }
                    }
                } else {
                    // Morning reminder
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Morning Reminder")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.adaptivePrimaryText)
                                Text("9:00 AM")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.adaptiveSecondaryText)
                            }
                        } icon: {
                            Image(systemName: "sunrise.fill")
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { notificationManager.morningReminderEnabled },
                            set: { _ in notificationManager.toggleMorningReminder() }
                        ))
                        .tint(AppTheme.accent)
                    }
                    
                    Divider()
                    
                    // Evening reminder
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Evening Reminder")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.adaptivePrimaryText)
                                Text("9:00 PM")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color.adaptiveSecondaryText)
                            }
                        } icon: {
                            Image(systemName: "moon.stars.fill")
                                .foregroundColor(.purple)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { notificationManager.eveningReminderEnabled },
                            set: { _ in notificationManager.toggleEveningReminder() }
                        ))
                        .tint(AppTheme.accent)
                    }
                }
            }
        }
    }
    
    // MARK: - Tags Section
    
    private var tagsSection: some View {
        SettingsSection(title: "Tags", icon: "tag.fill") {
            Button {
                showTagEditor = true
            } label: {
                HStack {
                    Text("Edit Tags")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.adaptivePrimaryText)
                    
                    Spacer()
                    
                    Text("\(dataManager.tags.count)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.adaptiveSecondaryText)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.adaptiveSecondaryText)
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        SettingsSection(title: "About", icon: "info.circle.fill") {
            VStack(spacing: 12) {
                HStack {
                    Text("Version")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.adaptivePrimaryText)
                    
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.adaptiveSecondaryText)
                }
                
                Divider()
                
                HStack {
                    Text("Total Traces")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color.adaptivePrimaryText)
                    
                    Spacer()
                    
                    Text("\(dataManager.traces.count)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color.adaptiveSecondaryText)
                }
            }
        }
    }
    
}


struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.adaptiveSecondaryText)
                    .textCase(.uppercase)
                    .tracking(1)
            }
            
            // Content
            content
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.adaptiveCardBackground)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
                )
        }
    }
}


struct TagEditorView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showAddTag = false
    @State private var newTagName = ""
    @State private var newTagIcon = "star.fill"
    
    private let availableIcons = [
        "star.fill", "heart.fill", "bolt.fill", "leaf.fill",
        "flame.fill", "drop.fill", "snowflake", "moon.fill",
        "sun.max.fill", "cloud.fill", "wind", "sparkles",
        "wand.and.stars", "paintbrush.fill", "pencil", "scissors",
        "hammer.fill", "wrench.fill", "gearshape.fill", "link",
        "paperclip", "bandage.fill", "cross.fill", "pills.fill"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Default") {
                    ForEach(dataManager.tags.filter { $0.isDefault }) { tag in
                        tagRow(tag)
                    }
                }
                
                Section("Custom") {
                    ForEach(dataManager.tags.filter { !$0.isDefault }) { tag in
                        tagRow(tag)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    dataManager.deleteTag(tag)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    
                    Button {
                        showAddTag = true
                    } label: {
                        Label("Add Tag", systemImage: "plus.circle.fill")
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.accent)
                }
            }
            .alert("New Tag", isPresented: $showAddTag) {
                TextField("Name", text: $newTagName)
                
                Button("Cancel", role: .cancel) {
                    newTagName = ""
                }
                
                Button("Add") {
                    let tag = Tag(icon: newTagIcon, name: newTagName, isDefault: false)
                    dataManager.addTag(tag)
                    newTagName = ""
                }
                .disabled(newTagName.isEmpty)
            } message: {
                Text("Enter a name for the new tag")
            }
        }
    }
    
    private func tagRow(_ tag: Tag) -> some View {
        HStack(spacing: 12) {
            Image(systemName: tag.icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.accent)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(AppTheme.accent.opacity(0.15))
                )
            
            Text(tag.name)
                .font(.system(size: 16, weight: .medium, design: .rounded))
            
            Spacer()
            
            if tag.isDefault {
                Text("Default")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.adaptiveSecondaryText)
            }
        }
    }
}

#Preview {
    SettingsView(dataManager: DataManager.shared)
}
