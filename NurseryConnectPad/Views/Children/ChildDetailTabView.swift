import SwiftUI
import SwiftData

struct ChildDetailTabView: View {
    let child: Child
    @Binding var selectedTab: KeyworkerTab
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context

    @Query private var pendingIncidents: [IncidentReport]

    init(child: Child, selectedTab: Binding<KeyworkerTab>) {
        self.child = child
        _selectedTab = selectedTab
        let childId = child.id
        _pendingIncidents = Query(
            filter: #Predicate<IncidentReport> { $0.childId == childId && $0.status == "pending" }
        )
    }

    var avatarColor: Color {
        let colors: [Color] = [NurseryTheme.primary, NurseryTheme.teal, NurseryTheme.purple,
                               NurseryTheme.pink, NurseryTheme.orange, NurseryTheme.indigo]
        return colors[abs(child.fullName.hashValue) % colors.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Child header
            childHeader

            Divider()

            // Tab bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(KeyworkerTab.allCases, id: \.self) { tab in
                        TabBarButton(
                            tab: tab,
                            isSelected: selectedTab == tab,
                            badgeCount: tab == .incidents ? pendingIncidents.count : 0
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .background(NurseryTheme.cardBg)

            Divider()

            // Tab content
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(NurseryTheme.background)
        .navigationTitle(child.preferredName)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var childHeader: some View {
        HStack(spacing: 16) {
            ChildAvatarView(initials: child.initials, color: avatarColor, size: 52)

            VStack(alignment: .leading, spacing: 4) {
                Text(child.fullName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(NurseryTheme.textPrimary)
                HStack(spacing: 8) {
                    Text(child.displayAge)
                        .font(.system(size: 13))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text("·")
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text(child.room)
                        .font(.system(size: 13))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
                HStack(spacing: 6) {
                    if child.hasAllergens {
                        ForEach(child.allergens.prefix(2), id: \.self) { a in
                            AllergenTag(allergen: a)
                        }
                    }
                    if child.sendFlag {
                        StatusBadge(text: "SEND", color: NurseryTheme.purple)
                    }
                }
            }

            Spacer()

            // Quick check-in/out
            Button {
                toggleCheckIn()
            } label: {
                Label(child.isCheckedIn ? "Check Out" : "Check In",
                      systemImage: child.isCheckedIn ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(child.isCheckedIn ? .orange : .green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background((child.isCheckedIn ? Color.orange : Color.green).opacity(0.12))
                    .clipShape(Capsule())
            }
            .keyboardShortcut(child.isCheckedIn ? "o" : "i", modifiers: [.command])
            .accessibilityLabel(child.isCheckedIn ? "Check out \(child.preferredName)" : "Check in \(child.preferredName)")
            .accessibilityHint(child.isCheckedIn ? "Records \(child.preferredName)'s departure" : "Records \(child.preferredName)'s arrival")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(NurseryTheme.cardBg)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .diary:
            DiaryFeedView(child: child)
        case .eyfs:
            EYFSLearningJourneyView(child: child)
        case .analytics:
            AnalyticsDashboardView(child: child)
        case .attendance:
            AttendanceView(child: child)
        case .incidents:
            IncidentListView(child: child)
        case .profile:
            ChildProfileView(child: child)
        }
    }

    private func toggleCheckIn() {
        if child.isCheckedIn {
            child.isCheckedIn = false
            child.checkInTime = nil
            child.checkInBy = ""
            let record = AttendanceRecord(childId: child.id, childName: child.fullName)
            record.checkOutTime = Date()
            context.insert(record)
        } else {
            child.isCheckedIn = true
            child.checkInTime = Date()
            child.checkInBy = appState.currentKeyworkerName
            let entry = DiaryEntry(
                childId: child.id, childName: child.fullName,
                entryType: "checkin",
                description: "Checked in to \(child.room)",
                keyworkerName: appState.currentKeyworkerName
            )
            context.insert(entry)
        }
        try? context.save()
    }
}

// MARK: - Tab Bar Button

private struct TabBarButton: View {
    let tab: KeyworkerTab
    let isSelected: Bool
    let badgeCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(isSelected ? tab.color : NurseryTheme.textSecondary)
                    if badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 8, y: -6)
                    }
                }
                Text(tab.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? tab.color : NurseryTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .overlay(alignment: .bottom) {
                if isSelected {
                    Rectangle()
                        .fill(tab.color)
                        .frame(height: 2)
                        .clipShape(Capsule())
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(badgeCount > 0 ? "\(badgeCount) pending" : "")
    }
}
