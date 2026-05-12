import SwiftUI
import SwiftData

@main
struct NurseryConnectPadApp: App {
    @State private var appState = AppState()
    @State private var phoneSession = PhoneSessionManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Child.self,
            DiaryEntry.self,
            IncidentReport.self,
            AttendanceRecord.self,
            MealRecord.self,
            EYFSObservation.self,
            Milestone.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let url = config.url
            try? FileManager.default.removeItem(at: url)
            do {
                let fresh = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                return try ModelContainer(for: schema, configurations: [fresh])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(phoneSession)
                .onAppear { seedIfNeeded() }
        }
        .modelContainer(sharedModelContainer)
    }

    private func seedIfNeeded() {
        let ctx = sharedModelContainer.mainContext
        let count = (try? ctx.fetchCount(FetchDescriptor<Child>())) ?? 0
        if count == 0 {
            SampleData.populate(context: ctx)
        }
    }
}
