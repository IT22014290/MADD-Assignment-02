import SwiftUI
import SwiftData

struct EYFSLearningJourneyView: View {
    let child: Child
    @Environment(\.modelContext) private var context

    @Query private var observations: [EYFSObservation]
    @Query private var milestones: [Milestone]

    @State private var selectedArea: EYFSArea? = nil
    @State private var showAddObservation = false
    @State private var showMilestones = false
    @State private var selectedObs: EYFSObservation? = nil

    init(child: Child) {
        self.child = child
        let childId = child.id
        _observations = Query(
            filter: #Predicate<EYFSObservation> { $0.childId == childId },
            sort: \EYFSObservation.timestamp,
            order: .reverse
        )
        _milestones = Query(
            filter: #Predicate<Milestone> { $0.childId == childId },
            sort: \Milestone.achievedDate,
            order: .reverse
        )
    }

    var filteredObservations: [EYFSObservation] {
        guard let area = selectedArea else { return observations }
        return observations.filter { $0.eyfsAreaRaw == area.rawValue }
    }

    var coverageData: [EYFSAreaStat] {
        EYFSArea.allCases.map { area in
            let count = observations.filter { $0.eyfsAreaRaw == area.rawValue }.count
            return EYFSAreaStat(area: area, count: count)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Progress overview grid
                progressOverview

                // Area filter
                areaFilter

                // Observations list
                observationsList

                // Milestones
                milestonesSection
            }
            .padding(16)
        }
        .background(NurseryTheme.background)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showMilestones = true
                } label: {
                    Label("Milestones", systemImage: "star.fill")
                }

                Button {
                    showAddObservation = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(NurseryTheme.purple)
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }
        .sheet(isPresented: $showAddObservation) {
            AddObservationView(child: child)
        }
        .sheet(isPresented: $showMilestones) {
            MilestoneTrackerView(child: child)
        }
        .sheet(item: $selectedObs) { obs in
            ObservationDetailView(observation: obs)
        }
    }

    // MARK: Progress Overview

    private var progressOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EYFS Area Coverage")
                .sectionHeaderStyle()
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100), spacing: 10)
            ], spacing: 10) {
                ForEach(coverageData) { stat in
                    EYFSAreaTile(
                        stat: stat,
                        isSelected: selectedArea == stat.area
                    ) {
                        withAnimation {
                            selectedArea = selectedArea == stat.area ? nil : stat.area
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: Area Filter

    private var areaFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChipEYFS(label: "All Areas", isSelected: selectedArea == nil, color: NurseryTheme.primary) {
                    selectedArea = nil
                }
                ForEach(EYFSArea.allCases, id: \.self) { area in
                    FilterChipEYFS(label: area.shortName, isSelected: selectedArea == area, color: area.color) {
                        withAnimation { selectedArea = selectedArea == area ? nil : area }
                    }
                }
            }
        }
    }

    // MARK: Observations List

    private var observationsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Observations (\(filteredObservations.count))")
                    .sectionHeaderStyle()
                Spacer()
                Button("Add Observation") { showAddObservation = true }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(NurseryTheme.purple)
            }

            if filteredObservations.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass.circle",
                    title: "No observations",
                    message: selectedArea == nil
                        ? "Add the first EYFS observation for \(child.preferredName)."
                        : "No observations recorded for \(selectedArea?.shortName ?? "") yet."
                )
            } else {
                ForEach(filteredObservations) { obs in
                    ObservationCard(observation: obs)
                        .onTapGesture { selectedObs = obs }
                }
            }
        }
    }

    // MARK: Milestones Section

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Milestones")
                    .sectionHeaderStyle()
                Spacer()
                Button("View All") { showMilestones = true }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(NurseryTheme.primary)
            }

            if milestones.isEmpty {
                Text("No milestones recorded yet.")
                    .font(.subheadline)
                    .foregroundStyle(NurseryTheme.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(milestones.prefix(3)) { milestone in
                    MilestoneRow(milestone: milestone)
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Supporting Types & Views

struct EYFSAreaStat: Identifiable {
    let area: EYFSArea
    let count: Int
    var id: String { area.rawValue }
}

private struct EYFSAreaTile: View {
    let stat: EYFSAreaStat
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: stat.area.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? .white : stat.area.color)
                Text("\(stat.count)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(isSelected ? .white : NurseryTheme.textPrimary)
                Text(stat.area.shortName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? .white.opacity(0.9) : NurseryTheme.textSecondary)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(isSelected ? stat.area.color : stat.area.color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(stat.area.color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

private struct FilterChipEYFS: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : color.opacity(0.1))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

private struct ObservationCard: View {
    let observation: EYFSObservation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(observation.eyfsArea.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: observation.eyfsArea.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(observation.eyfsArea.color)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(observation.eyfsArea.shortName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(observation.eyfsArea.color)
                    StatusBadge(text: observation.stage.rawValue, color: observation.stage.color)
                    Spacer()
                    Text(observation.timestamp.dayMonthString)
                        .font(.system(size: 11))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
                Text(observation.observationText)
                    .font(.system(size: 14))
                    .foregroundStyle(NurseryTheme.textPrimary)
                    .lineLimit(2)
                if !observation.nextSteps.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right.circle")
                            .font(.system(size: 11))
                            .foregroundStyle(NurseryTheme.primary)
                        Text(observation.nextSteps)
                            .font(.system(size: 12))
                            .foregroundStyle(NurseryTheme.textSecondary)
                            .lineLimit(1)
                    }
                }
                if observation.drawingData != nil {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil.tip.crop.circle")
                            .font(.system(size: 11))
                        Text("Drawing attached")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(NurseryTheme.purple)
                }
            }
        }
        .cardStyle(padding: 12)
    }
}

private struct MilestoneRow: View {
    let milestone: Milestone

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(milestone.eyfsArea.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NurseryTheme.textPrimary)
                Text(milestone.eyfsArea.shortName + " · " + milestone.achievedDate.dayMonthString)
                    .font(.system(size: 12))
                    .foregroundStyle(NurseryTheme.textSecondary)
            }
            Spacer()
            if milestone.isSharedWithParent {
                Image(systemName: "person.fill.checkmark")
                    .font(.system(size: 13))
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}
