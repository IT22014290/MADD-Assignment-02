import SwiftUI
import SwiftData

struct IncidentListView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Query private var incidents: [IncidentReport]
    @State private var showNewIncident = false
    @State private var selectedIncident: IncidentReport? = nil

    init(child: Child) {
        self.child = child
        let childId = child.id
        _incidents = Query(
            filter: #Predicate<IncidentReport> { $0.childId == childId },
            sort: \IncidentReport.incidentDate, order: .reverse
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !incidents.isEmpty {
                    incidentSummary
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Incident Reports (\(incidents.count))")
                            .sectionHeaderStyle()
                        Spacer()
                        Button("New Report") { showNewIncident = true }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.orange)
                    }

                    if incidents.isEmpty {
                        EmptyStateView(
                            icon: "checkmark.shield.fill",
                            title: "No incidents recorded",
                            message: "Incident reports for \(child.preferredName) will appear here.",
                            buttonTitle: "File Report"
                        ) {
                            showNewIncident = true
                        }
                    } else {
                        ForEach(incidents) { incident in
                            IncidentCard(incident: incident)
                                .onTapGesture { selectedIncident = incident }
                                .accessibilityLabel("\(incident.categoryDisplay), \(incident.status.capitalized), \(incident.incidentDate.dayMonthString)")
                                .accessibilityHint("Tap to view or update this incident report")
                        }
                    }
                }
                .cardStyle()
            }
            .padding(16)
        }
        .background(NurseryTheme.background)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showNewIncident = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.orange)
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])
                .accessibilityLabel("File new incident report")
            }
        }
        .sheet(isPresented: $showNewIncident) {
            NewIncidentView(child: child)
        }
        .sheet(item: $selectedIncident) { incident in
            IncidentDetailView(incident: incident)
        }
    }

    private var incidentSummary: some View {
        HStack(spacing: 12) {
            let pending  = incidents.filter { $0.status == "pending" }.count
            let serious  = incidents.filter { $0.isSerious }.count
            StatCard(title: "Total Reports",   value: "\(incidents.count)", icon: "doc.text.fill",                   color: NurseryTheme.primary)
            StatCard(title: "Pending Review",  value: "\(pending)",         icon: "clock.fill",                     color: .orange)
            StatCard(title: "Serious",         value: "\(serious)",         icon: "exclamationmark.triangle.fill",  color: .red)
        }
    }
}

// MARK: - Incident Card

private struct IncidentCard: View {
    let incident: IncidentReport

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(incident.severityColor)
                        .frame(width: 8, height: 8)
                    Text(incident.categoryDisplay)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(incident.severityColor)
                }
                Spacer()
                StatusBadge(text: incident.status.capitalized, color: incident.statusColor)
                Text(incident.incidentDate.dayMonthString)
                    .font(.system(size: 12))
                    .foregroundStyle(NurseryTheme.textSecondary)
            }

            Text(incident.incidentDescription)
                .font(.system(size: 14))
                .foregroundStyle(NurseryTheme.textPrimary)
                .lineLimit(2)

            HStack(spacing: 12) {
                if !incident.location.isEmpty {
                    Label(incident.location, systemImage: "mappin.circle")
                        .font(.system(size: 11))
                        .foregroundStyle(NurseryTheme.textSecondary)
                }
                Label(incident.reportedBy, systemImage: "person")
                    .font(.system(size: 11))
                    .foregroundStyle(NurseryTheme.textSecondary)
                Spacer()
                if incident.parentNotified {
                    Label("Parent notified", systemImage: "bell.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(12)
        .background(incident.isSerious ? Color.red.opacity(0.04) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(incident.severityColor.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Incident Detail View

struct IncidentDetailView: View {
    let incident: IncidentReport
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState

    // Manager review state
    @State private var reviewStatus: String
    @State private var managerNotes: String
    @State private var parentNotified: Bool
    @State private var ofstedNotified: Bool
    @State private var riddorRequired: Bool
    @State private var showReviewEditor = false
    @State private var isSavingReview = false

    init(incident: IncidentReport) {
        self.incident = incident
        _reviewStatus     = State(initialValue: incident.status)
        _managerNotes     = State(initialValue: incident.managerNotes)
        _parentNotified   = State(initialValue: incident.parentNotified)
        _ofstedNotified   = State(initialValue: incident.ofstedNotified)
        _riddorRequired   = State(initialValue: incident.riddorRequired)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(incident.categoryDisplay)
                                .font(.title3.bold())
                                .foregroundStyle(incident.severityColor)
                            Text(incident.incidentDate.mediumDateString + " at " + incident.incidentDate.shortTimeString)
                                .font(.subheadline)
                                .foregroundStyle(NurseryTheme.textSecondary)
                        }
                        Spacer()
                        StatusBadge(text: incident.status.capitalized, color: incident.statusColor)
                    }
                    .cardStyle()
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(incident.categoryDisplay), status: \(incident.status)")

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Incident Description")
                            .sectionHeaderStyle()
                        Text(incident.incidentDescription)
                            .font(.system(size: 15))
                            .foregroundStyle(NurseryTheme.textPrimary)
                    }
                    .cardStyle()

                    // Immediate action
                    if !incident.immediateAction.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Immediate Action Taken")
                                .sectionHeaderStyle()
                            Text(incident.immediateAction)
                                .font(.system(size: 15))
                        }
                        .cardStyle()
                    }

                    // Record details
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Record Details")
                            .sectionHeaderStyle()
                        InfoRow(label: "Reported by",   value: incident.reportedBy)
                        InfoRow(label: "Location",      value: incident.location.isEmpty ? "—" : incident.location)
                        InfoRow(label: "Witnesses",     value: incident.witnesses.isEmpty ? "None" : incident.witnesses)
                        InfoRow(label: "Injury site",   value: incident.injuryBodyLocation.isEmpty ? "—" : incident.injuryBodyLocation)
                        InfoRow(label: "Parent notified",
                                value: incident.parentNotified
                                    ? (incident.parentNotifiedTime?.shortTimeString ?? "Yes")
                                    : "No",
                                valueColor: incident.parentNotified ? .green : .orange)
                        if incident.isSerious {
                            InfoRow(label: "Ofsted notified",
                                    value: incident.ofstedNotified ? "Yes" : "Pending",
                                    valueColor: incident.ofstedNotified ? .green : .red)
                            InfoRow(label: "RIDDOR required",
                                    value: incident.riddorRequired ? "Yes" : "No",
                                    valueColor: incident.riddorRequired ? .red : .secondary)
                        }
                    }
                    .cardStyle()

                    // Manager Review Section
                    managerReviewSection
                }
                .padding(16)
            }
            .background(NurseryTheme.background)
            .navigationTitle("Incident Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .frame(minWidth: 480, minHeight: 500)
    }

    // MARK: Manager Review Section

    @ViewBuilder
    private var managerReviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Manager Review")
                    .sectionHeaderStyle()
                Spacer()
                if incident.status != "finalised" {
                    Button(showReviewEditor ? "Cancel" : "Update Status") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showReviewEditor.toggle()
                        }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(NurseryTheme.primary)
                }
            }

            // Status display
            HStack(spacing: 12) {
                ForEach(["pending", "reviewed", "finalised"], id: \.self) { s in
                    let isActive = incident.status == s
                    HStack(spacing: 6) {
                        Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 14))
                            .foregroundStyle(isActive ? statusColor(s) : NurseryTheme.textSecondary)
                        Text(s.capitalized)
                            .font(.system(size: 13, weight: isActive ? .semibold : .regular))
                            .foregroundStyle(isActive ? statusColor(s) : NurseryTheme.textSecondary)
                    }
                    .accessibilityLabel("Status: \(s.capitalized)\(isActive ? ", current status" : "")")
                    if s != "finalised" {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                            .foregroundStyle(NurseryTheme.textSecondary)
                    }
                }
            }

            if !incident.managerNotes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Manager Notes")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text(incident.managerNotes)
                        .font(.system(size: 14))
                        .foregroundStyle(NurseryTheme.textPrimary)
                }
            }

            if incident.managerReviewDate != nil {
                InfoRow(label: "Reviewed by", value: incident.managerName)
                InfoRow(label: "Review date", value: incident.managerReviewDate!.mediumDateString)
            }

            // Inline editor
            if showReviewEditor {
                reviewEditorView
            }
        }
        .cardStyle()
    }

    @ViewBuilder
    private var reviewEditorView: some View {
        Divider()

        VStack(alignment: .leading, spacing: 14) {
            Text("Update Incident")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(NurseryTheme.textPrimary)

            // Status picker
            Picker("New Status", selection: $reviewStatus) {
                Text("Pending").tag("pending")
                Text("Reviewed").tag("reviewed")
                Text("Finalised").tag("finalised")
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Update incident status")

            // Manager notes
            VStack(alignment: .leading, spacing: 6) {
                Text("Manager Notes")
                    .font(.system(size: 13))
                    .foregroundStyle(NurseryTheme.textSecondary)
                TextEditor(text: $managerNotes)
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(NurseryTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(NurseryTheme.primary.opacity(0.2), lineWidth: 1))
                    .accessibilityLabel("Manager review notes")
            }

            // Notification toggles
            Toggle("Parent Notified", isOn: $parentNotified)
                .tint(.green)
                .accessibilityLabel("Mark parent as notified")

            if incident.isSerious {
                Toggle("Ofsted Notified", isOn: $ofstedNotified)
                    .tint(.orange)
                    .accessibilityLabel("Mark Ofsted as notified")
                Toggle("RIDDOR Reportable", isOn: $riddorRequired)
                    .tint(.red)
                    .accessibilityLabel("Mark as RIDDOR reportable")
            }

            Button {
                saveReview()
            } label: {
                HStack {
                    if isSavingReview {
                        ProgressView().progressViewStyle(.circular).tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Save Review")
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle(color: NurseryTheme.primary))
            .disabled(isSavingReview)
            .accessibilityLabel("Save manager review")
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "pending":   return .orange
        case "reviewed":  return NurseryTheme.primary
        case "finalised": return .green
        default:          return .gray
        }
    }

    private func saveReview() {
        isSavingReview = true
        incident.status              = reviewStatus
        incident.managerNotes        = managerNotes
        incident.managerName         = appState.currentKeyworkerName
        incident.managerReviewDate   = Date()
        incident.parentNotified      = parentNotified
        incident.ofstedNotified      = ofstedNotified
        incident.riddorRequired      = riddorRequired
        if parentNotified && incident.parentNotifiedTime == nil {
            incident.parentNotifiedTime = Date()
        }
        try? context.save()
        withAnimation {
            showReviewEditor = false
            isSavingReview = false
        }
    }
}
