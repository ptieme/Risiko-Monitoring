//
//  UrlGespeichertView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//

import SwiftUI
// Diese View zeigt die erfolgreiche verbindung an
struct UrlGespeichertView: View {
    @EnvironmentObject var fhirService: FHIRServiceView
    // enthält die gespeicherte Server-Url und es wird von der voherigen View übergeben
    let serverUrl: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            // system-Icon von Apple
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Verbindung erfolgreich")
                .font(.title2.bold())

            Text("Die URL wurde erfolgreich gespeichert.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
            //Button mit dem Text Weiter und Aktion wird beim Klick ausgeführt
            Button("Weiter") {
                // setzt Onboarding auf abgeschlossen
                fhirService.hasCompletedOnboarding = true   
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .padding()
    }
}
