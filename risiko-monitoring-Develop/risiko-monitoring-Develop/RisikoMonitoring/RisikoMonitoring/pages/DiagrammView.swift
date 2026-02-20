//
//  DiagrammView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//

import SwiftUI

// Diese View zeigt Diagramm an
struct DiagrammView: View {
    // enthält Vitaldaten der Patienten
    @EnvironmentObject var fhirService: FHIRServiceView
    // es wird  den aktuell ausgewählten Tab gespeichert
    
    @State private var selection = 0
    
    //Liste der Patienten für die Programme
    let patients: [PatientResult]

    // Es wird geprüft, ob Vitaldaten geladen sind.
    
    private var isVitalsReady: Bool {
        // Wenn es keine patienten gibt , nicht bereit
        guard !patients.isEmpty else { return false }
        // Für jeden Patienten muss ein Eintrag existieren .  Auch Liste könnte eventuell laden
        return patients.allSatisfy { fhirService.patientVitals[$0.patientID] != nil }
    }

    var body: some View {
        //Tabview mit auswahlsteuerung
        TabView(selection: $selection) {
            // View für mehere Patienten(Multi-Chart)
            MultipleView(patients: patients)
                 // Übergibt Service-Objekt
                .environmentObject(fhirService)
                .tabItem { Label("Multi", systemImage: "chart.xyaxis.line") }
                .tag(0)
            // View für Diagramm mit Annotationen
            AnnotationChartview(patients: patients)
                .environmentObject(fhirService)
                .tabItem { Label("Annotation", systemImage: "text.bubble") }
                .tag(1)
        }
        .navigationTitle("Diagramme")
        .navigationBarTitleDisplayMode(.inline)

        // Lade-Overlay (skeleton)
        .overlay {
            // Wenn Vitaldaten noch nicht bereit sind
            if !isVitalsReady {
                // Es wird Ladeanzeige gezeigt
                DiagrammLoadingOverlay()
            }
        }
    }
}

//DiagrammLoadingOverlay, Private View und wird nur Intern benutzt
private struct DiagrammLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()

            VStack(spacing: 12) {
                // Lade-Spinner
                ProgressView()
                Text("Daten werden geladen…")
                    .font(.headline)

                VStack(spacing: 10) {
                    // Platzhalter
                    skeletonBar
                    skeletonBar
                    skeletonBar
                }
                .padding(.top, 6)
            }
            .padding(18)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
        }
    }
    // platzhalter für Ladezustand
    private var skeletonBar: some View {
        // Abgerundes Rechteck
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(.systemGray5))
            .frame(height: 56)
            .redacted(reason: .placeholder)
    }
}


