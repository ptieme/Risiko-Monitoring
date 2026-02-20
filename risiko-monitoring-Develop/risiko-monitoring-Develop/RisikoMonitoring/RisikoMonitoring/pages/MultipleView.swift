//
//  MultipleView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 07.12.25.
//

import SwiftUI
import Charts

// Diese wird für Diagramme mit mehreren Patienten verwendet
struct MultipleView: View {

    // Enthält Vitaldaten und Risiko-Infos
    @EnvironmentObject var fhirService: FHIRServiceView

    // Liste der ausgewählten Patienten
    let patients: [PatientResult]

    // Aktuell ausgewählter Vitalwert
    @State private var selectedType: VitalType = .temperature

    // Für Tooltip / Hover / Berührung
    @State private var selectedDate: Date? = nil
    @State private var selectedByPatient: [String: ChartData] = [:]   // patientID -> nearest point

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    // zeigt Box mit Hochrisiko-Patienten (wenn vorhanden)
                    highRiskBox

                    // Auswahl für Vitaltyp
                    Picker("Messwert", selection: $selectedType) {
                        Text("Temp").tag(VitalType.temperature)
                        Text("Pulse").tag(VitalType.pulse)
                        Text("sys").tag(VitalType.systolicBP)
                        Text("Dia").tag(VitalType.diastolicBP)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Es wird geprüft, ob keine Diagrammdaten existieren
                    if points.isEmpty {
                        ContentUnavailableView(
                            "Keine Daten",
                            systemImage: "waveform.path.ecg",
                            description: Text("Keine passenden Vitalwerte gefunden")
                        )
                        .padding(.top, 40)
                    } else {

                        Chart {
                            // Linien
                            ForEach(points) { p in
                                LineMark(
                                    x: .value("Zeit", p.date),
                                    y: .value("Wert", p.value)
                                )
                                .foregroundStyle(by: .value("Patient", p.patientName))
                                .interpolationMethod(.catmullRom)
                            }

                            // ✅ Vertikale Linie bei Auswahl
                            if let selectedDate {
                                RuleMark(x: .value("Auswahl", selectedDate))
                                    .lineStyle(.init(lineWidth: 1, dash: [4]))
                                    .foregroundStyle(.secondary)
                            }

                            // ✅ Punkte nur zeigen, wenn ausgewählt (pro Patient der nächste Punkt)
                            if !selectedByPatient.isEmpty {
                                ForEach(Array(selectedByPatient.values), id: \.id) { p in
                                    PointMark(
                                        x: .value("Zeit", p.date),
                                        y: .value("Wert", p.value)
                                    )
                                    .foregroundStyle(by: .value("Patient", p.patientName))
                                    .symbol(by: .value("Patient", p.patientName))
                                    .symbolSize(80)
                                }
                            }
                        }
                        .chartLegend(position: .bottom, alignment: .leading)
                        .frame(height: 320)
                        .padding(.horizontal)

                        // ✅ Tooltip Overlay
                        .chartOverlay { proxy in
                            GeometryReader { geo in
                                ZStack(alignment: .topLeading) {

                                    // "Touch-Fangfläche"
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { value in
                                                    let plotFrame = geo[proxy.plotAreaFrame]
                                                    let xInPlot = value.location.x - plotFrame.origin.x

                                                    if let date: Date = proxy.value(atX: xInPlot) {
                                                        selectedDate = date
                                                        selectedByPatient = nearestPointsPerPatient(to: date)
                                                    }
                                                }
                                                .onEnded { _ in
                                                    selectedDate = nil
                                                    selectedByPatient = [:]
                                                }
                                        )

                                    // Tooltip-Box (nur wenn etwas selektiert ist)
                                    if let selectedDate, !selectedByPatient.isEmpty,
                                       let xPos = proxy.position(forX: selectedDate) {

                                        let plotFrame = geo[proxy.plotAreaFrame]
                                        let tooltipX = plotFrame.origin.x + xPos

                                        tooltipView(selectedDate: selectedDate, points: Array(selectedByPatient.values))
                                            .frame(maxWidth: 260)
                                            .position(
                                                x: clamp(tooltipX, min: plotFrame.minX + 130, max: plotFrame.maxX - 130),
                                                y: plotFrame.minY + 24
                                            )
                                    }
                                }
                            }
                        }

                        Text("Berühre/ziehe über das Diagramm, um die Werte anzuzeigen.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
            }
            .navigationTitle("Mehrere Patienten")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Hochrisiko Box
    private var highRiskBox: some View {
        let hoch = patients.filter { p in
            fhirService.patientRiskInfo["\(p.patientID)"]?.level.uppercased() == "HIGH"
        }

        return Group {
            if !hoch.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hochrisiko Patienten")
                        .font(.headline)

                    ForEach(hoch, id: \.patientID) { p in
                        let risk = fhirService.patientRiskInfo["\(p.patientID)"]
                        Text("\(p.vorname) \(p.name) (ID \(p.patientID)) - Score \(risk?.score ?? 0)")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.15))
                .cornerRadius(14)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Chart Points
    private var points: [ChartData] {
        var out: [ChartData] = []

        for p in validPatients {
            let vitals = fhirService.patientVitals["\(p.patientID)"] ?? []
            let pname = "\(p.vorname) \(p.name) (\(p.patientID))"
            let pid = "\(p.patientID)"

            for v in vitals {
                guard let s = v.measuredAt, let d = DateParser.parse(s) else { continue }

                let value: Double?
                switch selectedType {
                case .temperature:
                    value = v.temperature
                case .pulse:
                    value = v.pulse.map(Double.init)
                case .systolicBP:
                    value = v.systolicBp.map(Double.init)
                case .diastolicBP:
                    value = v.diastolicBp.map(Double.init)
                }

                if let value {
                    out.append(
                        ChartData(
                            patientID: pid,
                            patientName: pname,
                            date: d,
                            value: value,
                            type: selectedType
                        )
                    )
                }
            }
        }

        return out.sorted { $0.date < $1.date }
    }

    // Filtert Patienten mit passenden Vitalwerten
    private var validPatients: [PatientResult] {
        patients.filter { p in
            let vitals = fhirService.patientVitals["\(p.patientID)"] ?? []
            return vitals.contains { v in
                switch selectedType {
                case .temperature: return v.temperature != nil
                case .pulse: return v.pulse != nil
                case .systolicBP: return v.systolicBp != nil
                case .diastolicBP: return v.diastolicBp != nil
                }
            }
        }
    }

    // MARK: - Tooltip Helpers

    /// Pro Patient wird der nächste Punkt zur gewählten Date gesucht (damit man mehrere Patienten gleichzeitig sieht).
    private func nearestPointsPerPatient(to date: Date) -> [String: ChartData] {
        var result: [String: ChartData] = [:]

        // Gruppiere alle Punkte nach Patient
        let grouped = Dictionary(grouping: points, by: { $0.patientID })

        for (pid, pts) in grouped {
            guard let nearest = pts.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) else {
                continue
            }

            // Optional: zu weit entfernte Punkte nicht anzeigen (z.B. wenn ein Patient nur sehr alte Werte hat)
            let maxDistance: TimeInterval = 60 * 60 * 24 * 2 // 2 Tage
            if abs(nearest.date.timeIntervalSince(date)) <= maxDistance {
                result[pid] = nearest
            }
        }

        return result
    }

    private func tooltipView(selectedDate: Date, points: [ChartData]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dateLabel(selectedDate))
                .font(.caption)
                .foregroundStyle(.secondary)

            // Sortiert für stabile Anzeige
            ForEach(points.sorted(by: { $0.patientName < $1.patientName }), id: \.id) { p in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(shortName(p.patientName))
                        .font(.caption)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Text("\(formatValue(p.value)) \(unitText(for: selectedType))")
                        .font(.caption)
                        .monospacedDigit()
                }
            }
        }
        .padding(10)
        .background(.thinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.secondary.opacity(0.25), lineWidth: 1)
        )
    }

    private func unitText(for type: VitalType) -> String {
        switch type {
        case .temperature: return "°C"
        case .pulse: return "bpm"
        case .systolicBP, .diastolicBP: return "mmHg"
        }
    }

    private func formatValue(_ v: Double) -> String {
        // Temperatur meist 1 Nachkommastelle, Puls/BP meist 0
        switch selectedType {
        case .temperature:
            return String(format: "%.1f", v)
        case .pulse, .systolicBP, .diastolicBP:
            return String(format: "%.0f", v)
        }
    }

    private func dateLabel(_ d: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "de_DE")
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: d)
    }

    private func shortName(_ full: String) -> String {
        // Kürzt "Vorname Nachname (ID)" -> "Vorname N."
        // Wenn es nicht passt, wird einfach abgeschnitten.
        let parts = full.split(separator: " ")
        guard parts.count >= 2 else { return String(full.prefix(18)) }
        let first = parts[0]
        let last = parts[1].first.map { "\($0)." } ?? ""
        return "\(first) \(last)"
    }

    private func clamp(_ x: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(x, min), max)
    }
}
