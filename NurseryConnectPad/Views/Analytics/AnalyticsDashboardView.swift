import SwiftUI
import SwiftData
import Charts

struct AnalyticsDashboardView: View {
    let child: Child
    @Query private var attendanceRecords: [AttendanceRecord]
    @Query private var diaryEntries: [DiaryEntry]
    @Query private var mealRecords: [MealRecord]
    @Query private var observations: [EYFSObservation]

    init(child: Child) {
        self.child = child
        let childId = child.id
        _attendanceRecords = Query(
            filter: #Predicate<AttendanceRecord> { $0.childId == childId },
            sort: \AttendanceRecord.date, order: .reverse
        )
        _diaryEntries = Query(
            filter: #Predicate<DiaryEntry> { $0.childId == childId },
            sort: \DiaryEntry.timestamp, order: .reverse
        )
        _mealRecords = Query(
            filter: #Predicate<MealRecord> { $0.childId == childId },
            sort: \MealRecord.date, order: .reverse
        )
        _observations = Query(
            filter: #Predicate<EYFSObservation> { $0.childId == childId },
            sort: \EYFSObservation.timestamp, order: .reverse
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Summary stats
                summaryStats

                // Attendance chart
                AttendanceChartView(records: Array(attendanceRecords.prefix(14)))

                // Mood / Wellbeing chart
                MoodChartView(entries: Array(diaryEntries.prefix(20)))

                // Meal chart
                MealChartView(records: Array(mealRecords.prefix(15)))

                // EYFS Coverage chart
                EYFSProgressChartView(observations: Array(observations))
            }
            .padding(16)
        }
        .background(NurseryTheme.background)
    }

    private var summaryStats: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()), GridItem(.flexible()),
            GridItem(.flexible()), GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                title: "Days Attended",
                value: "\(attendanceRecords.count)",
                icon: "calendar.badge.checkmark",
                color: NurseryTheme.primary
            )
            StatCard(
                title: "Diary Entries",
                value: "\(diaryEntries.count)",
                icon: "book.fill",
                color: NurseryTheme.teal
            )
            StatCard(
                title: "Observations",
                value: "\(observations.count)",
                icon: "graduationcap.fill",
                color: NurseryTheme.purple
            )
            let avgMood = moodScore
            StatCard(
                title: "Avg Mood",
                value: avgMood > 0 ? String(format: "%.1f/5", avgMood) : "—",
                icon: "face.smiling.fill",
                color: NurseryTheme.pink
            )
        }
    }

    private var moodScore: Double {
        let moodMap = ["Upset": 1.0, "Unsettled": 2.0, "Okay": 3.0, "Happy": 4.0, "Very Happy": 5.0]
        let rated = diaryEntries.filter { !$0.moodRating.isEmpty }
        guard !rated.isEmpty else { return 0 }
        let total = rated.compactMap { moodMap[$0.moodRating] }.reduce(0, +)
        return total / Double(rated.count)
    }
}

// MARK: - Attendance Chart

struct AttendanceChartView: View {
    let records: [AttendanceRecord]

    struct DailyAttendance: Identifiable {
        let id = UUID()
        let day: String
        let date: Date
        let attended: Bool
    }

    var chartData: [DailyAttendance] {
        let cal = Calendar.current
        return (0..<14).compactMap { offset -> DailyAttendance? in
            guard let date = cal.date(byAdding: .day, value: -offset, to: Date()) else { return nil }
            if cal.isDateInWeekend(date) { return nil }
            let attended = records.contains { cal.isDate($0.date, inSameDayAs: date) }
            return DailyAttendance(day: date.weekdayString, date: date, attended: attended)
        }.reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attendance – Past 2 Weeks")
                .sectionHeaderStyle()

            if chartData.isEmpty {
                Text("No attendance data available.")
                    .font(.subheadline)
                    .foregroundStyle(NurseryTheme.textSecondary)
                    .padding(.vertical, 20)
            } else {
                Chart(chartData) { item in
                    BarMark(
                        x: .value("Day", item.day + "\n" + item.date.dayMonthString),
                        y: .value("Attended", item.attended ? 1 : 0)
                    )
                    .foregroundStyle(item.attended ? NurseryTheme.primary.gradient : Color.gray.opacity(0.2).gradient)
                    .cornerRadius(6)
                }
                .chartYAxis {
                    AxisMarks(values: [0, 1]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text(v == 1 ? "Present" : "Absent")
                                    .font(.system(size: 10))
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                        AxisValueLabel()
                            .font(.system(size: 10))
                    }
                }
                .frame(height: 160)
                .padding(.horizontal, 4)
                .accessibilityLabel("Attendance chart for the past 2 weeks")
            }
        }
        .cardStyle()
    }
}

// MARK: - Mood Chart

struct MoodChartView: View {
    let entries: [DiaryEntry]

    private let moodMap: [String: Int] = [
        "Upset": 1, "Unsettled": 2, "Okay": 3, "Happy": 4, "Very Happy": 5
    ]

    struct MoodPoint: Identifiable {
        let id = UUID()
        let date: Date
        let score: Int
        let label: String
    }

    var chartData: [MoodPoint] {
        entries
            .filter { !$0.moodRating.isEmpty }
            .compactMap { entry in
                guard let score = moodMap[entry.moodRating] else { return nil }
                return MoodPoint(date: entry.timestamp, score: score, label: entry.moodRating)
            }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood & Wellbeing Trend")
                .sectionHeaderStyle()

            if chartData.isEmpty {
                Text("No mood data recorded yet.")
                    .font(.subheadline)
                    .foregroundStyle(NurseryTheme.textSecondary)
                    .padding(.vertical, 20)
            } else {
                Chart(chartData) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Mood", point.score)
                    )
                    .foregroundStyle(NurseryTheme.pink.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Mood", point.score)
                    )
                    .foregroundStyle(NurseryTheme.pink)
                    .symbolSize(36)
                }
                .chartYScale(domain: 1...5)
                .chartYAxis {
                    AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            let labels = ["", "Upset", "Unsettled", "Okay", "Happy", "Very Happy"]
                            if let v = value.as(Int.self), v < labels.count {
                                Text(labels[v]).font(.system(size: 9))
                            }
                        }
                    }
                }
                .frame(height: 160)
                .accessibilityLabel("Mood and wellbeing trend chart")
            }
        }
        .cardStyle()
    }
}

// MARK: - Meal Chart

struct MealChartView: View {
    let records: [MealRecord]

    struct ConsumptionSlice: Identifiable {
        let id = UUID()
        let label: String
        let count: Int
        let color: Color
    }

    var chartData: [ConsumptionSlice] {
        let groups = Dictionary(grouping: records) { $0.foodConsumed }
        let colorMap: [String: Color] = [
            "all": .green, "most": NurseryTheme.teal,
            "half": .yellow, "little": .orange,
            "none": .red, "refused": NurseryTheme.red
        ]
        return groups.map { key, items in
            ConsumptionSlice(
                label: key.capitalized,
                count: items.count,
                color: colorMap[key] ?? .gray
            )
        }.filter { $0.count > 0 }.sorted { $0.count > $1.count }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meal Consumption Breakdown")
                .sectionHeaderStyle()

            if chartData.isEmpty {
                Text("No meal data recorded yet.")
                    .font(.subheadline)
                    .foregroundStyle(NurseryTheme.textSecondary)
                    .padding(.vertical, 20)
            } else {
                HStack(alignment: .center, spacing: 24) {
                    Chart(chartData) { slice in
                        SectorMark(
                            angle: .value("Count", slice.count),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(slice.color.gradient)
                        .cornerRadius(4)
                    }
                    .frame(width: 160, height: 160)

                    // Legend
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(chartData) { slice in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(slice.color)
                                    .frame(width: 10, height: 10)
                                Text(slice.label)
                                    .font(.system(size: 12))
                                    .foregroundStyle(NurseryTheme.textPrimary)
                                Spacer()
                                Text("\(slice.count)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(NurseryTheme.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - EYFS Progress Chart

struct EYFSProgressChartView: View {
    let observations: [EYFSObservation]

    struct AreaCount: Identifiable {
        let id = UUID()
        let area: EYFSArea
        let count: Int
        let secureCount: Int
    }

    var chartData: [AreaCount] {
        EYFSArea.allCases.map { area in
            let areaObs = observations.filter { $0.eyfsAreaRaw == area.rawValue }
            let secure = areaObs.filter { $0.stageRaw == DevelopmentalStage.secure.rawValue }.count
            return AreaCount(area: area, count: areaObs.count, secureCount: secure)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EYFS Area Progress")
                .sectionHeaderStyle()

            Chart(chartData) { item in
                BarMark(
                    x: .value("Area", item.area.shortName),
                    y: .value("Observations", item.count),
                    width: .ratio(0.6)
                )
                .foregroundStyle(item.area.color.opacity(0.3))
                .cornerRadius(4)

                BarMark(
                    x: .value("Area", item.area.shortName),
                    y: .value("Secure", item.secureCount),
                    width: .ratio(0.6)
                )
                .foregroundStyle(item.area.color.gradient)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.system(size: 10))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                    AxisValueLabel().font(.system(size: 10))
                }
            }
            .frame(height: 200)
            .accessibilityLabel("EYFS area progress chart showing observations per learning area")

            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(NurseryTheme.primary.opacity(0.3))
                        .frame(width: 16, height: 10)
                    Text("Total observations").font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                }
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(NurseryTheme.primary)
                        .frame(width: 16, height: 10)
                    Text("Secure stage").font(.system(size: 11)).foregroundStyle(NurseryTheme.textSecondary)
                }
            }
        }
        .cardStyle()
    }
}
