import SwiftUI
import SwiftData

struct ChildProfileView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @State private var isEditing = false

    var avatarColor: Color {
        let colors: [Color] = [NurseryTheme.primary, NurseryTheme.teal, NurseryTheme.purple,
                               NurseryTheme.pink, NurseryTheme.orange, NurseryTheme.indigo]
        return colors[abs(child.fullName.hashValue) % colors.count]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Avatar header
                VStack(spacing: 12) {
                    ChildAvatarView(initials: child.initials, color: avatarColor, size: 80)
                    Text(child.fullName)
                        .font(.title2.bold())
                    HStack(spacing: 12) {
                        Text(child.displayAge)
                            .foregroundStyle(NurseryTheme.textSecondary)
                        Text("·")
                            .foregroundStyle(NurseryTheme.textSecondary)
                        Text(child.room)
                            .foregroundStyle(NurseryTheme.textSecondary)
                    }
                    .font(.subheadline)
                    if child.hasAllergens {
                        HStack(spacing: 6) {
                            ForEach(child.allergens, id: \.self) { AllergenTag(allergen: $0) }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .cardStyle()

                // Key info
                profileSection("Personal Details") {
                    InfoRow(label: "Full name", value: child.fullName)
                    InfoRow(label: "Preferred name", value: child.preferredName)
                    InfoRow(label: "Date of birth", value: child.dateOfBirth.mediumDateString)
                    InfoRow(label: "Age", value: child.displayAge)
                    InfoRow(label: "Room", value: child.room)
                    InfoRow(label: "Session times", value: child.sessionTimes)
                    InfoRow(label: "Keyworker", value: child.keyworkerName)
                }

                profileSection("Parent / Guardian") {
                    InfoRow(label: "Parent 1", value: child.parentOneName)
                    InfoRow(label: "Phone", value: child.parentOnePhone)
                    InfoRow(label: "Email", value: child.parentOneEmail)
                    if !child.parentTwoName.isEmpty {
                        InfoRow(label: "Parent 2", value: child.parentTwoName)
                        InfoRow(label: "Phone", value: child.parentTwoPhone)
                    }
                    if !child.emergencyContactName.isEmpty {
                        InfoRow(label: "Emergency contact", value: child.emergencyContactName)
                        InfoRow(label: "Phone", value: child.emergencyContactPhone)
                        InfoRow(label: "Relationship", value: child.emergencyContactRelationship)
                    }
                }

                profileSection("Health & Medical") {
                    InfoRow(label: "NHS number", value: child.nhsNumber.isEmpty ? "Not recorded" : child.nhsNumber)
                    InfoRow(label: "Medical conditions", value: child.medicalConditions.isEmpty ? "None" : child.medicalConditions, valueColor: child.medicalConditions.isEmpty ? NurseryTheme.textPrimary : .orange)
                    InfoRow(label: "Medications", value: child.medications.isEmpty ? "None" : child.medications, valueColor: child.medications.isEmpty ? NurseryTheme.textPrimary : .orange)
                    InfoRow(label: "GP", value: child.gpName)
                    InfoRow(label: "GP phone", value: child.gpPhone)
                }

                profileSection("Diet & Allergens") {
                    InfoRow(label: "Dietary requirements", value: child.dietaryRequirements.isEmpty ? "None" : child.dietaryRequirements)
                    if child.hasAllergens {
                        InfoRow(label: "Allergens", value: child.allergens.joined(separator: ", "), valueColor: .orange)
                        InfoRow(label: "Severity", value: child.allergenSeverity.capitalized, valueColor: child.allergenSeverity == "anaphylactic" ? .red : .orange)
                    } else {
                        InfoRow(label: "Allergens", value: "None known")
                    }
                    if !child.dietaryNotes.isEmpty {
                        InfoRow(label: "Notes", value: child.dietaryNotes)
                    }
                }

                profileSection("Consents") {
                    ConsentRow(label: "Photography", granted: child.photographyConsent)
                    ConsentRow(label: "Social media", granted: child.socialMediaConsent)
                    ConsentRow(label: "GPS / tracking", granted: child.gpsConsent)
                    ConsentRow(label: "Video", granted: child.videoConsent)
                    ConsentRow(label: "Medical treatment", granted: child.medicalTreatmentConsent)
                    ConsentRow(label: "Data processing", granted: child.dataProcessingConsent)
                }

                profileSection("EYFS & Notes") {
                    if child.sendFlag {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(NurseryTheme.purple)
                            Text("SEND flag active")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(NurseryTheme.purple)
                        }
                    }
                    if !child.eyfsNotes.isEmpty {
                        InfoRow(label: "EYFS notes", value: child.eyfsNotes)
                    }
                    if !child.notes.isEmpty {
                        InfoRow(label: "General notes", value: child.notes)
                    }
                    InfoRow(label: "Registered", value: child.registrationDate.mediumDateString)
                }
            }
            .padding(16)
        }
        .background(NurseryTheme.background)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isEditing = true }
                    .keyboardShortcut("e", modifiers: .command)
            }
        }
        .sheet(isPresented: $isEditing) {
            AddChildView(editingChild: child)
        }
    }

    @ViewBuilder
    private func profileSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .sectionHeaderStyle()
            content()
        }
        .cardStyle()
    }
}

// MARK: - Consent Row

private struct ConsentRow: View {
    let label: String
    let granted: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(NurseryTheme.textSecondary)
            Spacer()
            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(granted ? .green : .red)
            Text(granted ? "Granted" : "Not granted")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(granted ? .green : .red)
        }
        .padding(.vertical, 3)
    }
}

// MARK: - Add / Edit Child View

struct AddChildView: View {
    var editingChild: Child? = nil
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var fullName = ""
    @State private var preferredName = ""
    @State private var dob = Date()
    @State private var room = "Sunshine Room"
    @State private var keyworkerName = ""
    @State private var parentOneName = ""
    @State private var parentOnePhone = ""
    @State private var parentOneEmail = ""
    @State private var allergenList = ""
    @State private var allergenSeverity = "none"
    @State private var medicalConditions = ""
    @State private var medications = ""
    @State private var sendFlag = false
    @State private var photographyConsent = true
    @State private var socialMediaConsent = false

    private let rooms = ["Sunshine Room", "Rainbow Room", "Stars Room", "Butterfly Room"]
    private let severities = ["none", "intolerance", "allergy", "anaphylactic"]

    var isEditing: Bool { editingChild != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Details") {
                    TextField("Full name", text: $fullName)
                    TextField("Preferred name", text: $preferredName)
                    DatePicker("Date of birth", selection: $dob, displayedComponents: .date)
                    Picker("Room", selection: $room) {
                        ForEach(rooms, id: \.self) { Text($0).tag($0) }
                    }
                    TextField("Keyworker name", text: $keyworkerName)
                }

                Section("Parent / Guardian") {
                    TextField("Parent / guardian name", text: $parentOneName)
                    TextField("Phone number", text: $parentOnePhone)
                        .keyboardType(.phonePad)
                    TextField("Email address", text: $parentOneEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }

                Section("Health & Allergens") {
                    TextField("Medical conditions (or leave blank)", text: $medicalConditions)
                    TextField("Medications (or leave blank)", text: $medications)
                    TextField("Allergens (comma-separated)", text: $allergenList)
                    Picker("Allergen severity", selection: $allergenSeverity) {
                        ForEach(severities, id: \.self) { Text($0.capitalized).tag($0) }
                    }
                    Toggle("SEND flag", isOn: $sendFlag)
                }

                Section("Consents") {
                    Toggle("Photography consent", isOn: $photographyConsent)
                    Toggle("Social media consent", isOn: $socialMediaConsent)
                }
            }
            .navigationTitle(isEditing ? "Edit Child" : "Add Child")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "Save Changes" : "Add Child") { save() }
                        .buttonStyle(.borderedProminent)
                        .tint(NurseryTheme.primary)
                        .disabled(fullName.isEmpty)
                }
            }
            .onAppear { loadExisting() }
        }
        .frame(minWidth: 480, minHeight: 540)
    }

    private func loadExisting() {
        guard let c = editingChild else {
            keyworkerName = appState.currentKeyworkerName
            room = appState.currentRoom
            return
        }
        fullName = c.fullName
        preferredName = c.preferredName
        dob = c.dateOfBirth
        room = c.room
        keyworkerName = c.keyworkerName
        parentOneName = c.parentOneName
        parentOnePhone = c.parentOnePhone
        parentOneEmail = c.parentOneEmail
        allergenList = c.allergenList
        allergenSeverity = c.allergenSeverity
        medicalConditions = c.medicalConditions
        medications = c.medications
        sendFlag = c.sendFlag
        photographyConsent = c.photographyConsent
        socialMediaConsent = c.socialMediaConsent
    }

    private func save() {
        if let c = editingChild {
            c.fullName = fullName
            c.preferredName = preferredName.isEmpty ? (fullName.components(separatedBy: " ").first ?? fullName) : preferredName
            c.dateOfBirth = dob
            c.room = room
            c.keyworkerName = keyworkerName
            c.parentOneName = parentOneName
            c.parentOnePhone = parentOnePhone
            c.parentOneEmail = parentOneEmail
            c.allergenList = allergenList
            c.allergenSeverity = allergenSeverity
            c.medicalConditions = medicalConditions
            c.medications = medications
            c.sendFlag = sendFlag
            c.photographyConsent = photographyConsent
            c.socialMediaConsent = socialMediaConsent
        } else {
            let child = Child(fullName: fullName, preferredName: preferredName,
                              dateOfBirth: dob, keyworkerName: keyworkerName, room: room)
            child.parentOneName = parentOneName
            child.parentOnePhone = parentOnePhone
            child.parentOneEmail = parentOneEmail
            child.allergenList = allergenList
            child.allergenSeverity = allergenSeverity
            child.medicalConditions = medicalConditions
            child.medications = medications
            child.sendFlag = sendFlag
            child.photographyConsent = photographyConsent
            child.socialMediaConsent = socialMediaConsent
            context.insert(child)
        }
        try? context.save()
        dismiss()
    }
}
