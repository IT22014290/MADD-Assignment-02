import SwiftUI
import SwiftData

struct MilestoneTrackerView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @Query private var milestones: [Milestone]
    @State private var showAddMilestone = false
    @State private var selectedArea: EYFSArea? = nil

    init(child: Child) {
        self.child = child
        let childId = child.id
        _milestones = Query(
            filter: #Predicate<Milestone> { $0.childId == childId },
            sort: \Milestone.achievedDate,
            order: .reverse
        )
    }

    var grouped: [EYFSArea: [Milestone]] {
        Dictionary(grouping: milestones) { $0.eyfsArea }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary bar
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                        ForEach(EYFSArea.allCases, id: \.self) { area in
                            let count = grouped[area]?.count ?? 0
                            VStack(spacing: 4) {
                                Image(systemName: area.icon)
                                    .font(.system(size: 16))
                                    .foregroundStyle(count > 0 ? area.color : .secondary)
                                Text("\(count)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(count > 0 ? NurseryTheme.textPrimary : .secondary)
                                Text(area.shortName)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(count > 0 ? area.color.opacity(0.08) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(area.color.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .cardStyle()

                    // Milestones by area
                    ForEach(EYFSArea.allCases, id: \.self) { area in
                        let areaMs = grouped[area] ?? []
                        if !areaMs.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: area.icon)
                                        .foregroundStyle(area.color)
                                    Text(area.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(NurseryTheme.textPrimary)
                                }
                                ForEach(areaMs) { milestone in
                                    MilestoneDetailRow(milestone: milestone)
                                }
                            }
                            .cardStyle()
                        }
                    }

                    // Suggested milestones
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suggested Next Milestones")
                            .sectionHeaderStyle()
                        let achieved = Set(milestones.map { $0.title })
                        let suggestions = suggestedMilestones.filter { !achieved.contains($0.title) }.prefix(4)
                        ForEach(Array(suggestions.enumerated()), id: \.offset) { _, suggestion in
                            SuggestedMilestoneRow(suggestion: suggestion) {
                                let m = Milestone(
                                    childId: child.id,
                                    childName: child.fullName,
                                    eyfsArea: suggestion.area,
                                    title: suggestion.title,
                                    description: suggestion.description,
                                    keyworkerName: appState.currentKeyworkerName
                                )
                                context.insert(m)
                                try? context.save()
                            }
                        }
                    }
                    .cardStyle()
                }
                .padding(16)
            }
            .background(NurseryTheme.background)
            .navigationTitle("\(child.preferredName)'s Milestones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddMilestone = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddMilestone) {
                AddMilestoneView(child: child)
            }
        }
        .frame(minWidth: 540, minHeight: 600)
    }
}

// MARK: - Milestone Row

private struct MilestoneDetailRow: View {
    let milestone: Milestone
    @Environment(\.modelContext) private var context

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20))
                .foregroundStyle(milestone.eyfsArea.color)
            VStack(alignment: .leading, spacing: 3) {
                Text(milestone.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NurseryTheme.textPrimary)
                Text(milestone.milestoneDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(NurseryTheme.textSecondary)
                    .lineLimit(2)
                Text(milestone.achievedDate.mediumDateString)
                    .font(.system(size: 11))
                    .foregroundStyle(NurseryTheme.textSecondary)
            }
            Spacer()
            if milestone.isSharedWithParent {
                Image(systemName: "person.fill.checkmark")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Suggested Milestone Row

private struct SuggestedMilestoneRow: View {
    let suggestion: SuggestedMilestone
    let onAdd: () -> Void
    @State private var added = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: suggestion.area.icon)
                .font(.system(size: 18))
                .foregroundStyle(suggestion.area.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(NurseryTheme.textPrimary)
                Text(suggestion.area.shortName)
                    .font(.system(size: 11))
                    .foregroundStyle(suggestion.area.color)
            }
            Spacer()
            Button {
                added = true
                onAdd()
            } label: {
                Image(systemName: added ? "checkmark.circle.fill" : "plus.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(added ? .green : NurseryTheme.primary)
            }
            .disabled(added)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Add Milestone View

struct AddMilestoneView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var selectedArea: EYFSArea = .communication
    @State private var title = ""
    @State private var description = ""
    @State private var achievedDate = Date()
    @State private var shareWithParent = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Milestone Details") {
                    Picker("EYFS Area", selection: $selectedArea) {
                        ForEach(EYFSArea.allCases, id: \.self) { area in
                            Label(area.rawValue, systemImage: area.icon).tag(area)
                        }
                    }
                    TextField("Milestone title", text: $title)
                    DatePicker("Achieved on", selection: $achievedDate, displayedComponents: .date)
                }
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 80)
                }
                Section {
                    Toggle("Share with parent", isOn: $shareWithParent)
                }
                Section("Quick Select") {
                    ForEach(suggestedMilestones.filter { $0.area == selectedArea }, id: \.title) { s in
                        Button {
                            title = s.title
                            description = s.description
                        } label: {
                            Text(s.title)
                                .foregroundStyle(NurseryTheme.primary)
                        }
                    }
                }
            }
            .navigationTitle("Record Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        let m = Milestone(
                            childId: child.id, childName: child.fullName,
                            eyfsArea: selectedArea, title: title,
                            description: description, keyworkerName: appState.currentKeyworkerName
                        )
                        m.achievedDate = achievedDate
                        m.isSharedWithParent = shareWithParent
                        context.insert(m)
                        try? context.save()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(NurseryTheme.purple)
                    .disabled(title.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 500)
    }
}
