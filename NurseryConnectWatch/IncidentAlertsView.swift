import SwiftUI

struct IncidentAlertsView: View {
    @EnvironmentObject var store: WatchDataStore

    var pendingIncidents: [WatchIncident] {
        store.incidents.filter { $0.status == "pending" }
    }

    var body: some View {
        Group {
            if store.incidents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.green)
                    Text("No incidents")
                        .font(.headline)
                    Text("All clear")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                List(store.incidents) { incident in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Circle()
                                .fill(incident.status == "pending" ? Color.orange : Color.green)
                                .frame(width: 8, height: 8)
                            Text(incident.category)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(incident.status == "pending" ? .orange : .green)
                        }

                        Text(incident.childName)
                            .font(.system(size: 13, weight: .bold))

                        Text(incident.description)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)

                        Text(incident.date, style: .relative)
                            .font(.system(size: 9))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Incidents")
    }
}
