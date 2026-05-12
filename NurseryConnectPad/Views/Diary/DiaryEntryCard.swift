import SwiftUI

struct DiaryEntryCard: View {
    let entry: DiaryEntry

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline dot + line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(entry.entryColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: entry.entryIcon)
                        .font(.system(size: 16))
                        .foregroundStyle(entry.entryColor)
                }
                Rectangle()
                    .fill(entry.entryColor.opacity(0.2))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .padding(.top, 4)
            }
            .frame(width: 36)

            // Content card
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entry.entryTypeDisplay)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(entry.entryColor)
                    Spacer()
                    Text(entry.timestamp.shortTimeString)
                        .font(.system(size: 12))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    if entry.isReadByParent {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.green)
                    }
                }

                if !entry.entryNote.isEmpty {
                    Text(entry.entryNote)
                        .font(.system(size: 14))
                        .foregroundStyle(NurseryTheme.textPrimary)
                        .lineLimit(3)
                }

                // Extra detail chips
                HStack(spacing: 8) {
                    if !entry.moodRating.isEmpty {
                        DetailChip(icon: "face.smiling", text: entry.moodRating, color: NurseryTheme.pink)
                    }
                    if !entry.eyfsArea.isEmpty {
                        DetailChip(icon: "graduationcap", text: (EYFSArea(rawValue: entry.eyfsArea)?.shortName ?? ""), color: NurseryTheme.purple)
                    }
                    if entry.entryType == "sleep", let start = entry.sleepStart, let end = entry.sleepEnd {
                        let mins = Int(end.timeIntervalSince(start) / 60)
                        DetailChip(icon: "moon.fill", text: "\(mins) min", color: NurseryTheme.indigo)
                    }
                    if entry.entryType == "meal" && !entry.foodConsumed.isEmpty {
                        DetailChip(icon: "fork.knife", text: entry.foodConsumed.capitalized, color: NurseryTheme.teal)
                    }
                }

                HStack {
                    Text(entry.keyworkerName)
                        .font(.system(size: 11))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Spacer()
                    if entry.timestamp.isToday {
                        Text(entry.timestamp.timeAgoString)
                            .font(.system(size: 11))
                            .foregroundStyle(NurseryTheme.textSecondary)
                    } else {
                        Text(entry.timestamp.dayMonthString)
                            .font(.system(size: 11))
                            .foregroundStyle(NurseryTheme.textSecondary)
                    }
                }
            }
            .cardStyle(padding: 12)
        }
    }
}

private struct DetailChip: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11, weight: .medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}
