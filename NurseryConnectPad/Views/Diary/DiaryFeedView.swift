import SwiftUI
import SwiftData

struct DiaryFeedView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState

    @Query private var entries: [DiaryEntry]
    @State private var showAddEntry = false
    @State private var selectedEntry: DiaryEntry? = nil
    @State private var filterType = "all"

    private let entryTypes = ["all", "activity", "sleep", "meal", "nappy", "wellbeing", "milestone", "photo"]

    init(child: Child) {
        self.child = child
        let childId = child.id
        _entries = Query(
            filter: #Predicate<DiaryEntry> { $0.childId == childId },
            sort: \DiaryEntry.timestamp,
            order: .reverse
        )
    }

    var filtered: [DiaryEntry] {
        filterType == "all" ? entries : entries.filter { $0.entryType == filterType }
    }

    private func entryTypeLabel(_ type: String) -> String {
        switch type {
        case "activity":  return "Activity"
        case "sleep":     return "Sleep"
        case "meal":      return "Meal"
        case "nappy":     return "Nappy"
        case "wellbeing": return "Wellbeing"
        case "milestone": return "Milestone"
        case "photo":     return "Photo"
        default:          return type.capitalized
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(entryTypes, id: \.self) { type in
                        FilterChip(
                            label: type == "all" ? "All" : entryTypeLabel(type),
                            isSelected: filterType == type
                        ) {
                            filterType = type
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(NurseryTheme.cardBg)

            Divider()

            if filtered.isEmpty {
                EmptyStateView(
                    icon: "book.closed",
                    title: "No diary entries",
                    message: "Tap + to add the first entry for \(child.preferredName).",
                    buttonTitle: "Add Entry"
                ) {
                    showAddEntry = true
                }
            } else {
                List {
                    ForEach(filtered) { entry in
                        DiaryEntryCard(entry: entry)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                selectedEntry = entry
                            }
                    }
                    .onDelete { indexSet in
                        for idx in indexSet {
                            context.delete(filtered[idx])
                        }
                    }
                }
                .listStyle(.plain)
                .background(NurseryTheme.background)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddEntry = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(NurseryTheme.primary)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        .sheet(isPresented: $showAddEntry) {
            AddDiaryEntryView(child: child)
        }
        .sheet(item: $selectedEntry) { entry in
            DiaryEntryDetailView(entry: entry)
        }
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : NurseryTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? NurseryTheme.primary : Color.gray.opacity(0.1))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
