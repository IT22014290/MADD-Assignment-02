import SwiftUI
import SwiftData

struct ChildrenSidebarView: View {
    @Binding var selectedChild: Child?
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @Query(sort: \Child.fullName) private var children: [Child]
    @State private var searchText = ""
    @State private var filterCheckedIn = false
    @State private var isDropTargeting = false

    var filtered: [Child] {
        children.filter { child in
            let matchesSearch = searchText.isEmpty ||
                child.fullName.localizedCaseInsensitiveContains(searchText) ||
                child.preferredName.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = !filterCheckedIn || child.isCheckedIn
            return matchesSearch && matchesFilter
        }
    }

    var checkedInCount: Int { children.filter(\.isCheckedIn).count }

    var body: some View {
        VStack(spacing: 0) {
            // Stats bar
            HStack(spacing: 16) {
                Label("\(checkedInCount) present", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.green)
                Label("\(children.count - checkedInCount) absent", systemImage: "xmark.circle.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("Present only", isOn: $filterCheckedIn)
                    .toggleStyle(.button)
                    .font(.system(size: 12, weight: .medium))
                    .tint(NurseryTheme.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(NurseryTheme.background)

            Divider()

            // Drag-to-check-in drop zone
            CheckInDropZone(isTargeting: isDropTargeting)
                .onDrop(of: ["public.text"], isTargeted: $isDropTargeting) { providers in
                    providers.first?.loadObject(ofClass: String.self) { value, _ in
                        guard let idString = value,
                              let uuid = UUID(uuidString: idString),
                              let child = children.first(where: { $0.id == uuid }),
                              !child.isCheckedIn else { return }
                        DispatchQueue.main.async {
                            child.isCheckedIn = true
                            child.checkInTime = Date()
                            child.checkInBy   = appState.currentKeyworkerName
                            try? context.save()
                        }
                    }
                    return true
                }

            if filtered.isEmpty {
                EmptyStateView(
                    icon: "person.2.slash",
                    title: "No children found",
                    message: "Try adjusting your search or filter."
                )
            } else {
                List(filtered, id: \.id, selection: $selectedChild) { child in
                    ChildSidebarRow(child: child)
                        .tag(child)
                        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .accessibilityLabel("\(child.fullName), \(child.displayAge), \(child.isCheckedIn ? "present" : "not checked in")\(child.hasAllergens ? ", has allergens" : "")\(child.sendFlag ? ", SEND" : "")")
                        .accessibilityHint("Tap to view \(child.preferredName)'s records. Long press for quick actions.")
                        // Drag: drag a child card to the drop zone to check in
                        .onDrag {
                            NSItemProvider(object: child.id.uuidString as NSString)
                        }
                        // Context menu for quick actions
                        .contextMenu {
                            if child.isCheckedIn {
                                Button(role: .none) {
                                    checkOut(child)
                                } label: {
                                    Label("Check Out", systemImage: "arrow.left.circle.fill")
                                }
                            } else {
                                Button(role: .none) {
                                    checkIn(child)
                                } label: {
                                    Label("Check In", systemImage: "arrow.right.circle.fill")
                                }
                            }
                            Divider()
                            Button {
                                selectedChild = child
                            } label: {
                                Label("View Profile", systemImage: "person.fill")
                            }
                            if child.hasAllergens {
                                Divider()
                                Button(role: .none) { } label: {
                                    Label("⚠️ " + child.allergens.joined(separator: ", "),
                                          systemImage: "exclamationmark.triangle.fill")
                                }
                                .disabled(true)
                            }
                        }
                }
                .listStyle(.sidebar)
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search children")
    }

    private func checkIn(_ child: Child) {
        child.isCheckedIn = true
        child.checkInTime = Date()
        child.checkInBy   = appState.currentKeyworkerName
        try? context.save()
    }

    private func checkOut(_ child: Child) {
        child.isCheckedIn = false
        child.checkInTime = nil
        child.checkInBy   = ""
        try? context.save()
    }
}

// MARK: - Drag Drop Zone

private struct CheckInDropZone: View {
    let isTargeting: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isTargeting ? "checkmark.circle.fill" : "arrow.down.circle.dotted")
                .font(.system(size: 16))
                .foregroundStyle(isTargeting ? .green : NurseryTheme.primary.opacity(0.5))
                .animation(.spring(response: 0.3), value: isTargeting)
            Text(isTargeting ? "Drop to check in" : "Drag child here to check in")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isTargeting ? .green : NurseryTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isTargeting ? Color.green.opacity(0.1) : NurseryTheme.primary.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isTargeting ? Color.green : NurseryTheme.primary.opacity(0.2),
                        style: StrokeStyle(lineWidth: 1.5, dash: [4]))
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .animation(.easeInOut(duration: 0.2), value: isTargeting)
    }
}

// MARK: - Child Row

private struct ChildSidebarRow: View {
    let child: Child

    var avatarColor: Color {
        let colors: [Color] = [NurseryTheme.primary, NurseryTheme.teal, NurseryTheme.purple,
                               NurseryTheme.pink, NurseryTheme.orange, NurseryTheme.indigo]
        let idx = abs(child.fullName.hashValue) % colors.count
        return colors[idx]
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                ChildAvatarView(initials: child.initials, color: avatarColor, size: 44)
                Circle()
                    .fill(child.isCheckedIn ? Color.green : Color.gray.opacity(0.4))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(child.fullName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NurseryTheme.textPrimary)
                HStack(spacing: 6) {
                    Text(child.displayAge)
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    if child.hasAllergens {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.orange)
                    }
                    if child.sendFlag {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(NurseryTheme.purple)
                    }
                }
                if child.isCheckedIn, let t = child.checkInTime {
                    Text("In since \(t.shortTimeString)")
                        .font(.system(size: 11))
                        .foregroundStyle(.green)
                } else {
                    Text("Not checked in")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
