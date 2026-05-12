import SwiftUI

struct AttendanceSummaryView: View {
    @EnvironmentObject var store: WatchDataStore

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header — derived from synced children data
                Text(store.children.first?.room ?? "My Room")
                    .font(.headline)
                    .foregroundStyle(.primary)

                // Big count
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 80, height: 80)
                    VStack(spacing: 2) {
                        Text("\(store.checkedInCount)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.green)
                        Text("of \(store.totalCount)")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }

                Text("Children present")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Divider()

                // Status rows
                HStack {
                    Label("\(store.checkedInCount) in", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.green)
                    Spacer()
                    Label("\(store.totalCount - store.checkedInCount) out", systemImage: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                if store.pendingIncidents > 0 {
                    Divider()
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("\(store.pendingIncidents) pending incident\(store.pendingIncidents > 1 ? "s" : "")")
                            .font(.system(size: 11))
                            .foregroundStyle(.orange)
                    }
                }

                // Allergen warning
                let allergenKids = store.children.filter { $0.isCheckedIn && $0.hasAllergens }
                if !allergenKids.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Allergen Alert", systemImage: "exclamationmark.shield.fill")
                            .font(.caption2)
                            .foregroundStyle(.red)
                        ForEach(allergenKids) { child in
                            Text("⚠ \(child.preferredName)")
                                .font(.system(size: 10))
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Attendance")
    }
}
