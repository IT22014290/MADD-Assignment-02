import SwiftUI
import SwiftData

struct AddDiaryEntryView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var entryType = "activity"
    @State private var note = ""
    @State private var moodRating = ""
    @State private var eyfsArea = ""
    @State private var sleepStart = Date()
    @State private var sleepEnd = Date()
    @State private var sleepPosition = "back"
    @State private var nappyType = "wet"
    @State private var creamApplied = false
    @State private var mealType = "lunch"
    @State private var foodOffered = ""
    @State private var foodConsumed = "most"
    @State private var fluidType = "water"
    @State private var fluidAmount: Double = 150
    @State private var isSaving = false

    private let entryTypes = ["activity", "sleep", "meal", "nappy", "wellbeing", "milestone", "photo"]
    private let sleepPositions = ["back", "side", "front"]
    private let nappyTypes = ["wet", "soiled", "both", "dry"]
    private let consumptionOptions = ["all", "most", "half", "little", "none", "refused"]
    private let fluids = ["water", "milk", "juice", "formula"]
    private let mealTypes = ["breakfast", "lunch", "snack", "tea"]

    var body: some View {
        NavigationStack {
            Form {
                // Entry type selector
                Section("Entry Type") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(entryTypes, id: \.self) { type in
                                let dummy = DiaryEntry(childId: child.id, childName: child.fullName,
                                                       entryType: type, description: "", keyworkerName: "")
                                EntryTypeButton(
                                    label: dummy.entryTypeDisplay,
                                    icon: dummy.entryIcon,
                                    color: dummy.entryColor,
                                    isSelected: entryType == type
                                ) {
                                    entryType = type
                                }
                                .accessibilityLabel("\(dummy.entryTypeDisplay) entry type")
                                .accessibilityAddTraits(entryType == type ? .isSelected : [])
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                // Observation / Note
                Section("Observation") {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                        .overlay(alignment: .topLeading) {
                            if note.isEmpty {
                                Text("What happened? What did you observe?")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 14))
                                    .padding(4)
                                    .allowsHitTesting(false)
                            }
                        }
                        .accessibilityLabel("Observation note")
                        .accessibilityHint("Describe what you observed for this entry")
                }

                // Mood
                Section("Mood & Wellbeing") {
                    MoodRatingPicker(rating: $moodRating)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                // EYFS Link
                Section("EYFS Area") {
                    Picker("Link to EYFS Area", selection: $eyfsArea) {
                        Text("None").tag("")
                        ForEach(EYFSArea.allCases, id: \.self) { area in
                            Text(area.rawValue).tag(area.rawValue)
                        }
                    }
                    .accessibilityLabel("Link to EYFS learning area")
                }

                // Type-specific sections
                if entryType == "sleep" { sleepSection }
                if entryType == "nappy" { nappySection }
                if entryType == "meal"  { mealSection  }
            }
            .navigationTitle("New Diary Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { save() }
                        .buttonStyle(.borderedProminent)
                        .tint(NurseryTheme.primary)
                        .disabled(note.isEmpty || isSaving)
                }
            }
        }
        .frame(minWidth: 540, minHeight: 600)
    }

    // MARK: Sleep Section

    @ViewBuilder
    private var sleepSection: some View {
        Section("Sleep Details") {
            DatePicker("Sleep Start", selection: $sleepStart, displayedComponents: .hourAndMinute)
                .accessibilityLabel("Sleep start time")
            DatePicker("Sleep End", selection: $sleepEnd, displayedComponents: .hourAndMinute)
                .accessibilityLabel("Sleep end time")
            Picker("Position", selection: $sleepPosition) {
                ForEach(sleepPositions, id: \.self) { Text($0.capitalized).tag($0) }
            }
            .accessibilityLabel("Sleep position")
        }
    }

    // MARK: Nappy Section

    @ViewBuilder
    private var nappySection: some View {
        Section("Nappy Details") {
            Picker("Type", selection: $nappyType) {
                ForEach(nappyTypes, id: \.self) { Text($0.capitalized).tag($0) }
            }
            .accessibilityLabel("Nappy type")
            Toggle("Cream Applied", isOn: $creamApplied)
                .accessibilityLabel("Cream was applied")
        }
    }

    // MARK: Meal Section

    @ViewBuilder
    private var mealSection: some View {
        Section("Meal Details") {
            Picker("Meal Type", selection: $mealType) {
                ForEach(mealTypes, id: \.self) { Text($0.capitalized).tag($0) }
            }
            .accessibilityLabel("Meal type")

            TextField("Food offered", text: $foodOffered)
                .accessibilityLabel("Food offered")
                .accessibilityHint("Describe what food was offered to the child")

            Picker("Food consumed", selection: $foodConsumed) {
                ForEach(consumptionOptions, id: \.self) { Text($0.capitalized).tag($0) }
            }
            .accessibilityLabel("Amount of food consumed")

            Picker("Fluid type", selection: $fluidType) {
                ForEach(fluids, id: \.self) { Text($0.capitalized).tag($0) }
            }
            .accessibilityLabel("Fluid type")

            // Slider replaces Stepper for richer iPadOS input experience
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Fluid amount")
                        .font(.system(size: 14))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Spacer()
                    Text("\(Int(fluidAmount)) ml")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(NurseryTheme.primary)
                        .frame(minWidth: 60, alignment: .trailing)
                }
                Slider(value: $fluidAmount, in: 0...500, step: 25)
                    .tint(NurseryTheme.primary)
                    .accessibilityLabel("Fluid amount")
                    .accessibilityValue("\(Int(fluidAmount)) millilitres")
                    .accessibilityHint("Drag to set the amount of fluid consumed in millilitres")
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: Save

    private func save() {
        isSaving = true
        let entry = DiaryEntry(
            childId: child.id,
            childName: child.fullName,
            entryType: entryType,
            description: note,
            keyworkerName: appState.currentKeyworkerName
        )
        entry.moodRating = moodRating
        entry.eyfsArea = eyfsArea

        if entryType == "sleep" {
            entry.sleepStart = sleepStart
            entry.sleepEnd = sleepEnd
            entry.sleepPosition = sleepPosition
        }
        if entryType == "nappy" {
            entry.nappyType = nappyType
            entry.creamApplied = creamApplied
        }
        if entryType == "meal" {
            entry.mealType = mealType
            entry.foodOffered = foodOffered
            entry.foodConsumed = foodConsumed
            entry.fluidType = fluidType
            entry.fluidAmount = Int(fluidAmount)
        }
        context.insert(entry)
        try? context.save()
        dismiss()
    }
}

// MARK: - Entry Type Button

private struct EntryTypeButton: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? color : color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(isSelected ? .white : color)
                }
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(isSelected ? color : NurseryTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: 60)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
