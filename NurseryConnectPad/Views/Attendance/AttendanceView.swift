import SwiftUI
import SwiftData

struct AttendanceView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @Query private var records: [AttendanceRecord]

    init(child: Child) {
        self.child = child
        let childId = child.id
        _records = Query(
            filter: #Predicate<AttendanceRecord> { $0.childId == childId },
            sort: \AttendanceRecord.date, order: .reverse
        )
    }

    var todayRecord: AttendanceRecord? {
        records.first { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Today's status
                todayStatusCard

                // History
                VStack(alignment: .leading, spacing: 12) {
                    Text("Attendance History")
                        .sectionHeaderStyle()

                    if records.isEmpty {
                        EmptyStateView(
                            icon: "calendar.badge.clock",
                            title: "No records",
                            message: "Attendance history will appear here."
                        )
                    } else {
                        ForEach(records.prefix(20)) { record in
                            AttendanceRecordRow(record: record)
                        }
                    }
                }
                .cardStyle()
            }
            .padding(16)
        }
        .background(NurseryTheme.background)
    }

    // MARK: Today Status Card

    private var todayStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today – " + Date().mediumDateString)
                .sectionHeaderStyle()

            HStack(spacing: 20) {
                // Status indicator
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(child.isCheckedIn ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                            .frame(width: 64, height: 64)
                        Image(systemName: child.isCheckedIn ? "checkmark.circle.fill" : "clock.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(child.isCheckedIn ? .green : .orange)
                    }
                    Text(child.isCheckedIn ? "Present" : "Absent")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(child.isCheckedIn ? .green : .orange)
                }

                Divider().frame(height: 80)

                // Check-in time
                VStack(alignment: .leading, spacing: 6) {
                    if child.isCheckedIn, let t = child.checkInTime {
                        InfoRow(label: "Checked in", value: t.shortTimeString, valueColor: .green)
                        InfoRow(label: "By", value: child.checkInBy.isEmpty ? "Staff" : child.checkInBy)
                    } else {
                        Text("Not yet checked in today.")
                            .font(.subheadline)
                            .foregroundStyle(NurseryTheme.textSecondary)
                    }
                }

                Spacer()

                // Quick toggle
                Button {
                    toggleCheckIn()
                } label: {
                    Label(child.isCheckedIn ? "Check Out" : "Check In",
                          systemImage: child.isCheckedIn ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(child.isCheckedIn ? .orange : .green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background((child.isCheckedIn ? Color.orange : Color.green).opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
        .cardStyle()
    }

    private func toggleCheckIn() {
        if child.isCheckedIn {
            child.isCheckedIn = false
            if let today = todayRecord {
                today.checkOutTime = Date()
            } else {
                let r = AttendanceRecord(childId: child.id, childName: child.fullName)
                r.checkOutTime = Date()
                context.insert(r)
            }
            child.checkInTime = nil
            child.checkInBy = ""
        } else {
            child.isCheckedIn = true
            child.checkInTime = Date()
            child.checkInBy = appState.currentKeyworkerName
            if todayRecord == nil {
                let r = AttendanceRecord(childId: child.id, childName: child.fullName)
                r.checkInTime = Date()
                r.droppedOffBy = child.parentOneName
                context.insert(r)
            }
        }
        try? context.save()
    }
}

// MARK: - Attendance Record Row

private struct AttendanceRecordRow: View {
    let record: AttendanceRecord

    var duration: String {
        guard let `in` = record.checkInTime, let out = record.checkOutTime else { return "—" }
        let mins = Int(out.timeIntervalSince(`in`) / 60)
        let hours = mins / 60
        let remaining = mins % 60
        return "\(hours)h \(remaining)m"
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .center, spacing: 2) {
                Text(record.date.weekdayString)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(NurseryTheme.textSecondary)
                Text(record.date.dayMonthString)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(NurseryTheme.textPrimary)
            }
            .frame(width: 48)

            Divider().frame(height: 40)

            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Arrived")
                        .font(.system(size: 10))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text(record.checkInTime?.shortTimeString ?? "—")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.green)
                }

                Image(systemName: "arrow.right")
                    .foregroundStyle(NurseryTheme.textSecondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Departed")
                        .font(.system(size: 10))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text(record.checkOutTime?.shortTimeString ?? "Still in")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(record.checkOutTime == nil ? .orange : NurseryTheme.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Duration")
                        .font(.system(size: 10))
                        .foregroundStyle(NurseryTheme.textSecondary)
                    Text(duration)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(NurseryTheme.primary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
