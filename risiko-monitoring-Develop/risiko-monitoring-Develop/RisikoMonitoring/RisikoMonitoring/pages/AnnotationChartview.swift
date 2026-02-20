//
//  AnnotationChartview.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 07.12.25.
//

import SwiftUI
import Charts

// View für Digramme mit Annotationnen
struct AnnotationChartview: View {
    //enthält Vitaldaten der Patienten
    @EnvironmentObject var fhirService: FHIRServiceView
    //Liste der Patienten
    // Mehere Patienten möglich
    let patients: [PatientResult]
    
     // Aktuell ausgewählter Vitalwert
     // Standard: Temperatur
    @State private var selectedType: VitalType = .temperature
    

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Auswahlfeld für Vitaltyp
                // Temepatur auswählen, puls sys etc.....
                Picker("Messwert", selection: $selectedType) {
                    Text("temp").tag(VitalType.temperature)
                    Text("Pulse").tag(VitalType.pulse)
                    Text("sys").tag(VitalType.systolicBP)
                    Text("Dia").tag(VitalType.diastolicBP)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Es wird geprüft, ob patienten ohne Daten existieren
                if !missingPatients.isEmpty {
                    // Zeigt Namen der Patienten ohne Daten
                    Text("Keine Daten für: \(missingPatients.joined(separator: ", "))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                // Es wird geprüft, ob keine Punkte existieren
                if points.isEmpty {
                    // systemansicht für leere Inhalte und Erkärung für leere Inhalte
                    ContentUnavailableView("Keine Daten", systemImage: "chart.xyaxis.line",
                                           description: Text("Keine passenden Vitalwerte gefunden"))
                        .padding(.top, 40)
                } else {
                    // Start des Diagramms
                    Chart {

                        // Schleife über alle Datenpunkte
                        ForEach(points) { p in
                            // Linien-Diagramm mit X-Achse= Datum oder Zeit
                            // Y-Achse = Messwert
                            LineMark(
                                x: .value("Zeit", p.date),
                                y: .value("Wert", p.value)
                            )
                            // jede Linie bekommt eigene Farbe pro Patient
                            .foregroundStyle(by: .value("Patient", p.patientName))
                            // Glatte kurven
                            .interpolationMethod(.catmullRom)
                        }
                        // Sortiert letzte Punkte nach Patientennamen
                        let sortedLast = lastPoints.sorted{$0.patientName < $1.patientName}
                        // Schleife mit Index für Versatz
                        ForEach(Array(sortedLast.enumerated()), id: \.element.id) {idx, p in
                            // punkt im Diagramm
                            PointMark(
                                x: .value("Zeit", p.date),
                                y: .value("Wert", p.value)
                            )
                            // Farbe nach Patient
                            .foregroundStyle(by: .value("Patient", p.patientName))
                            // Text über dem Punkt
                            .annotation(position: .top) {
                                // Formatierter Wert
                                Text(format(p.value))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                // Vertikaler Versatz gegen überlappung
                                    .offset(y: idx.isMultiple(of: 2) ? -10: 0)
                                // Horizonzaler versatz
                                    .offset(x: idx.isMultiple(of: 3) ? 8: 0)
                            }
                        }
                    }
                     // Legende
                    .chartLegend(position: .bottom, alignment: .leading)
                    .frame(height: 320)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Annotation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Diese Funktion erstellt Diagramm-Daten für alle Patienten
    private var points: [ChartData] {
        // Leeres Array für Ergebnisse
        var out: [ChartData] = []
        // Schleifen über Patienten
        for p in patients {
            //holt Vitaldaten des Patienten
            let vitals = fhirService.patientVitals["\(p.patientID)"] ?? []
            // Anzeigename im Diagramm
            let pname = "\(p.vorname) \(p.name) (\(p.patientID))"
            
            
            //Schleife über VitalWerte
            for v in vitals {
                // Prüft Datum und parst es
                guard let s = v.measuredAt, let d = DateParser.parse(s) else { continue }
                // messwert als Zahl
                let value: Double?
                // passender Wert wird ausgewählt, puls etc.....
                switch selectedType {
                case .pulse: value = v.pulse.map(Double.init)
                case .temperature: value = v.temperature
                case .systolicBP: value = v.systolicBp.map(Double.init)
                case .diastolicBP: value = v.diastolicBp.map(Double.init)
                }
                 // Nur wenn Wert existiert
                if let value {
                    // wird neuen Punkt hinzugefügt
                    out.append(ChartData(patientID: "\(p.patientID)",
                                         patientName: pname,
                                         date: d,
                                         value: value,
                                         type: selectedType))
                }
            }
        }
        // sortiert Punkte nach Datum
        return out.sorted { $0.date < $1.date }
    }

    // Liste der Patienten ohne Daten
    private var missingPatients: [String] {
        // filtert patienten
        patients.compactMap { p in
            // holt vitaldaten
            let vitals = fhirService.patientVitals["\(p.patientID)"] ?? []
            // wird geprüft ob wert existiert
            let hasAny = vitals.contains { v in
                // Daten muss gültig sein
                guard let s = v.measuredAt, DateParser.parse(s) != nil else { return false }
                // es wird passenden Wert geprüft
                switch selectedType {
                case .pulse: return v.pulse != nil
                case .temperature: return v.temperature != nil
                case .systolicBP: return v.systolicBp != nil
                case .diastolicBP: return v.diastolicBp != nil
                }
            }
            // Nur Patienten ohne Daten zurückgeben
            return hasAny ? nil : "\(p.vorname) \(p.name)"
        }
    }

  // Diese Funktion baut eine Kleine Anzeige für ein Datum im Diagramm
    private func annotationBox(for date: Date) -> some View {
        // holt die Werte, die am nächsten zu diesem Datum sind(pro Patient)
        let values = valuesNear(date: date)

        return VStack(alignment: .leading, spacing: 4) {
            //Zeigt das Datum als Text ohne Urhzeit
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
             // Prüfung
            if values.isEmpty {
                Text("Keine Werte")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                // Schleife über alle Patienten-Werte
                ForEach(values, id: \.patientName) { item in
                    HStack {
                        Text(item.patientName)
                            .font(.caption2)
                            .lineLimit(1)
                        Spacer()
                        Text(format(item.value))
                            .font(.caption2)
                            .monospacedDigit()
                    }
                }
            }
        }
        .padding(8)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // Diese Funktion gibt pro Patient den Wert zurück, der zeitlich am nächsten
    // Zum gegeben Datum ist
    private func valuesNear(date: Date) -> [(patientName: String, value: Double)] {
        // Gruppiert alle Diagramm-punkte nach Patientennamen
        // Ergebnis [patientName:[ChartData]]
        let grouped = Dictionary(grouping: points, by: { $0.patientName })
        // Geht durch jede Gruppe
        // name = patient, pts= alle Punkte dieses Patienten
        return grouped.compactMap { (name, pts) in
            //Sucht den Punkt der zeitlich am nächsten ist
            // Achtung auf die Zeitdifferenz, denn Zeit hängt von der Region ab
            // Wenn kein Punkt existiert nichts zurückgeben
            guard let nearest = pts.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
            else { return nil }
            // gibt ein Tupel zurück(PatientName, Wert)
            return (name, nearest.value)
        }
        // Die Liste alphabetisch muss nach Patientennamen sortiert werdeb
        .sorted { $0.patientName < $1.patientName }
    }
    // Diese Funktion formatiert Werte für Anzeige
    private func format(_ v: Double) -> String {
        // je nach VitalTyp, Temperatur mit Einheit etc..
        switch selectedType {
        case .temperature:
            return String(format: "%.1f °C", v)
        case .pulse:
            return "\(Int(v)) bpm"
        case .systolicBP, .diastolicBP:
            return "\(Int(v)) mmHg"
        }
    }
    // Letzter Punkt pro Patient
    private var lastPoints: [ChartData] {
        // Gruppiert nach Patient
        Dictionary(grouping: points, by: { $0.patientName })
        // Filtert Gruppen
        // neue Punkte müssen genommen werden
            .compactMap { _, pts in
                pts.max(by: { $0.date < $1.date })
            }
    }

}
