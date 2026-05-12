import Foundation
import WatchConnectivity

// Codable payloads that match WatchDataStore's WatchChild / WatchIncident structs exactly.

struct WatchChildPayload: Codable {
    let id: String
    let name: String
    let preferredName: String
    var isCheckedIn: Bool
    var checkInTime: Date?
    let room: String
    let hasAllergens: Bool
}

struct WatchIncidentPayload: Codable {
    let id: String
    let childName: String
    let category: String
    let status: String
    let date: Date
    let description: String
}

// MARK: - PhoneSessionManager

@Observable
final class PhoneSessionManager: NSObject {
    var isWatchReachable = false

    // When the Watch toggles check-in, it sends us the full list of checked-in IDs.
    // RootView observes this and updates SwiftData accordingly.
    var pendingWatchCheckIns: [String] = []

    override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Send children to Watch

    func syncChildren(_ children: [Child]) {
        guard WCSession.default.activationState == .activated else { return }
        let payloads = children.map { c in
            WatchChildPayload(
                id: c.id.uuidString,
                name: c.fullName,
                preferredName: c.preferredName,
                isCheckedIn: c.isCheckedIn,
                checkInTime: c.checkInTime,
                room: c.room,
                hasAllergens: c.hasAllergens
            )
        }
        guard let data = try? JSONEncoder().encode(payloads) else { return }
        try? WCSession.default.updateApplicationContext(["childrenData": data])
    }

    // MARK: - Send incidents to Watch

    func syncIncidents(_ incidents: [IncidentReport]) {
        guard WCSession.default.activationState == .activated else { return }
        let payloads = Array(incidents.prefix(20)).map { i in
            WatchIncidentPayload(
                id: i.id.uuidString,
                childName: i.childName,
                category: i.categoryDisplay,
                status: i.status,
                date: i.incidentDate,
                description: i.incidentDescription
            )
        }
        guard let data = try? JSONEncoder().encode(payloads) else { return }
        // Merge into the existing context so children and incidents travel together.
        var ctx = (try? WCSession.default.applicationContext) ?? [:]
        ctx["incidentsData"] = data
        try? WCSession.default.updateApplicationContext(ctx)
    }
}

// MARK: - WCSessionDelegate

extension PhoneSessionManager: WCSessionDelegate {

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        Task { @MainActor in
            isWatchReachable = activationState == .activated
        }
    }

    // Called when the Watch is deactivated (required on iOS).
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    // Reactivate after Watch switches.
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    // Watch sends back the list of checked-in child IDs after a check-in action.
    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        if let checkedIn = applicationContext["checkedIn"] as? [String] {
            Task { @MainActor in
                pendingWatchCheckIns = checkedIn
            }
        }
    }

    // Accept real-time messages (e.g. watch-side check-in taps).
    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        if let checkedIn = message["checkedIn"] as? [String] {
            Task { @MainActor in
                pendingWatchCheckIns = checkedIn
            }
        }
    }
}
