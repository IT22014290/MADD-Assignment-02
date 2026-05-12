import SwiftUI
import SwiftData

// MARK: - App State

@Observable
class AppState {
    var currentKeyworkerName: String {
        didSet { UserDefaults.standard.set(currentKeyworkerName, forKey: "nc_keyworkerName") }
    }
    var currentRoom: String {
        didSet { UserDefaults.standard.set(currentRoom, forKey: "nc_currentRoom") }
    }
    var selectedChildId: UUID? = nil
    var pendingIncidentCount: Int = 0

    init() {
        currentKeyworkerName = UserDefaults.standard.string(forKey: "nc_keyworkerName") ?? "Dilini Jayasuriya"
        currentRoom = UserDefaults.standard.string(forKey: "nc_currentRoom") ?? "Sunshine Room"
    }
}

// MARK: - SwiftData Models

@Model
final class Child {
    var id: UUID = UUID()
    var fullName: String = ""
    var preferredName: String = ""
    var dateOfBirth: Date = Date()
    var keyworkerName: String = ""
    var secondaryKeyworker: String = ""
    var room: String = ""
    var sessionTimes: String = "08:00 – 17:00"
    var parentOneName: String = ""
    var parentOnePhone: String = ""
    var parentOneEmail: String = ""
    var parentTwoName: String = ""
    var parentTwoPhone: String = ""
    var emergencyContactName: String = ""
    var emergencyContactPhone: String = ""
    var emergencyContactRelationship: String = ""
    var nhsNumber: String = ""
    var address: String = ""
    var medicalConditions: String = ""
    var medications: String = ""
    var gpName: String = ""
    var gpPhone: String = ""
    var dietaryRequirements: String = ""
    var allergenList: String = ""
    var allergenSeverity: String = "none"
    var dietaryNotes: String = ""
    var isCheckedIn: Bool = false
    var checkInTime: Date? = nil
    var checkInBy: String = ""
    var isTransportChild: Bool = false
    var school: String = ""
    var photographyConsent: Bool = true
    var socialMediaConsent: Bool = false
    var dataProcessingConsent: Bool = true
    var gpsConsent: Bool = true
    var videoConsent: Bool = false
    var medicalTreatmentConsent: Bool = true
    var eyfsNotes: String = ""
    var sendFlag: Bool = false
    var registrationDate: Date = Date()
    var notes: String = ""
    var authorisedCollectors: String = ""

    init(fullName: String, preferredName: String = "", dateOfBirth: Date,
         keyworkerName: String, room: String) {
        self.id = UUID()
        self.fullName = fullName
        self.preferredName = preferredName.isEmpty
            ? (fullName.components(separatedBy: " ").first ?? fullName)
            : preferredName
        self.dateOfBirth = dateOfBirth
        self.keyworkerName = keyworkerName
        self.room = room
        self.registrationDate = Date()
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    var ageMonths: Int {
        Calendar.current.dateComponents([.month], from: dateOfBirth, to: Date()).month ?? 0
    }

    var displayAge: String {
        let years = age
        let months = ageMonths % 12
        if years == 0 { return "\(months) months" }
        if months == 0 { return "\(years) yr" }
        return "\(years) yr \(months) mo"
    }

    var initials: String {
        let parts = fullName.components(separatedBy: " ")
        return parts.compactMap { $0.first }.prefix(2).map { String($0) }.joined().uppercased()
    }

    var allergens: [String] {
        allergenList.isEmpty ? [] : allergenList.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    var hasAllergens: Bool { !allergenList.isEmpty }
}

@Model
final class DiaryEntry {
    var id: UUID = UUID()
    var childId: UUID = UUID()
    var childName: String = ""
    var timestamp: Date = Date()
    var entryType: String = "activity"
    var entryNote: String = ""
    var duration: Int = 0
    var moodRating: String = ""
    var eyfsArea: String = ""
    var keyworkerName: String = ""
    var isReadByParent: Bool = false
    var sleepStart: Date? = nil
    var sleepEnd: Date? = nil
    var sleepPosition: String = "back"
    var nappyType: String = ""
    var creamApplied: Bool = false
    var mealType: String = ""
    var foodOffered: String = ""
    var foodConsumed: String = ""
    var fluidType: String = ""
    var fluidAmount: Int = 0
    var photoCaption: String = ""

    init(childId: UUID, childName: String, entryType: String,
         description: String, keyworkerName: String) {
        self.id = UUID()
        self.childId = childId
        self.childName = childName
        self.timestamp = Date()
        self.entryType = entryType
        self.entryNote = description
        self.keyworkerName = keyworkerName
    }

    var entryTypeDisplay: String {
        switch entryType {
        case "activity":   return "Activity"
        case "sleep":      return "Sleep / Nap"
        case "nappy":      return "Nappy"
        case "meal":       return "Meal"
        case "wellbeing":  return "Wellbeing"
        case "milestone":  return "Milestone"
        case "photo":      return "Photo"
        case "checkin":    return "Check-In"
        case "checkout":   return "Check-Out"
        default:           return entryType.capitalized
        }
    }

    var entryIcon: String {
        switch entryType {
        case "activity":   return "figure.play"
        case "sleep":      return "moon.fill"
        case "nappy":      return "drop.fill"
        case "meal":       return "fork.knife"
        case "wellbeing":  return "heart.fill"
        case "milestone":  return "star.fill"
        case "photo":      return "camera.fill"
        case "checkin":    return "arrow.right.circle.fill"
        case "checkout":   return "arrow.left.circle.fill"
        default:           return "note.text"
        }
    }

    var entryColor: Color {
        switch entryType {
        case "activity":   return NurseryTheme.teal
        case "sleep":      return NurseryTheme.indigo
        case "nappy":      return NurseryTheme.orange
        case "meal":       return NurseryTheme.primary
        case "wellbeing":  return NurseryTheme.pink
        case "milestone":  return .yellow
        case "photo":      return NurseryTheme.purple
        case "checkin":    return .green
        case "checkout":   return .gray
        default:           return NurseryTheme.primary
        }
    }
}

@Model
final class IncidentReport {
    var id: UUID = UUID()
    var childId: UUID = UUID()
    var childName: String = ""
    var reportedBy: String = ""
    var incidentDate: Date = Date()
    var location: String = ""
    var category: String = "minor_accident"
    var incidentDescription: String = ""
    var immediateAction: String = ""
    var witnesses: String = ""
    var injuryBodyLocation: String = ""
    var status: String = "pending"
    var managerNotes: String = ""
    var managerName: String = ""
    var managerReviewDate: Date? = nil
    var parentNotified: Bool = false
    var parentNotifiedTime: Date? = nil
    var parentAcknowledged: Bool = false
    var parentAcknowledgeDate: Date? = nil
    var isSerious: Bool = false
    var ofstedNotified: Bool = false
    var riddorRequired: Bool = false

    init(childId: UUID, childName: String, reportedBy: String,
         category: String, description: String) {
        self.id = UUID()
        self.childId = childId
        self.childName = childName
        self.reportedBy = reportedBy
        self.incidentDate = Date()
        self.category = category
        self.incidentDescription = description
        self.status = "pending"
    }

    static func categoryLabel(_ key: String) -> String {
        switch key {
        case "minor_accident":    return "Minor Accident"
        case "first_aid":         return "First Aid Required"
        case "safeguarding":      return "Safeguarding Concern"
        case "near_miss":         return "Near Miss"
        case "allergic_reaction": return "Allergic Reaction"
        case "medical":           return "Medical Incident"
        default: return key.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    var categoryDisplay: String { IncidentReport.categoryLabel(category) }

    var severityColor: Color {
        switch category {
        case "safeguarding", "allergic_reaction": return .red
        case "first_aid", "medical":              return .orange
        default:                                  return NurseryTheme.primary
        }
    }

    var statusColor: Color {
        switch status {
        case "pending":   return .orange
        case "reviewed":  return NurseryTheme.primary
        case "finalised": return .green
        default:          return .gray
        }
    }
}

@Model
final class AttendanceRecord {
    var id: UUID = UUID()
    var childId: UUID = UUID()
    var childName: String = ""
    var date: Date = Date()
    var checkInTime: Date? = nil
    var checkOutTime: Date? = nil
    var droppedOffBy: String = ""
    var collectedBy: String = ""
    var collectorRelationship: String = ""
    var isTransportPickup: Bool = false
    var transportPickupTime: Date? = nil
    var notes: String = ""

    init(childId: UUID, childName: String) {
        self.id = UUID()
        self.childId = childId
        self.childName = childName
        self.date = Date()
    }
}

@Model
final class MealRecord {
    var id: UUID = UUID()
    var childId: UUID = UUID()
    var childName: String = ""
    var date: Date = Date()
    var mealType: String = "lunch"
    var foodOffered: String = ""
    var foodConsumed: String = "most"
    var fluidType: String = "water"
    var fluidAmount: Int = 150
    var notes: String = ""
    var keyworkerName: String = ""

    init(childId: UUID, childName: String, mealType: String) {
        self.id = UUID()
        self.childId = childId
        self.childName = childName
        self.date = Date()
        self.mealType = mealType
    }

    var consumptionColor: Color {
        switch foodConsumed {
        case "all", "most":             return .green
        case "half":                    return .orange
        case "little", "none", "refused": return .red
        default:                        return .gray
        }
    }
}
