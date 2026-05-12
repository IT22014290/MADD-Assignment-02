import SwiftUI
import SwiftData

struct NewIncidentView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var category = "minor_accident"
    @State private var location = ""
    @State private var incidentDescription = ""
    @State private var immediateAction = ""
    @State private var witnesses = ""
    @State private var injuryBodyLocation = ""
    @State private var parentNotified = false
    @State private var parentNotifiedTime = Date()
    @State private var isSerious = false
    @State private var ofstedNotified = false
    @State private var riddorRequired = false
    @State private var isSaving = false

    private let categories = [
        "minor_accident", "first_aid", "near_miss",
        "safeguarding", "allergic_reaction", "medical"
    ]

    var body: some View {
        NavigationStack {
            Form {
                // Category
                Section("Incident Category") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(IncidentReport.categoryLabel(cat)).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: category) { _, newVal in
                        if newVal == "safeguarding" || newVal == "allergic_reaction" {
                            isSerious = true
                        }
                    }
                }

                // Description
                Section("Incident Description") {
                    TextEditor(text: $incidentDescription)
                        .frame(minHeight: 100)
                        .overlay(alignment: .topLeading) {
                            if incidentDescription.isEmpty {
                                Text("Describe what happened, when, and who was involved.")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 14))
                                    .padding(4)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                // Location & Witnesses
                Section("Location & Witnesses") {
                    TextField("Location (e.g. outdoor area, reading corner)", text: $location)
                    TextField("Witnesses (names and roles)", text: $witnesses)
                    TextField("Injury body location (if applicable)", text: $injuryBodyLocation)
                }

                // Immediate Action
                Section("Immediate Action Taken") {
                    TextEditor(text: $immediateAction)
                        .frame(minHeight: 80)
                        .overlay(alignment: .topLeading) {
                            if immediateAction.isEmpty {
                                Text("What was done immediately after the incident?")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 14))
                                    .padding(4)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                // Parent Notification
                Section("Parent / Guardian") {
                    Toggle("Parent / guardian notified", isOn: $parentNotified)
                    if parentNotified {
                        DatePicker("Notified at", selection: $parentNotifiedTime, displayedComponents: .hourAndMinute)
                    }
                }

                // Serious Incident
                Section("Regulatory") {
                    Toggle("Mark as Serious Incident", isOn: $isSerious)
                    if isSerious {
                        Toggle("Ofsted notified", isOn: $ofstedNotified)
                        Toggle("RIDDOR reportable", isOn: $riddorRequired)
                    }
                }

                if category == "safeguarding" {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                                .font(.system(size: 22))
                                .foregroundStyle(.red)
                            Text("Safeguarding concerns must be reported to the Designated Safeguarding Lead immediately. Do not discuss with the parent before consulting the DSL.")
                                .font(.system(size: 12))
                                .foregroundStyle(.red)
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("⚠️ Safeguarding Notice")
                    }
                }
            }
            .navigationTitle("File Incident Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Submit") { save() }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .disabled(incidentDescription.isEmpty || isSaving)
                }
            }
        }
        .frame(minWidth: 540, minHeight: 640)
    }

    private func save() {
        isSaving = true
        let report = IncidentReport(
            childId: child.id,
            childName: child.fullName,
            reportedBy: appState.currentKeyworkerName,
            category: category,
            description: incidentDescription
        )
        report.location = location
        report.immediateAction = immediateAction
        report.witnesses = witnesses
        report.injuryBodyLocation = injuryBodyLocation
        report.parentNotified = parentNotified
        report.parentNotifiedTime = parentNotified ? parentNotifiedTime : nil
        report.isSerious = isSerious
        report.ofstedNotified = ofstedNotified
        report.riddorRequired = riddorRequired
        context.insert(report)
        try? context.save()
        dismiss()
    }
}
