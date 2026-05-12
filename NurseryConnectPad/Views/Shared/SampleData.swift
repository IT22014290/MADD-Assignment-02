import SwiftData
import Foundation

enum SampleData {
    static func populate(context: ModelContext) {
        let cal = Calendar.current
        let now = Date()
        let kw = "Dilini Jayasuriya"
        let room = "Sunshine Room"

        // MARK: Children (Sri Lankan names)
        let children: [Child] = [
            makeChild("Amaya Rathnayake",
                      dob: cal.date(byAdding: .month, value: -38, to: now)!,
                      kw: kw, room: room,
                      parent1: ("Chamindi Rathnayake", "0712 345 001", "chamindi@example.lk"),
                      allergens: "Milk,Egg", severity: "allergy",
                      medical: "Mild asthma – salbutamol inhaler on site",
                      send: false),

            makeChild("Dineth Perera",
                      dob: cal.date(byAdding: .month, value: -36, to: now)!,
                      kw: kw, room: room,
                      parent1: ("Ruwan Perera", "0712 345 002", "ruwan@example.lk"),
                      allergens: "", severity: "none",
                      medical: "",
                      send: false),

            makeChild("Senuri Fernando",
                      dob: cal.date(byAdding: .month, value: -44, to: now)!,
                      kw: kw, room: room,
                      parent1: ("Sanduni Fernando", "0712 345 003", "sanduni@example.lk"),
                      allergens: "Peanut,Tree Nuts", severity: "anaphylactic",
                      medical: "EpiPen held by nursery manager – peanut anaphylaxis",
                      send: false),

            makeChild("Kaveen Bandara",
                      dob: cal.date(byAdding: .month, value: -30, to: now)!,
                      kw: kw, room: room,
                      parent1: ("Nimesha Bandara", "0712 345 004", "nimesha@example.lk"),
                      allergens: "", severity: "none",
                      medical: "",
                      send: true),

            makeChild("Tharushi Silva",
                      dob: cal.date(byAdding: .month, value: -50, to: now)!,
                      kw: kw, room: room,
                      parent1: ("Asanka Silva", "0712 345 005", "asanka@example.lk"),
                      allergens: "Gluten", severity: "intolerance",
                      medical: "Coeliac disease – gluten-free meals only",
                      send: false),
        ]

        children[0].isCheckedIn = true
        children[0].checkInTime = cal.date(byAdding: .hour, value: -3, to: now)
        children[0].checkInBy = kw
        children[0].parentTwoName = "Kamal Rathnayake"
        children[0].parentTwoPhone = "0712 345 011"
        children[0].emergencyContactName = "Sudu Nona Rathnayake"
        children[0].emergencyContactPhone = "0712 345 021"
        children[0].emergencyContactRelationship = "Grandmother"
        children[0].nhsNumber = "SL-NIC-0001"
        children[0].gpName = "Dr. Pradeep Weerasinghe"
        children[0].gpPhone = "0112 345 678"
        children[0].eyfsNotes = "Very communicative; responds well to music and story-based activities."

        children[1].isCheckedIn = true
        children[1].checkInTime = cal.date(byAdding: .hour, value: -2, to: now)
        children[1].checkInBy = "Kasun Wijeratne"
        children[1].parentTwoName = "Nilmini Perera"
        children[1].parentTwoPhone = "0712 345 012"
        children[1].emergencyContactName = "Sunil Perera"
        children[1].emergencyContactPhone = "0712 345 022"
        children[1].emergencyContactRelationship = "Uncle"
        children[1].nhsNumber = "SL-NIC-0002"
        children[1].gpName = "Dr. Anoma Liyanage"
        children[1].gpPhone = "0112 345 679"

        children[2].isCheckedIn = true
        children[2].checkInTime = cal.date(byAdding: .hour, value: -4, to: now)
        children[2].checkInBy = kw
        children[2].emergencyContactName = "Priyantha Fernando"
        children[2].emergencyContactPhone = "0712 345 023"
        children[2].emergencyContactRelationship = "Father"
        children[2].nhsNumber = "SL-NIC-0003"
        children[2].gpName = "Dr. Ravi Jayasekara"
        children[2].gpPhone = "0112 345 680"
        children[2].dietaryNotes = "Strictly no peanuts or tree nuts. Check all labels. EpiPen in office."

        children[3].nhsNumber = "SL-NIC-0004"
        children[3].gpName = "Dr. Kumari Seneviratne"
        children[3].gpPhone = "0112 345 681"
        children[3].sendFlag = true
        children[3].eyfsNotes = "Speech and language support in progress. Weekly SALT sessions on Thursdays."

        children[4].isCheckedIn = true
        children[4].checkInTime = cal.date(byAdding: .hour, value: -1, to: now)
        children[4].checkInBy = kw
        children[4].nhsNumber = "SL-NIC-0005"
        children[4].gpName = "Dr. Mahesh Dharmaratne"
        children[4].gpPhone = "0112 345 682"
        children[4].dietaryNotes = "Coeliac – all meals must be certified gluten-free. Check kitchen labels."

        for c in children { context.insert(c) }

        // MARK: Diary Entries
        let activityNotes = [
            "Engaged in watercolour painting – showed excellent colour-mixing skills and focus.",
            "Built a tall tower using foam blocks; counted each block aloud independently.",
            "Led a group role-play activity as 'doctor'; demonstrated empathy and vocabulary.",
            "Completed a simple jigsaw puzzle independently; showed persistence.",
            "Participated in outdoor cricket activity; demonstrated strong gross motor skills.",
            "Listened to a Sinhala folk tale and retold it with expressive gestures.",
            "Created a collage of Sri Lankan fruits and named each one correctly.",
        ]
        let sleepNotes   = ["Slept soundly for 45 minutes – placed on back as per protocol.",
                             "Settled quickly; napped for 30 minutes in cot 3."]
        let mealNotes    = ["Ate most of the rice and curry; drank a full cup of water.",
                             "Enjoyed the hoppers with coconut sambol; good appetite today."]
        let wellbeingNotes = ["Appeared settled and happy throughout the morning session.",
                               "Engaged well with peers; initiated sharing during free play."]
        let milestoneNotes = ["Recognised own name card on the self-registration board – first time!",
                               "Used scissors confidently to cut along a curved line."]

        let allNotes: [(String, [String])] = [
            ("activity",  activityNotes),
            ("sleep",     sleepNotes),
            ("meal",      mealNotes),
            ("wellbeing", wellbeingNotes),
            ("milestone", milestoneNotes),
        ]

        for (idx, child) in children.prefix(4).enumerated() {
            for offset in 0..<7 {
                let (type, notes) = allNotes[offset % allNotes.count]
                let entry = DiaryEntry(
                    childId: child.id,
                    childName: child.fullName,
                    entryType: type,
                    description: notes[offset % notes.count],
                    keyworkerName: idx == 1 ? "Kasun Wijeratne" : kw
                )
                entry.timestamp = cal.date(byAdding: .hour, value: -(offset * 2 + idx * 3), to: now)!
                entry.moodRating = ["Happy", "Very Happy", "Happy", "Okay", "Very Happy"][offset % 5]
                entry.eyfsArea   = [EYFSArea.communication, .expressive, .personalSocial,
                                    .physicalDev, .mathematics, .literacy, .understanding][offset % 7].rawValue
                if type == "sleep" {
                    entry.sleepStart = cal.date(byAdding: .hour, value: -(offset * 2 + idx * 3 + 1), to: now)
                    entry.sleepEnd   = cal.date(byAdding: .minute, value: -((offset * 2 + idx * 3) * 60 - 40), to: now)
                    entry.sleepPosition = "back"
                }
                if type == "meal" {
                    entry.mealType    = "lunch"
                    entry.foodConsumed = ["all", "most", "most", "half", "all"][offset % 5]
                    entry.fluidType   = "water"
                    entry.fluidAmount = [180, 200, 150, 220, 180][offset % 5]
                }
                context.insert(entry)
            }
        }

        // MARK: Incidents
        let incident = IncidentReport(
            childId: children[1].id,
            childName: children[1].fullName,
            reportedBy: "Kasun Wijeratne",
            category: "minor_accident",
            description: "Dineth bumped his head on the corner of the bookcase while running in the reading area. A small red mark was observed but no swelling. Comfort was given and a cold pack applied for five minutes."
        )
        incident.immediateAction = "Cold pack applied for 5 minutes. Child comforted. Parent (Ruwan Perera) notified by telephone at 14:30. Child appeared recovered within 10 minutes."
        incident.location = "Reading corner"
        incident.witnesses = "Kasun Wijeratne (Room Lead)"
        incident.parentNotified = true
        incident.parentNotifiedTime = cal.date(byAdding: .minute, value: -30, to: now)
        context.insert(incident)

        // MARK: EYFS Observations
        let obs1 = EYFSObservation(
            childId: children[0].id, childName: children[0].fullName,
            eyfsArea: .communication, stage: .developing,
            observationText: "Amaya demonstrated excellent listening skills during story time. She predicted story outcomes and used rich descriptive vocabulary when explaining her ideas to the group.",
            nextSteps: "Introduce more complex narratives. Encourage retelling stories in Sinhala and English. Pair with older child for peer storytelling.",
            keyworkerName: kw
        )
        obs1.timestamp = cal.date(byAdding: .day, value: -2, to: now)!
        obs1.isSharedWithParent = true

        let obs2 = EYFSObservation(
            childId: children[0].id, childName: children[0].fullName,
            eyfsArea: .expressive, stage: .secure,
            observationText: "Amaya created a detailed painting of her family in traditional Sri Lankan dress using a wide range of colours. She independently mixed colours to achieve the shades she wanted and narrated her creative process in full sentences.",
            nextSteps: "Explore clay and collage media. Introduce batik-inspired textile art to connect to cultural heritage.",
            keyworkerName: kw
        )
        obs2.timestamp = cal.date(byAdding: .day, value: -5, to: now)!

        let obs3 = EYFSObservation(
            childId: children[2].id, childName: children[2].fullName,
            eyfsArea: .mathematics, stage: .emerging,
            observationText: "Senuri counted objects up to 6 with one-to-one correspondence. She became uncertain beyond this point and needed adult prompting to continue.",
            nextSteps: "Practise counting songs targeting numbers 7–10. Use everyday objects such as cups and plates at snack time for embedded practice.",
            keyworkerName: kw
        )

        let obs4 = EYFSObservation(
            childId: children[3].id, childName: children[3].fullName,
            eyfsArea: .communication, stage: .emerging,
            observationText: "Kaveen used 2-word combinations consistently today: 'more juice', 'big ball'. Initiation of communication with peers has increased compared to last week.",
            nextSteps: "Model 3-word utterances in response. Use PECS cards to support vocabulary expansion. Update SALT therapist at Thursday session.",
            keyworkerName: kw
        )
        obs4.timestamp = cal.date(byAdding: .day, value: -1, to: now)!

        let obs5 = EYFSObservation(
            childId: children[4].id, childName: children[4].fullName,
            eyfsArea: .physicalDev, stage: .secure,
            observationText: "Tharushi demonstrated excellent fine motor skills, threading small beads in a colour pattern of her own design. She worked independently for over 20 minutes – exceptional focus for her age.",
            nextSteps: "Introduce weaving and more complex threading activities. Present pattern extension challenges.",
            keyworkerName: kw
        )
        obs5.timestamp = cal.date(byAdding: .day, value: -3, to: now)!

        for obs in [obs1, obs2, obs3, obs4, obs5] { context.insert(obs) }

        // MARK: Milestones
        let m1 = Milestone(
            childId: children[0].id, childName: children[0].fullName,
            eyfsArea: .literacy, title: "Name recognition",
            description: "Amaya confidently spotted her name card on the self-registration board on first attempt.",
            keyworkerName: kw
        )
        m1.achievedDate = cal.date(byAdding: .day, value: -10, to: now)!
        m1.isSharedWithParent = true

        let m2 = Milestone(
            childId: children[1].id, childName: children[1].fullName,
            eyfsArea: .physicalDev, title: "Uses scissors",
            description: "Dineth successfully cut along a curved line with child-safe scissors, maintaining control throughout.",
            keyworkerName: "Kasun Wijeratne"
        )
        m2.achievedDate = cal.date(byAdding: .day, value: -3, to: now)!

        let m3 = Milestone(
            childId: children[4].id, childName: children[4].fullName,
            eyfsArea: .mathematics, title: "Counts to 20",
            description: "Tharushi counted wooden cubes to 20 with perfect one-to-one correspondence.",
            keyworkerName: kw
        )
        m3.achievedDate = cal.date(byAdding: .day, value: -6, to: now)!
        m3.isSharedWithParent = true

        let m4 = Milestone(
            childId: children[0].id, childName: children[0].fullName,
            eyfsArea: .personalSocial, title: "Shares independently",
            description: "Amaya offered her art materials to a peer without adult prompting – first spontaneous sharing observed.",
            keyworkerName: kw
        )
        m4.achievedDate = cal.date(byAdding: .day, value: -14, to: now)!

        for m in [m1, m2, m3, m4] { context.insert(m) }

        // MARK: Attendance Records (last 10 weekdays)
        for child in children {
            for dayOffset in 1...10 {
                let date = cal.date(byAdding: .day, value: -dayOffset, to: now)!
                if cal.isDateInWeekend(date) { continue }
                let record = AttendanceRecord(childId: child.id, childName: child.fullName)
                record.date = date
                record.checkInTime  = cal.date(bySettingHour: 8, minute: Int.random(in: 0...30), second: 0, of: date)
                record.checkOutTime = cal.date(bySettingHour: 17, minute: Int.random(in: 0...30), second: 0, of: date)
                record.droppedOffBy = child.parentOneName
                record.collectedBy  = child.parentOneName
                context.insert(record)
            }
        }

        // MARK: Meal Records (varied Sri Lankan meals)
        let lunches   = ["Rice and dhal curry", "String hoppers with fish curry", "Kottu roti with vegetables", "Fried rice with chicken", "Pol roti with coconut sambol"]
        let breakfasts = ["Milk rice (kiribath) with treacle", "Porridge with banana", "Bread with butter and jam", "Semolina with milk"]
        let snacks     = ["Fresh papaya slices", "Banana and crackers", "Apple and cheese cubes", "Coconut biscuits"]

        for (cIdx, child) in children.prefix(4).enumerated() {
            for (mIdx, mealType) in ["breakfast", "lunch", "snack"].enumerated() {
                let meal = MealRecord(childId: child.id, childName: child.fullName, mealType: mealType)
                switch mealType {
                case "breakfast": meal.foodOffered = breakfasts[cIdx % breakfasts.count]
                case "lunch":     meal.foodOffered = lunches[cIdx % lunches.count]
                default:          meal.foodOffered = snacks[(cIdx + mIdx) % snacks.count]
                }
                meal.foodConsumed = ["all", "most", "most", "half", "all"][cIdx % 5]
                meal.fluidType    = "water"
                meal.fluidAmount  = Int.random(in: 150...250)
                meal.keyworkerName = kw
                context.insert(meal)
            }
        }
    }

    private static func makeChild(
        _ name: String, dob: Date, kw: String, room: String,
        parent1: (String, String, String),
        allergens: String, severity: String, medical: String,
        send: Bool
    ) -> Child {
        let c = Child(fullName: name, dateOfBirth: dob, keyworkerName: kw, room: room)
        c.parentOneName  = parent1.0
        c.parentOnePhone = parent1.1
        c.parentOneEmail = parent1.2
        c.allergenList   = allergens
        c.allergenSeverity = severity
        c.medicalConditions = medical
        c.sessionTimes   = "07:30 – 17:30"
        c.dietaryRequirements = allergens.isEmpty ? "No specific requirements" : "See allergen list"
        c.sendFlag       = send
        c.photographyConsent = true
        c.dataProcessingConsent = true
        c.medicalTreatmentConsent = true
        return c
    }
}
