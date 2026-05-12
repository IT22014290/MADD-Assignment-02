import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(PhoneSessionManager.self) private var phoneSession
    @Environment(\.modelContext) private var context

    // Queries used for Watch sync and sidebar
    @Query(sort: \Child.fullName) private var children: [Child]
    @Query(sort: \IncidentReport.incidentDate, order: .reverse) private var incidents: [IncidentReport]

    @State private var selectedChild: Child? = nil
    @State private var selectedTab: KeyworkerTab = .diary
    @State private var showAddChild = false
    @State private var showSettings = false
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ChildrenSidebarView(selectedChild: $selectedChild)
                .navigationTitle(appState.currentRoom)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showAddChild = true
                        } label: {
                            Image(systemName: "person.badge.plus")
                        }
                        .keyboardShortcut("n", modifiers: [.command, .shift])
                        .accessibilityLabel("Add new child")
                    }
                    ToolbarItem(placement: .secondaryAction) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                        .accessibilityLabel("Open settings")
                    }
                }
        } detail: {
            if let child = selectedChild {
                ChildDetailTabView(child: child, selectedTab: $selectedTab)
                    .id(child.id)
            } else {
                ContentPlaceholderView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showAddChild) {
            AddChildView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        // Sync children to Watch whenever the list changes
        .onChange(of: children) { _, updated in
            phoneSession.syncChildren(updated)
        }
        // Sync incidents to Watch whenever they change
        .onChange(of: incidents) { _, updated in
            phoneSession.syncIncidents(updated)
        }
        // Apply Watch check-in changes back into SwiftData
        .onChange(of: phoneSession.pendingWatchCheckIns) { _, ids in
            applyWatchCheckIns(ids: ids)
        }
        // Initial sync on launch
        .task {
            phoneSession.syncChildren(children)
            phoneSession.syncIncidents(incidents)
        }
    }

    // Update SwiftData to match what the Watch reported as checked-in
    private func applyWatchCheckIns(ids: [String]) {
        for child in children {
            let shouldBeIn = ids.contains(child.id.uuidString)
            if child.isCheckedIn != shouldBeIn {
                child.isCheckedIn = shouldBeIn
                child.checkInTime = shouldBeIn ? Date() : nil
                child.checkInBy   = shouldBeIn ? "Watch" : ""
            }
        }
        try? context.save()
    }
}

// MARK: - Keyworker Tabs

enum KeyworkerTab: String, CaseIterable {
    case diary      = "Diary"
    case eyfs       = "EYFS"
    case analytics  = "Analytics"
    case attendance = "Attendance"
    case incidents  = "Incidents"
    case profile    = "Profile"

    var icon: String {
        switch self {
        case .diary:      return "book.fill"
        case .eyfs:       return "graduationcap.fill"
        case .analytics:  return "chart.bar.fill"
        case .attendance: return "checkmark.circle.fill"
        case .incidents:  return "exclamationmark.triangle.fill"
        case .profile:    return "person.fill"
        }
    }

    var color: Color {
        switch self {
        case .diary:      return NurseryTheme.primary
        case .eyfs:       return NurseryTheme.purple
        case .analytics:  return NurseryTheme.teal
        case .attendance: return .green
        case .incidents:  return .orange
        case .profile:    return NurseryTheme.indigo
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var keyworkerName = ""
    @State private var room = ""

    private let rooms = ["Sunshine Room", "Rainbow Room", "Stars Room", "Butterfly Room"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Keyworker") {
                    TextField("Your name", text: $keyworkerName)
                        .accessibilityLabel("Keyworker name")
                        .accessibilityHint("Enter the name of the keyworker using this device")
                }
                Section("Room") {
                    Picker("Current room", selection: $room) {
                        ForEach(rooms, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .accessibilityLabel("Current room")
                }
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(NurseryTheme.primary)
                        Text("These settings are saved on this device and used when creating diary entries, observations, and incident reports.")
                            .font(.system(size: 13))
                            .foregroundStyle(NurseryTheme.textSecondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        appState.currentKeyworkerName = keyworkerName
                        appState.currentRoom = room
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(NurseryTheme.primary)
                    .disabled(keyworkerName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityLabel("Save settings")
                }
            }
            .onAppear {
                keyworkerName = appState.currentKeyworkerName
                room = appState.currentRoom
            }
        }
        .frame(minWidth: 380, minHeight: 320)
    }
}

// MARK: - Placeholder View

private struct ContentPlaceholderView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 64))
                .foregroundStyle(NurseryTheme.primary.opacity(0.25))
                .accessibilityHidden(true)
            VStack(spacing: 8) {
                Text("Welcome to NurseryConnect")
                    .font(.title2.bold())
                    .foregroundStyle(NurseryTheme.textPrimary)
                Text("Select a child from the sidebar to view their diary,\nEYFS progress, attendance and more.")
                    .font(.subheadline)
                    .foregroundStyle(NurseryTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            HStack(spacing: 32) {
                FeatureHint(icon: "book.fill",                     label: "Diary",     color: NurseryTheme.primary)
                FeatureHint(icon: "graduationcap.fill",            label: "EYFS",      color: NurseryTheme.purple)
                FeatureHint(icon: "chart.bar.fill",                label: "Analytics", color: NurseryTheme.teal)
                FeatureHint(icon: "exclamationmark.triangle.fill", label: "Incidents", color: .orange)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NurseryTheme.background)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Welcome to NurseryConnect. Select a child from the sidebar to begin.")
    }
}

private struct FeatureHint: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(NurseryTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
    }
}
