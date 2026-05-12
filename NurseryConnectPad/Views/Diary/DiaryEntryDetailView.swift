import SwiftUI

struct DiaryEntryDetailView: View {
    let entry: DiaryEntry
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header card
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(entry.entryColor.opacity(0.15))
                                .frame(width: 56, height: 56)
                            Image(systemName: entry.entryIcon)
                                .font(.system(size: 26))
                                .foregroundStyle(entry.entryColor)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.entryTypeDisplay)
                                .font(.title3.bold())
                                .foregroundStyle(NurseryTheme.textPrimary)
                            Text(entry.timestamp.mediumDateString + " at " + entry.timestamp.shortTimeString)
                                .font(.subheadline)
                                .foregroundStyle(NurseryTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .cardStyle()

                    // Note
                    if !entry.entryNote.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Observation")
                                .sectionHeaderStyle()
                            Text(entry.entryNote)
                                .font(.system(size: 15))
                                .foregroundStyle(NurseryTheme.textPrimary)
                        }
                        .cardStyle()
                    }

                    // Details grid
                    if !entry.moodRating.isEmpty || !entry.eyfsArea.isEmpty || entry.duration > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Details")
                                .sectionHeaderStyle()
                            if !entry.moodRating.isEmpty {
                                InfoRow(label: "Mood", value: entry.moodRating)
                            }
                            if !entry.eyfsArea.isEmpty {
                                InfoRow(label: "EYFS Area", value: EYFSArea(rawValue: entry.eyfsArea)?.rawValue ?? entry.eyfsArea)
                            }
                            if !entry.keyworkerName.isEmpty {
                                InfoRow(label: "Recorded by", value: entry.keyworkerName)
                            }
                        }
                        .cardStyle()
                    }

                    // Sleep details
                    if entry.entryType == "sleep", let start = entry.sleepStart, let end = entry.sleepEnd {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sleep Record")
                                .sectionHeaderStyle()
                            InfoRow(label: "Start", value: start.shortTimeString)
                            InfoRow(label: "End", value: end.shortTimeString)
                            let mins = Int(end.timeIntervalSince(start) / 60)
                            InfoRow(label: "Duration", value: "\(mins) minutes")
                            InfoRow(label: "Position", value: entry.sleepPosition.capitalized)
                        }
                        .cardStyle()
                    }

                    // Meal details
                    if entry.entryType == "meal" {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meal Record")
                                .sectionHeaderStyle()
                            if !entry.mealType.isEmpty {
                                InfoRow(label: "Meal type", value: entry.mealType.capitalized)
                            }
                            if !entry.foodOffered.isEmpty {
                                InfoRow(label: "Food offered", value: entry.foodOffered)
                            }
                            InfoRow(label: "Consumed", value: entry.foodConsumed.capitalized)
                            InfoRow(label: "Fluid", value: "\(entry.fluidType.capitalized) – \(entry.fluidAmount) ml")
                        }
                        .cardStyle()
                    }

                    // Parent shared indicator
                    HStack {
                        Image(systemName: entry.isReadByParent ? "checkmark.circle.fill" : "clock.circle")
                            .foregroundStyle(entry.isReadByParent ? .green : .secondary)
                        Text(entry.isReadByParent ? "Viewed by parent" : "Not yet viewed by parent")
                            .font(.system(size: 13))
                            .foregroundStyle(entry.isReadByParent ? .green : .secondary)
                    }
                    .padding(.horizontal)
                }
                .padding(16)
            }
            .background(NurseryTheme.background)
            .navigationTitle(entry.childName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete", role: .destructive) {
                        context.delete(entry)
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 480, minHeight: 500)
    }
}
