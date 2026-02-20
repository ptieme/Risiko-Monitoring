//
//  Combiner.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 07.12.25.
//

import SwiftUI
// imporiert Charts für Diagramm
import Charts
// Eine View die Risiko + Vitaldaten als Chart zeigt.
struct Combiner: View {
    // Geneinsamer Service(Daten vom Backend)
    @EnvironmentObject var fhirservice: FHIRServiceView
    // Der Patient, der angezeigt wird
    let patient: PatientResult
    
    var body: some View {
        NavigationStack {
            // Seite sind hier zu scrollen
            ScrollView() {
                VStack(alignment: .leading, spacing: 12) {
                    // Es wird eine Box, gezeigt wenn Patient High Risiko hat
                    highRiskBox
                    // es wird geprüft,ob keine Daten vorhanden sind
                    if series.isEmpty{
                        //System-View
                        ContentUnavailableView(
                            "Keine Vitaldaten",
                            systemImage: "waveform.path.ecg",
                            description: Text("Keine Vitalwerte für diesen Patienten.")
                        )
                        .padding(.top, 40)
                    } else {
                        // Diagramm mit Daten series
                        Chart(series) { p in
                            LineMark(x: .value("Zeit", p.date),
                                     y: .value("Wert", p.value)
                            )
                            .foregroundStyle(by: .value("Type", p.type.rawValue))
                            .interpolationMethod(.catmullRom)
                            
                            PointMark(x: .value("Zeit", p.date), y: .value("Wert", p.value)
                            )
                            .foregroundStyle(by: .value("Type", p.type.rawValue))
                        }
                        // Legende unten Links
                        .chartLegend(position: .bottom, alignment: .leading)
                        .frame(height: 320)
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
            }
            // Titel zeigt Patient Name
            .navigationTitle("Patient: \(patient.vorname) \(patient.name)")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    // Box wird als computed propertygebaut
    private var highRiskBox: some View {
        // Holt Risiko-Info aus Dictionary(Backend)
        let risk = fhirservice.patientRiskInfo[patient.patientID]
        // es wird geprüft, ob Risiko-Level High ist
        let isHoch = risk?.level.uppercased() == "HIGH"
        // Mehrere Viewa Möglich
        return Group {
            // Nur zeigen, wenn HIGH
            if isHoch {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hochrisiko")
                        .font(.headline)
                    // Es wird Score gezeigt(falls nil dann 0)
                    Text("Score: \(risk?.score ?? 0)")
                        .font(.subheadline)
                    // Gründe-Liste(falls nil oder leere Liste)
                    let reasons = risk?.reasons ?? []
                    // zeigt maximal 3 Gründe
                    ForEach(reasons.prefix(3), id: \.self) { r in
                        // Grund als Text
                        Text("\(r)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.15))
                .cornerRadius(14)
                .padding(.horizontal)
            }
        }
    }
    
    // Baut Chart-Daten aus Vitalwerten
    private var series: [ChartData] {
        // Vitaldate für Patienten wird geholt
        let vitals = fhirservice.patientVitals[patient.patientID] ?? []
        // Patient label für Chart
        let label = "\(patient.vorname) \(patient.name)"
        //Leeres Array für Chatpunkte
        var  out: [ChartData] = []
        // Schleife über Vitalwerte
        for v in vitals {
            //Datum muss existieren und paserbar sein, sonst überspringen
            guard let s = v.measuredAt, let d = DateParser.parse(s) else { continue }
            
            // Wenn Temperatur vorhanden ist
            if let temp = v.temperature {
                // wird ChartData Punkt hinzugefügt
                out.append(ChartData(patientID: patient.patientID, patientName: label, date: d, value: temp, type: .temperature))
            }
            // Die selbe Erklärung wie bei der Temperatur
            if let pulse = v.pulse {
                out.append(ChartData(patientID: patient.patientID, patientName: label, date: d, value: Double(pulse), type: .pulse))
            }
            
            if let sys = v.systolicBp {
                out.append(ChartData(patientID: patient.patientID, patientName: label, date: d, value: Double(sys), type: .systolicBP))
            }
            
            if let dia = v.diastolicBp {
                out.append(ChartData(patientID: patient.patientID, patientName: label, date: d, value: Double(dia), type: .diastolicBP))
            }
        }
        // Sortiert nach Datun (alt neu)
        return out.sorted { $0.date < $1.date}
    }
    
}
