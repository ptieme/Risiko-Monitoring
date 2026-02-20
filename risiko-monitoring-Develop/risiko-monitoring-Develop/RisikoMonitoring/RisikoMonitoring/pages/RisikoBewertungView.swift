//
//  RisikoBewertungView.swift
//  RisikoMonitoring
//

import SwiftUI
import UIKit

struct RisikoBewertungView: View {
    @EnvironmentObject var fhirService: FHIRServiceView

    @State private var showDiagram = false
    @State private var diagramPatients: [PatientResult] = []
    @State private var isPreparingDiagram = false
    @State private var diagramErrorMessage: String? = nil
    @State private var showDiagramErrorAlert = false

    @State private var showSaved = false

    @State private var showSaveAlert = false
    @State private var saveAlertText = ""

    @State private var showExportAlert = false
    @State private var exportAlertText = ""

    let patients: [PatientResult]

    var body: some View {
        ScrollView {
            ForEach(patients) { p in
                patientCard(p)
            }

            VStack(spacing: 10) {
                Button("Export (Alle Patienten) als JSON") {
                    exportAlleInJSON()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)

                Button("Speichern (Alle Patienten)") {
                    saveAlleDauerhaft()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                Button("Gespeicherte Bewertungen ansehen") {
                    showSaved = true
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                Button {
                    let selected = Array(patients.prefix(3))
                    diagramPatients = selected
                    isPreparingDiagram = true
                    diagramErrorMessage = nil

                    Task {
                        do {
                            try await fhirService.ladeDetailsVonPatient(
                                patientIDs: patients.map { $0.patientID }
                            )
                            try await fhirService.ladeVitalsVonPatient(
                                patientIDs: selected.map { $0.patientID },
                                limit: 200
                            )

                            await MainActor.run {
                                isPreparingDiagram = false
                                showDiagram = true
                            }
                        } catch {
                            await MainActor.run {
                                isPreparingDiagram = false
                                diagramErrorMessage = error.localizedDescription
                                showDiagramErrorAlert = true
                            }
                        }
                    }
                } label: {
                    Text(isPreparingDiagram ? "Bitte warten..." : "Diagramme erstellen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(patients.isEmpty || isPreparingDiagram)
                .opacity((patients.isEmpty || isPreparingDiagram) ? 0.6 : 1)
                .frame(maxWidth: .infinity)
            }
            .padding(8)
        }
        .overlay {
            if isPreparingDiagram {
                ZStack {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Diagramme werden vorbereitet…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .navigationTitle("Risikobewertung")
        .navigationBarTitleDisplayMode(.inline)

        .navigationDestination(isPresented: $showDiagram) {
            DiagrammView(patients: diagramPatients)
                .environmentObject(fhirService)
        }

        .navigationDestination(isPresented: $showSaved) {
            GespeicherteView()
        }

        .alert("Fehler", isPresented: $showDiagramErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(diagramErrorMessage ?? "Unbekannter Fehler")
        }

        .alert("Speichern", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveAlertText)
        }

        .alert("Export", isPresented: $showExportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportAlertText)
        }
    }

    private func patientCard(_ patient: PatientResult) -> some View {
        let diags = fhirService.patientDiagnosen[patient.patientID] ?? []
        let meds = fhirService.patientenMedikamente[patient.patientID] ?? []

        return VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(patient.vorname) \(patient.name) \(patient.geschlecht)")
                        .font(.headline)
                        .lineLimit(5)
                    Text("ID: \(patient.patientID)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Geburt: \(patient.geburtsdatum)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Text(patient.risikoText)
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(patient.risikofarbe)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Beobachtung").font(.headline)
                HStack { Text("puls"); Spacer(); Text(patient.puls) }
                HStack { Text("Blutdruck"); Spacer(); Text("\(patient.blutdruckSys)/ \(patient.blutdruckDia)") }
                HStack { Text("Temperatur"); Spacer(); Text(patient.temperatur) }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text("Diagnosen").font(.headline)
                if diags.isEmpty {
                    Text("Nicht bekannt")
                } else {
                    ForEach(diags, id: \.self) { d in
                        Text(d)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text("Medikament").font(.headline)
                if meds.isEmpty {
                    Text("Nicht bekannt")
                } else {
                    ForEach(meds, id: \.self) { m in
                        Text(m)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 1)
    }

    private func exportAlleInJSON() {

        let patientArray: [[String: Any]] = patients.map { p in
            let diags = fhirService.patientDiagnosen[p.patientID] ?? []
            let meds = fhirService.patientenMedikamente[p.patientID] ?? []
            let risk = fhirService.patientRiskInfo[p.patientID]

            return [
                "patientID": p.patientID,
                "name": p.name,
                "vorname": p.vorname,
                "geburtsdatum": p.geburtsdatum,
                "geschlecht": p.geschlecht,
                "vitalswerte": [
                    "puls": p.puls,
                    "Temperatur": p.temperatur,
                    "blutdruck_systolisch": p.blutdruckSys,
                    "blutdruck_diastolisch": p.blutdruckDia
                ],
                "diagnosen": diags,
                "medikamente": meds,
                "risiko": [
                    "status": p.risikoText,
                    "farbe": p.risikofarbe.description,
                    "backend": [
                        "level": risk?.level as Any,
                        "score": risk?.score as Any,
                        "reasons": risk?.reasons as Any
                    ]
                ]
            ]
        }

        let exportData: [String: Any] = [
            "patient": patientArray   // beginnt mit "patient"
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: [.prettyPrinted])
            let fileName = "Risikobewertung_\(Int(Date().timeIntervalSince1970)).json"

            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let exportsDir = docs.appendingPathComponent("Exports", isDirectory: true)
            try FileManager.default.createDirectory(at: exportsDir, withIntermediateDirectories: true)

            let fileUrl = exportsDir.appendingPathComponent(fileName)
            try jsonData.write(to: fileUrl, options: [.atomic])

            exportAlertText = "Export gespeichert:\nDateien → Auf meinem iPhone → RisikoMonitoring → Exports\n\(fileName)"
            showExportAlert = true

        } catch {
            exportAlertText = "Export fehlgeschlagen: \(error.localizedDescription)"
            showExportAlert = true
        }
    }

    // Save: dauerhaft (Documents/RiskAssessments)
    private func saveAlleDauerhaft() {
        let exportData: [[String: Any]] = patients.map { p in
            let diags = fhirService.patientDiagnosen[p.patientID] ?? []
            let meds = fhirService.patientenMedikamente[p.patientID] ?? []
            let risk = fhirService.patientRiskInfo[p.patientID]

            return [
                "patient": [
                    "patientID": p.patientID,
                    "name": p.name,
                    "vorname": p.vorname,
                    "geburtsdatum": p.geburtsdatum,
                    "geschlecht": p.geschlecht
                ],
                "vitalswerte": [
                    "puls": p.puls,
                    "Temperatur": p.temperatur,
                    "blutdruck_systolisch": p.blutdruckSys,
                    "blutdruck_diastolisch": p.blutdruckDia
                ],
                "diagnosen": diags,
                "medikamente": meds,
                "risiko": [
                    "status": p.risikoText,
                    "farbe": p.risikofarbe.description,
                    "backend": [
                        "level": risk?.level as Any,
                        "score": risk?.score as Any,
                        "reasons": risk?.reasons as Any
                    ]
                ]
            ]
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: [.prettyPrinted])
            let fileName = "Risikobewertung_\(Int(Date().timeIntervalSince1970)).json"

            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dir = docs.appendingPathComponent("RiskAssessments", isDirectory: true)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

            let fileUrl = dir.appendingPathComponent(fileName)
            try jsonData.write(to: fileUrl, options: [.atomic])

            saveAlertText = "Gespeichert:\nDateien → Auf meinem iPhone → RisikoMonitoring → RiskAssessments\n\(fileName)"
            showSaveAlert = true

            print("Save gespeichert unter: \(fileUrl.path)")
        } catch {
            saveAlertText = "Speichern fehlgeschlagen: \(error.localizedDescription)"
            showSaveAlert = true
        }
    }
}
