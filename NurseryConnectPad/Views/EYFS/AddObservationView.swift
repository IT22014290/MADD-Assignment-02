import SwiftUI
import PencilKit
import SwiftData

struct AddObservationView: View {
    let child: Child
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var selectedArea: EYFSArea = .communication
    @State private var selectedStage: DevelopmentalStage = .emerging
    @State private var observationText = ""
    @State private var nextSteps = ""
    @State private var shareWithParent = false
    @State private var showCanvas = false
    @State private var drawing = PKDrawing()
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                // EYFS Area
                Section("EYFS Area") {
                    Picker("Area", selection: $selectedArea) {
                        ForEach(EYFSArea.allCases, id: \.self) { area in
                            Label(area.rawValue, systemImage: area.icon)
                                .tag(area)
                        }
                    }
                    .pickerStyle(.menu)

                    // Stage picker with visual indicators
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Developmental Stage")
                            .font(.system(size: 14))
                            .foregroundStyle(NurseryTheme.textSecondary)
                        HStack(spacing: 10) {
                            ForEach(DevelopmentalStage.allCases, id: \.self) { stage in
                                StageButton(stage: stage, isSelected: selectedStage == stage) {
                                    selectedStage = stage
                                }
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))
                }

                // Observation text
                Section("Observation") {
                    TextEditor(text: $observationText)
                        .frame(minHeight: 120)
                        .overlay(alignment: .topLeading) {
                            if observationText.isEmpty {
                                Text("Describe what you observed. What did the child do, say, or create?")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 14))
                                    .padding(4)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                // Next Steps
                Section("Next Steps") {
                    TextEditor(text: $nextSteps)
                        .frame(minHeight: 80)
                        .overlay(alignment: .topLeading) {
                            if nextSteps.isEmpty {
                                Text("How will you extend this learning?")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 14))
                                    .padding(4)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                // PencilKit Annotation
                Section {
                    Button {
                        showCanvas.toggle()
                    } label: {
                        HStack {
                            Image(systemName: drawing.strokes.isEmpty ? "pencil.tip.crop.circle" : "pencil.tip.crop.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(NurseryTheme.purple)
                            Text(drawing.strokes.isEmpty ? "Add Drawing Annotation" : "Edit Drawing Annotation")
                                .foregroundStyle(NurseryTheme.textPrimary)
                            Spacer()
                            if !drawing.strokes.isEmpty {
                                StatusBadge(text: "Drawing added", color: NurseryTheme.purple)
                            }
                        }
                    }

                    if showCanvas {
                        PKCanvasViewRepresentable(drawing: $drawing)
                            .frame(height: 240)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(NurseryTheme.purple.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    drawing = PKDrawing()
                                } label: {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(.red.opacity(0.7))
                                }
                                .padding(8)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    }
                } header: {
                    Text("Drawing Annotation (Apple Pencil)")
                }

                // Options
                Section("Options") {
                    Toggle("Share with parent", isOn: $shareWithParent)
                }
            }
            .navigationTitle("New EYFS Observation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") { save() }
                        .buttonStyle(.borderedProminent)
                        .tint(NurseryTheme.purple)
                        .disabled(observationText.isEmpty || isSaving)
                }
            }
        }
        .frame(minWidth: 540, minHeight: 640)
    }

    private func save() {
        isSaving = true
        let obs = EYFSObservation(
            childId: child.id,
            childName: child.fullName,
            eyfsArea: selectedArea,
            stage: selectedStage,
            observationText: observationText,
            nextSteps: nextSteps,
            keyworkerName: appState.currentKeyworkerName
        )
        obs.isSharedWithParent = shareWithParent
        if !drawing.strokes.isEmpty {
            obs.drawingData = try? drawing.dataRepresentation()
        }
        context.insert(obs)
        try? context.save()
        dismiss()
    }
}

// MARK: - Stage Button

private struct StageButton: View {
    let stage: DevelopmentalStage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: stage.icon)
                    .font(.system(size: 14))
                Text(stage.rawValue)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(isSelected ? .white : stage.color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? stage.color : stage.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - PKCanvasView Representable

struct PKCanvasViewRepresentable: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.drawingPolicy = .anyInput
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.delegate = context.coordinator

        let picker = PKToolPicker()
        picker.setVisible(true, forFirstResponder: canvas)
        picker.addObserver(canvas)
        context.coordinator.toolPicker = picker

        DispatchQueue.main.async { canvas.becomeFirstResponder() }
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing.dataRepresentation() != (try? drawing.dataRepresentation()) {
            uiView.drawing = drawing
        }
        context.coordinator.toolPicker?.setVisible(true, forFirstResponder: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        var toolPicker: PKToolPicker?

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

// MARK: - Observation Detail View

struct ObservationDetailView: View {
    let observation: EYFSObservation
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var drawing: PKDrawing = PKDrawing()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(observation.eyfsArea.color.opacity(0.15))
                                .frame(width: 56, height: 56)
                            Image(systemName: observation.eyfsArea.icon)
                                .font(.system(size: 24))
                                .foregroundStyle(observation.eyfsArea.color)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(observation.eyfsArea.rawValue)
                                .font(.title3.bold())
                            HStack(spacing: 8) {
                                StatusBadge(text: observation.stage.rawValue, color: observation.stage.color)
                                Text(observation.timestamp.mediumDateString)
                                    .font(.subheadline)
                                    .foregroundStyle(NurseryTheme.textSecondary)
                            }
                        }
                        Spacer()
                    }
                    .cardStyle()

                    // Observation text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Observation")
                            .sectionHeaderStyle()
                        Text(observation.observationText)
                            .font(.system(size: 15))
                    }
                    .cardStyle()

                    // Next steps
                    if !observation.nextSteps.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Next Steps")
                                .sectionHeaderStyle()
                            Text(observation.nextSteps)
                                .font(.system(size: 15))
                                .foregroundStyle(NurseryTheme.textPrimary)
                        }
                        .cardStyle()
                    }

                    // Drawing
                    if let data = observation.drawingData,
                       let d = try? PKDrawing(data: data) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Drawing Annotation")
                                .sectionHeaderStyle()
                            PKCanvasViewRepresentable(drawing: .constant(d))
                                .frame(height: 200)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .disabled(true)
                        }
                        .cardStyle()
                    }

                    InfoRow(label: "Recorded by", value: observation.keyworkerName)
                        .cardStyle()
                }
                .padding(16)
            }
            .background(NurseryTheme.background)
            .navigationTitle(observation.childName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .frame(minWidth: 480, minHeight: 500)
    }
}
