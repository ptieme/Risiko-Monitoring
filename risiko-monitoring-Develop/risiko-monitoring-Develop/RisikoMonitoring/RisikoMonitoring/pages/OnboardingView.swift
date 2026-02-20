//
//  OnboardingView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 21.01.26.
//

import SwiftUI
// Diese View Zeigt das Onboarding der App an
struct OnboardingView: View {
    // Zugriff auf den globalen Service. Zum Speichern von Onboarding-Status
    @EnvironmentObject var fhirService: FHIRServiceView

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 72))
                .foregroundStyle(.red)

            Text("Digitales Risiko-Monitoring")
                .font(.largeTitle.bold())
            // Erjlärung
            Text("""
            Diese Anwendung unterstützt medizinisches Fachpersonal
            bei der frühzeitigen Risikoerkennung und Therapieentscheidung.
            """)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

            Spacer()
            // Setzt Onboarding-Satus auf gesehen
            Button {
                fhirService.hasSeenOnboarding = true
            } label: {
                Text("Los geht’s")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)

        }
        .padding()
    }
}
// Nur in dieser Datei nutzbar
private struct FeatureRow: View {
    
     //Name des Icons Titel und Beschreibung
     
    let icon: String
    let title: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top,spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)
            
            VStack(alignment: .leading,spacing: 4) {
                Text(title).font(.headline)
                Text(text).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}

