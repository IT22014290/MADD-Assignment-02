import Testing
import SwiftUI
import SwiftData
import Foundation
@testable import NurseryConnectPad

// MARK: - Helpers

@MainActor
private func makeContainer() throws -> ModelContainer {
    let schema = Schema([
        Child.self, DiaryEntry.self, IncidentReport.self,
        AttendanceRecord.self, MealRecord.self, EYFSObservation.self, Milestone.self
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [config])
}

private func dob(yearsAgo: Int) -> Date {
    Calendar.current.date(byAdding: .year, value: -yearsAgo, to: Date())!
}

private func dob(monthsAgo: Int) -> Date {
    Calendar.current.date(byAdding: .month, value: -monthsAgo, to: Date())!
}

// MARK: - Child Model Tests

@MainActor
struct ChildModelTests {

    @Test func childCreationSetsDefaults() throws {
        let child = Child(fullName: "Amaya Ratnayake", dateOfBirth: dob(yearsAgo: 3),
                         keyworkerName: "Dilini", room: "Sunshine Room")
        #expect(child.fullName == "Amaya Ratnayake")
        #expect(child.preferredName == "Amaya")
        #expect(child.room == "Sunshine Room")
        #expect(child.isCheckedIn == false)
        #expect(child.checkInTime == nil)
        #expect(child.sendFlag == false)
        #expect(child.photographyConsent == true)
    }

    @Test func childPreferredNameCustom() throws {
        let child = Child(fullName: "Noah Clarke", preferredName: "Nono",
                         dateOfBirth: dob(yearsAgo: 2), keyworkerName: "Dilini", room: "Rainbow Room")
        #expect(child.preferredName == "Nono")
    }

    @Test func childInitialsTwoWords() throws {
        let child = Child(fullName: "Amaya Ratnayake", dateOfBirth: dob(yearsAgo: 3),
                         keyworkerName: "K", room: "R")
        #expect(child.initials == "AR")
    }

    @Test func childInitialsSingleName() throws {
        let child = Child(fullName: "Amaya", dateOfBirth: dob(yearsAgo: 2),
                         keyworkerName: "K", room: "R")
        #expect(child.initials == "A")
    }

    @Test func childAgeYearsOnly() throws {
        let child = Child(fullName: "Test Child", dateOfBirth: dob(yearsAgo: 4),
                         keyworkerName: "K", room: "R")
        #expect(child.age == 4)
    }

    @Test func childDisplayAgeUnderOneYear() throws {
        let child = Child(fullName: "Baby", dateOfBirth: dob(monthsAgo: 7),
                         keyworkerName: "K", room: "R")
        #expect(child.displayAge.contains("months"))
    }

    @Test func childDisplayAgeOverOneYear() throws {
        let child = Child(fullName: "Toddler", dateOfBirth: dob(yearsAgo: 2),
                         keyworkerName: "K", room: "R")
        #expect(child.displayAge.contains("yr"))
    }

    @Test func childAllergenParsing() throws {
        let child = Child(fullName: "Isla", dateOfBirth: dob(yearsAgo: 3),
                         keyworkerName: "K", room: "R")
        child.allergenList = "Nuts, Dairy, Eggs"
        #expect(child.hasAllergens == true)
        #expect(child.allergens.count == 3)
        #expect(child.allergens.contains("Nuts"))
        #expect(child.allergens.contains("Dairy"))
    }

    @Test func childNoAllergens() throws {
        let child = Child(fullName: "Ethan", dateOfBirth: dob(yearsAgo: 2),
                         keyworkerName: "K", room: "R")
        #expect(child.hasAllergens == false)
        #expect(child.allergens.isEmpty)
    }

    @Test func childCheckIn() throws {
        let child = Child(fullName: "Test", dateOfBirth: dob(yearsAgo: 3),
                         keyworkerName: "K", room: "R")
        child.isCheckedIn = true
        child.checkInTime = Date()
        child.checkInBy = "Dilini"
        #expect(child.isCheckedIn == true)
        #expect(child.checkInTime != nil)
        #expect(child.checkInBy == "Dilini")
    }

    @Test func childSwiftDataInsert() throws {
        let container = try makeContainer()
        let ctx = container.mainContext
        let child = Child(fullName: "DB Child", dateOfBirth: dob(yearsAgo: 2),
                         keyworkerName: "K", room: "R")
        ctx.insert(child)
        try ctx.save()
        let fetched = try ctx.fetch(FetchDescriptor<Child>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.fullName == "DB Child")
    }
}

// MARK: - DiaryEntry Model Tests

@MainActor
struct DiaryEntryModelTests {

    @Test func diaryEntryCreation() throws {
        let entry = DiaryEntry(childId: UUID(), childName: "Amaya",
                               entryType: "activity", description: "Painted a picture",
                               keyworkerName: "Dilini")
        #expect(entry.entryType == "activity")
        #expect(entry.entryNote == "Painted a picture")
        #expect(entry.keyworkerName == "Dilini")
        #expect(entry.isReadByParent == false)
    }

    @Test func diaryEntryTypeDisplayValues() throws {
        let types: [(String, String)] = [
            ("activity", "Activity"), ("sleep", "Sleep / Nap"),
            ("nappy", "Nappy"), ("meal", "Meal"),
            ("wellbeing", "Wellbeing"), ("milestone", "Milestone"),
            ("photo", "Photo"), ("checkin", "Check-In"), ("checkout", "Check-Out")
        ]
        for (raw, expected) in types {
            let e = DiaryEntry(childId: UUID(), childName: "C", entryType: raw,
                               description: "", keyworkerName: "K")
            #expect(e.entryTypeDisplay == expected)
        }
    }

    @Test func diaryEntryMealFields() throws {
        let entry = DiaryEntry(childId: UUID(), childName: "Noah",
                               entryType: "meal", description: "Lunch",
                               keyworkerName: "Dilini")
        entry.mealType = "lunch"
        entry.foodOffered = "Rice and vegetables"
        entry.foodConsumed = "most"
        entry.fluidType = "water"
        entry.fluidAmount = 200
        #expect(entry.foodOffered == "Rice and vegetables")
        #expect(entry.fluidAmount == 200)
        #expect(entry.foodConsumed == "most")
    }

    @Test func diaryEntrySleepFields() throws {
        let start = Date()
        let end = Calendar.current.date(byAdding: .hour, value: 1, to: start)!
        let entry = DiaryEntry(childId: UUID(), childName: "C", entryType: "sleep",
                               description: "", keyworkerName: "K")
        entry.sleepStart = start
        entry.sleepEnd = end
        entry.sleepPosition = "back"
        #expect(entry.sleepPosition == "back")
        #expect(entry.sleepStart != nil)
    }
}

// MARK: - IncidentReport Model Tests

@MainActor
struct IncidentReportModelTests {

    @Test func incidentCreation() throws {
        let id = UUID()
        let report = IncidentReport(childId: id, childName: "Noah",
                                    reportedBy: "Dilini",
                                    category: "minor_accident",
                                    description: "Bumped head")
        #expect(report.childName == "Noah")
        #expect(report.reportedBy == "Dilini")
        #expect(report.status == "pending")
        #expect(report.isSerious == false)
        #expect(report.parentNotified == false)
    }

    @Test func incidentCategoryLabels() throws {
        let cases: [(String, String)] = [
            ("minor_accident", "Minor Accident"),
            ("first_aid", "First Aid Required"),
            ("safeguarding", "Safeguarding Concern"),
            ("near_miss", "Near Miss"),
            ("allergic_reaction", "Allergic Reaction"),
            ("medical", "Medical Incident")
        ]
        for (key, expected) in cases {
            #expect(IncidentReport.categoryLabel(key) == expected)
        }
    }

    @Test func incidentStatusUpdate() throws {
        let report = IncidentReport(childId: UUID(), childName: "Child",
                                    reportedBy: "K", category: "minor_accident",
                                    description: "Test")
        report.status = "reviewed"
        report.managerNotes = "Reviewed — no further action needed."
        report.managerName = "Manager Name"
        report.managerReviewDate = Date()
        #expect(report.status == "reviewed")
        #expect(!report.managerNotes.isEmpty)
        #expect(report.managerReviewDate != nil)
    }

    @Test func incidentSeriousFlagsOfsted() throws {
        let report = IncidentReport(childId: UUID(), childName: "Child",
                                    reportedBy: "K", category: "safeguarding",
                                    description: "Concern raised")
        report.isSerious = true
        report.ofstedNotified = true
        report.riddorRequired = false
        #expect(report.isSerious == true)
        #expect(report.ofstedNotified == true)
        #expect(report.riddorRequired == false)
    }
}

// MARK: - AttendanceRecord Model Tests

@MainActor
struct AttendanceRecordModelTests {

    @Test func attendanceRecordCreation() throws {
        let id = UUID()
        let record = AttendanceRecord(childId: id, childName: "Amaya")
        #expect(record.childName == "Amaya")
        #expect(record.childId == id)
        #expect(record.checkInTime == nil)
        #expect(record.checkOutTime == nil)
    }

    @Test func attendanceRecordCheckOut() throws {
        let record = AttendanceRecord(childId: UUID(), childName: "Noah")
        let now = Date()
        record.checkOutTime = now
        record.collectedBy = "Parent"
        #expect(record.checkOutTime != nil)
        #expect(record.collectedBy == "Parent")
    }
}

// MARK: - EYFSObservation Model Tests

@MainActor
struct EYFSObservationModelTests {

    @Test func observationCreation() throws {
        let obs = EYFSObservation(
            childId: UUID(), childName: "Amaya",
            eyfsArea: .communication, stage: .developing,
            observationText: "Child used two-word phrases effectively.",
            nextSteps: "Encourage three-word sentences.",
            keyworkerName: "Dilini"
        )
        #expect(obs.eyfsArea == .communication)
        #expect(obs.stage == .developing)
        #expect(obs.observationText == "Child used two-word phrases effectively.")
        #expect(obs.isSharedWithParent == false)
    }

    @Test func observationAllAreas() throws {
        for area in EYFSArea.allCases {
            let obs = EYFSObservation(
                childId: UUID(), childName: "C", eyfsArea: area,
                stage: .secure, observationText: "Test", keyworkerName: "K"
            )
            #expect(obs.eyfsArea == area)
            #expect(!area.shortName.isEmpty)
            #expect(!area.icon.isEmpty)
        }
    }

    @Test func observationAllStages() throws {
        for stage in DevelopmentalStage.allCases {
            let obs = EYFSObservation(
                childId: UUID(), childName: "C", eyfsArea: .literacy,
                stage: stage, observationText: "Test", keyworkerName: "K"
            )
            #expect(obs.stage == stage)
            #expect(!stage.icon.isEmpty)
        }
    }

    @Test func observationDrawingDataRoundTrip() throws {
        let obs = EYFSObservation(
            childId: UUID(), childName: "C", eyfsArea: .expressive,
            stage: .emerging, observationText: "Test", keyworkerName: "K"
        )
        let fakeData = Data([0x01, 0x02, 0x03])
        obs.drawingData = fakeData
        #expect(obs.drawingData == fakeData)
    }
}

// MARK: - Milestone Model Tests

@MainActor
struct MilestoneModelTests {

    @Test func milestoneCreation() throws {
        let ms = Milestone(
            childId: UUID(), childName: "Amaya",
            eyfsArea: .mathematics,
            title: "Counts to 10",
            description: "Counts objects 1-10 with one-to-one correspondence",
            keyworkerName: "Dilini"
        )
        #expect(ms.title == "Counts to 10")
        #expect(ms.eyfsArea == .mathematics)
        #expect(ms.isSharedWithParent == false)
    }
}

// MARK: - MealRecord Model Tests

@MainActor
struct MealRecordModelTests {

    @Test func mealRecordCreation() throws {
        let meal = MealRecord(childId: UUID(), childName: "Amaya", mealType: "lunch")
        #expect(meal.mealType == "lunch")
        #expect(meal.foodConsumed == "most")
        #expect(meal.fluidAmount == 150)
    }

    @Test func mealConsumptionColors() throws {
        let greenCases = ["all", "most"]
        let orangeCases = ["half"]
        let redCases = ["little", "none", "refused"]

        for consumed in greenCases {
            let m = MealRecord(childId: UUID(), childName: "C", mealType: "lunch")
            m.foodConsumed = consumed
            #expect(m.consumptionColor == .green)
        }
        for consumed in orangeCases {
            let m = MealRecord(childId: UUID(), childName: "C", mealType: "lunch")
            m.foodConsumed = consumed
            #expect(m.consumptionColor == .orange)
        }
        for consumed in redCases {
            let m = MealRecord(childId: UUID(), childName: "C", mealType: "lunch")
            m.foodConsumed = consumed
            #expect(m.consumptionColor == .red)
        }
    }
}

// MARK: - AppState Tests

struct AppStateTests {

    @Test func appStateDefaultValues() throws {
        UserDefaults.standard.removeObject(forKey: "nc_keyworkerName")
        UserDefaults.standard.removeObject(forKey: "nc_currentRoom")
        let state = AppState()
        #expect(!state.currentKeyworkerName.isEmpty)
        #expect(!state.currentRoom.isEmpty)
    }

    @Test func appStatePersistsKeyworkerName() throws {
        let state = AppState()
        state.currentKeyworkerName = "Test Keyworker"
        let saved = UserDefaults.standard.string(forKey: "nc_keyworkerName")
        #expect(saved == "Test Keyworker")
        UserDefaults.standard.removeObject(forKey: "nc_keyworkerName")
    }

    @Test func appStatePersistsRoom() throws {
        let state = AppState()
        state.currentRoom = "Rainbow Room"
        let saved = UserDefaults.standard.string(forKey: "nc_currentRoom")
        #expect(saved == "Rainbow Room")
        UserDefaults.standard.removeObject(forKey: "nc_currentRoom")
    }
}

// MARK: - Multi-Child Data Isolation Tests

@MainActor
struct DataIsolationTests {

    @Test func multipleChildrenInserted() throws {
        let container = try makeContainer()
        let ctx = container.mainContext

        let names = ["Amaya Ratnayake", "Noah Clarke", "Isla Morrison", "Ethan Patel"]
        for name in names {
            let child = Child(fullName: name, dateOfBirth: dob(yearsAgo: 3),
                             keyworkerName: "Dilini", room: "Sunshine Room")
            ctx.insert(child)
        }
        try ctx.save()

        let fetched = try ctx.fetch(FetchDescriptor<Child>())
        #expect(fetched.count == names.count)
    }

    @Test func diaryEntriesFilteredByChild() throws {
        let container = try makeContainer()
        let ctx = container.mainContext

        let id1 = UUID()
        let id2 = UUID()

        let e1 = DiaryEntry(childId: id1, childName: "Child A", entryType: "activity",
                            description: "Art", keyworkerName: "K")
        let e2 = DiaryEntry(childId: id1, childName: "Child A", entryType: "meal",
                            description: "Lunch", keyworkerName: "K")
        let e3 = DiaryEntry(childId: id2, childName: "Child B", entryType: "sleep",
                            description: "Nap", keyworkerName: "K")

        ctx.insert(e1); ctx.insert(e2); ctx.insert(e3)
        try ctx.save()

        let pred = #Predicate<DiaryEntry> { $0.childId == id1 }
        let child1Entries = try ctx.fetch(FetchDescriptor<DiaryEntry>(predicate: pred))
        #expect(child1Entries.count == 2)
    }

    @Test func incidentFilteredByChild() throws {
        let container = try makeContainer()
        let ctx = container.mainContext

        let id1 = UUID()
        let id2 = UUID()

        let r1 = IncidentReport(childId: id1, childName: "A", reportedBy: "K",
                                category: "minor_accident", description: "Bump")
        let r2 = IncidentReport(childId: id2, childName: "B", reportedBy: "K",
                                category: "near_miss", description: "Nearly fell")
        ctx.insert(r1); ctx.insert(r2)
        try ctx.save()

        let pred = #Predicate<IncidentReport> { $0.childId == id1 }
        let results = try ctx.fetch(FetchDescriptor<IncidentReport>(predicate: pred))
        #expect(results.count == 1)
        #expect(results.first?.childName == "A")
    }
}
