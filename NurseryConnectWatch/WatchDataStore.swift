import Foundation
import WatchConnectivity
import Combine

struct WatchChild: Identifiable, Codable {
    let id: String
    var name: String
    var preferredName: String
    var isCheckedIn: Bool
    var checkInTime: Date?
    var room: String
    var hasAllergens: Bool
}

struct WatchIncident: Identifiable, Codable {
    let id: String
    var childName: String
    var category: String
    var status: String
    var date: Date
    var description: String
}

@MainActor
final class WatchDataStore: NSObject, ObservableObject {
    @Published var children: [WatchChild] = []
    @Published var incidents: [WatchIncident] = []
    @Published var isConnected: Bool = false

    override init() {
        super.init()
        loadSampleData()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    var checkedInCount: Int { children.filter(\.isCheckedIn).count }
    var totalCount: Int { children.count }
    var pendingIncidents: Int { incidents.filter { $0.status == "pending" }.count }

    func checkIn(childId: String) {
        if let idx = children.firstIndex(where: { $0.id == childId }) {
            children[idx].isCheckedIn.toggle()
            children[idx].checkInTime = children[idx].isCheckedIn ? Date() : nil
        }
        sendUpdateToPhone()
    }

    private func sendUpdateToPhone() {
        guard WCSession.default.activationState == .activated else { return }
        let checkedIn = children.filter(\.isCheckedIn).map(\.id)
        try? WCSession.default.updateApplicationContext(["checkedIn": checkedIn])
    }

    private func loadSampleData() {
        children = [
            WatchChild(id: "1", name: "Olivia Bennett", preferredName: "Olivia",
                       isCheckedIn: true, checkInTime: Calendar.current.date(byAdding: .hour, value: -3, to: Date()),
                       room: "Sunshine Room", hasAllergens: true),
            WatchChild(id: "2", name: "Noah Clarke", preferredName: "Noah",
                       isCheckedIn: true, checkInTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
                       room: "Sunshine Room", hasAllergens: false),
            WatchChild(id: "3", name: "Amelia Hughes", preferredName: "Amelia",
                       isCheckedIn: true, checkInTime: Calendar.current.date(byAdding: .hour, value: -4, to: Date()),
                       room: "Sunshine Room", hasAllergens: true),
            WatchChild(id: "4", name: "Ethan Patel", preferredName: "Ethan",
                       isCheckedIn: false, checkInTime: nil,
                       room: "Sunshine Room", hasAllergens: false),
            WatchChild(id: "5", name: "Isla Morrison", preferredName: "Isla",
                       isCheckedIn: false, checkInTime: nil,
                       room: "Sunshine Room", hasAllergens: true),
        ]

        incidents = [
            WatchIncident(id: "i1", childName: "Noah Clarke",
                          category: "Minor Accident", status: "pending",
                          date: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
                          description: "Bumped head on bookcase corner."),
        ]
    }
}

// MARK: - WCSessionDelegate

extension WatchDataStore: WCSessionDelegate {
    nonisolated func session(_ session: WCSession,
                             activationDidCompleteWith activationState: WCSessionActivationState,
                             error: Error?) {
        Task { @MainActor in
            isConnected = activationState == .activated
        }
    }

    nonisolated func session(_ session: WCSession,
                             didReceiveApplicationContext applicationContext: [String: Any]) {
        if let payload = applicationContext["childrenData"] as? Data,
           let decoded = try? JSONDecoder().decode([WatchChild].self, from: payload) {
            Task { @MainActor in
                self.children = decoded
            }
        }
        if let payload = applicationContext["incidentsData"] as? Data,
           let decoded = try? JSONDecoder().decode([WatchIncident].self, from: payload) {
            Task { @MainActor in
                self.incidents = decoded
            }
        }
    }

    nonisolated func session(_ session: WCSession,
                             didReceiveMessage message: [String: Any]) {
        if let payload = message["childrenData"] as? Data,
           let decoded = try? JSONDecoder().decode([WatchChild].self, from: payload) {
            Task { @MainActor in
                self.children = decoded
            }
        }
        if let payload = message["incidentsData"] as? Data,
           let decoded = try? JSONDecoder().decode([WatchIncident].self, from: payload) {
            Task { @MainActor in
                self.incidents = decoded
            }
        }
    }
}
