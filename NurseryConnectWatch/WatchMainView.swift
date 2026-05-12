import SwiftUI

struct WatchMainView: View {
    @EnvironmentObject var store: WatchDataStore

    var body: some View {
        TabView {
            NavigationStack { AttendanceSummaryView() }
            NavigationStack { QuickCheckInView() }
            NavigationStack { IncidentAlertsView() }
        }
        .tabViewStyle(.page)
        .environmentObject(store)
    }
}
