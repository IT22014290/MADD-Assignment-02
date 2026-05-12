import SwiftUI

@main
struct NurseryConnectWatchApp: App {
    @StateObject private var store = WatchDataStore()

    var body: some Scene {
        WindowGroup {
            WatchMainView()
                .environmentObject(store)
        }
    }
}
