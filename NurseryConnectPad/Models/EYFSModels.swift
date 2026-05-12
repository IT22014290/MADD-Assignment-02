import SwiftUI
import SwiftData

// MARK: - EYFS Areas

enum EYFSArea: String, CaseIterable, Codable {
    case communication      = "Communication & Language"
    case physicalDev        = "Physical Development"
    case personalSocial     = "Personal, Social & Emotional"
    case literacy           = "Literacy"
    case mathematics        = "Mathematics"
    case understanding      = "Understanding the World"
    case expressive         = "Expressive Arts & Design"

    var shortName: String {
        switch self {
        case .communication:  return "C&L"
        case .physicalDev:    return "PD"
        case .personalSocial: return "PSED"
        case .literacy:       return "Lit"
        case .mathematics:    return "Maths"
        case .understanding:  return "UW"
        case .expressive:     return "EAD"
        }
    }

    var color: Color {
        switch self {
        case .communication:  return NurseryTheme.teal
        case .physicalDev:    return NurseryTheme.orange
        case .personalSocial: return NurseryTheme.pink
        case .literacy:       return NurseryTheme.primary
        case .mathematics:    return NurseryTheme.purple
        case .understanding:  return NurseryTheme.green
        case .expressive:     return NurseryTheme.indigo
        }
    }

    var icon: String {
        switch self {
        case .communication:  return "bubble.left.and.bubble.right.fill"
        case .physicalDev:    return "figure.run"
        case .personalSocial: return "heart.fill"
        case .literacy:       return "book.fill"
        case .mathematics:    return "numbers"
        case .understanding:  return "globe"
        case .expressive:     return "paintpalette.fill"
        }
    }
}

// MARK: - Developmental Stage

enum DevelopmentalStage: String, CaseIterable, Codable {
    case emerging   = "Emerging"
    case developing = "Developing"
    case secure     = "Secure"

    var color: Color {
        switch self {
        case .emerging:   return .orange
        case .developing: return NurseryTheme.primary
        case .secure:     return .green
        }
    }

    var icon: String {
        switch self {
        case .emerging:   return "circle.dotted"
        case .developing: return "circle.lefthalf.filled"
        case .secure:     return "checkmark.circle.fill"
        }
    }
}

// MARK: - EYFS Observation Model

@Model
final class EYFSObservation {
    var id: UUID = UUID()
    var childId: UUID = UUID()
    var childName: String = ""
    var timestamp: Date = Date()
    var eyfsAreaRaw: String = EYFSArea.communication.rawValue
    var stageRaw: String = DevelopmentalStage.emerging.rawValue
    var observationText: String = ""
    var nextSteps: String = ""
    var keyworkerName: String = ""
    var drawingData: Data? = nil
    var isSharedWithParent: Bool = false

    init(childId: UUID, childName: String, eyfsArea: EYFSArea,
         stage: DevelopmentalStage, observationText: String,
         nextSteps: String = "", keyworkerName: String) {
        self.id = UUID()
        self.childId = childId
        self.childName = childName
        self.timestamp = Date()
        self.eyfsAreaRaw = eyfsArea.rawValue
        self.stageRaw = stage.rawValue
        self.observationText = observationText
        self.nextSteps = nextSteps
        self.keyworkerName = keyworkerName
    }

    var eyfsArea: EYFSArea {
        EYFSArea(rawValue: eyfsAreaRaw) ?? .communication
    }

    var stage: DevelopmentalStage {
        DevelopmentalStage(rawValue: stageRaw) ?? .emerging
    }
}

// MARK: - Milestone Model

@Model
final class Milestone {
    var id: UUID = UUID()
    var childId: UUID = UUID()
    var childName: String = ""
    var achievedDate: Date = Date()
    var eyfsAreaRaw: String = EYFSArea.communication.rawValue
    var title: String = ""
    var milestoneDescription: String = ""
    var keyworkerName: String = ""
    var isSharedWithParent: Bool = false

    init(childId: UUID, childName: String, eyfsArea: EYFSArea,
         title: String, description: String, keyworkerName: String) {
        self.id = UUID()
        self.childId = childId
        self.childName = childName
        self.achievedDate = Date()
        self.eyfsAreaRaw = eyfsArea.rawValue
        self.title = title
        self.milestoneDescription = description
        self.keyworkerName = keyworkerName
    }

    var eyfsArea: EYFSArea {
        EYFSArea(rawValue: eyfsAreaRaw) ?? .communication
    }
}

// MARK: - Suggested Milestones by Area

struct SuggestedMilestone {
    let area: EYFSArea
    let title: String
    let description: String
}

let suggestedMilestones: [SuggestedMilestone] = [
    SuggestedMilestone(area: .communication, title: "First words", description: "Child uses first recognisable words to communicate needs"),
    SuggestedMilestone(area: .communication, title: "Two-word phrases", description: "Combining two words to express an idea"),
    SuggestedMilestone(area: .physicalDev, title: "Independent walking", description: "Walking confidently without support"),
    SuggestedMilestone(area: .physicalDev, title: "Uses scissors", description: "Can use scissors with one hand to cut along a line"),
    SuggestedMilestone(area: .personalSocial, title: "Shares with peers", description: "Takes turns and shares toys with other children"),
    SuggestedMilestone(area: .personalSocial, title: "Self-care skills", description: "Attempts to dress/undress independently"),
    SuggestedMilestone(area: .literacy, title: "Name recognition", description: "Recognises own name in print"),
    SuggestedMilestone(area: .literacy, title: "Initial sounds", description: "Identifies initial sound of own name"),
    SuggestedMilestone(area: .mathematics, title: "Counts to 10", description: "Counts objects to 10 with one-to-one correspondence"),
    SuggestedMilestone(area: .mathematics, title: "Shape recognition", description: "Names circle, square, triangle, and rectangle"),
    SuggestedMilestone(area: .understanding, title: "Seasonal awareness", description: "Talks about differences between seasons"),
    SuggestedMilestone(area: .expressive, title: "Role play", description: "Engages in imaginative role-play scenarios"),
]
