# NurseryConnect

A nursery management app for iPad with a companion Apple Watch app, built with SwiftUI and SwiftData.

## Overview

NurseryConnect helps nursery keyworkers manage daily childcare operations — tracking attendance, logging diary entries, recording incidents, and monitoring EYFS learning milestones — all from an iPad. The paired Watch app provides quick glanceable summaries and fast check-in without reaching for the iPad.

## Features

### iPad App (NurseryConnectPad)

| Module | Description |
|---|---|
| **Children** | Child profiles with medical info, allergies, consents, and contact details |
| **Attendance** | Check-in / check-out with drop-off and collector logging |
| **Daily Diary** | Activity, sleep, nappy, meal, wellbeing, milestone, and photo entries |
| **Incidents** | Incident reports with severity, status tracking, and Ofsted/RIDDOR flags |
| **EYFS** | Learning journey observations and milestone tracker |
| **Analytics** | Dashboard showing attendance and diary trends |

### Apple Watch App (NurseryConnectWatch)

- **Attendance Summary** — live count of checked-in children
- **Quick Check-In** — mark a child present from the wrist
- **Incident Alerts** — view pending incidents at a glance

## Tech Stack

- **SwiftUI** — declarative UI for iPad and watchOS
- **SwiftData** — persistent local storage (Child, DiaryEntry, IncidentReport, AttendanceRecord, MealRecord, EYFSObservation, Milestone)
- **WatchConnectivity** — syncs state between iPhone/iPad and Apple Watch
- **Xcode 16+**, targeting iPadOS 17+ and watchOS 10+

## Project Structure

```
NurseryConnectPad/
├── Models/
│   ├── DataModels.swift        # SwiftData models + AppState
│   └── EYFSModels.swift        # EYFS observation & milestone models
├── Views/
│   ├── Attendance/             # Check-in/out views
│   ├── Children/               # Child profile and detail tabs
│   ├── Diary/                  # Daily diary feed and entry forms
│   ├── EYFS/                   # Learning journey and milestone tracker
│   ├── Incidents/              # Incident list and new report form
│   ├── Analytics/              # Analytics dashboard
│   ├── Sidebar/                # iPad split-view sidebar
│   └── Shared/                 # Theme, shared components, sample data
└── PhoneSessionManager.swift   # WatchConnectivity bridge

NurseryConnectWatch/
├── WatchMainView.swift         # Root TabView (page style)
├── AttendanceSummaryView.swift
├── QuickCheckInView.swift
├── IncidentAlertsView.swift
└── WatchDataStore.swift        # ObservableObject store for Watch
```

## Screenshots

### iPad

| Dashboard | Attendance | Diary | Incidents |
|---|---|---|---|
| ![](Screenshots/Ipad/Screenshot%202026-05-12%20at%2012.08.05.png) | ![](Screenshots/Ipad/Screenshot%202026-05-12%20at%2012.09.26.png) | ![](Screenshots/Ipad/Screenshot%202026-05-12%20at%2012.09.51.png) | ![](Screenshots/Ipad/Screenshot%202026-05-12%20at%2012.10.10.png) |

### Apple Watch

| Attendance | Quick Check-In | Incidents |
|---|---|---|
| ![](Screenshots/WatchOS/Screenshot%202026-05-12%20at%2012.11.34.png) | ![](Screenshots/WatchOS/Screenshot%202026-05-12%20at%2012.11.46.png) | ![](Screenshots/WatchOS/Screenshot%202026-05-12%20at%2012.12.10.png) |

## Getting Started

1. Clone the repository
2. Open `NurseryConnectPad.xcodeproj` in Xcode 16 or later
3. Select the `NurseryConnectPad` scheme for the iPad app, or `NurseryConnectWatch` for the Watch app
4. Run on an iPad simulator (iPadOS 17+) or a paired physical device with an Apple Watch

Sample data is seeded automatically on first launch.

## Assignment

This project was submitted as Assignment 2 for the Mobile Application Design and Development (MADD) module. See `Assignment2_Report.pdf` for the full design rationale and evaluation.
