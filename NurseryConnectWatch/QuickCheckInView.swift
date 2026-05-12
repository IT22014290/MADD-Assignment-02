import SwiftUI
import WatchKit

struct QuickCheckInView: View {
    @EnvironmentObject var store: WatchDataStore
    @State private var confirmingId: String? = nil

    var body: some View {
        List(store.children) { child in
            Button {
                confirmingId = child.id
                store.checkIn(childId: child.id)
                WKInterfaceDevice.current().play(.click)
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(child.isCheckedIn ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 28, height: 28)
                        Image(systemName: child.isCheckedIn ? "checkmark" : "person")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(child.preferredName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                        if child.isCheckedIn, let t = child.checkInTime {
                            Text("In \(t, style: .relative) ago")
                                .font(.system(size: 10))
                                .foregroundStyle(.green)
                        } else {
                            Text("Not checked in")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        if child.hasAllergens {
                            Text("⚠ Allergens")
                                .font(.system(size: 9))
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .listRowBackground(
                confirmingId == child.id
                    ? Color.green.opacity(0.15)
                    : Color.clear
            )
        }
        .navigationTitle("Children")
        .listStyle(.plain)
    }
}
