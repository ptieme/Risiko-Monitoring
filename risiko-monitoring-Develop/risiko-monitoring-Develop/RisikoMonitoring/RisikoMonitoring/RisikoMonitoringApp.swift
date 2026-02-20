//
//  RisikoMonitoringApp.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//


import SwiftUI
import SwiftData
// Makiert den Einstiegspunkt der APP
// Die APP startet huer
@main
// Steuert den gesamten APP-Ablauf
struct RisikoMonitoringApp: App {

    // Enthält Login-Satus, Onboarding-Status, FHIR-Daten(bezogen auf uns erstellte Datanbank)
    @StateObject private var fhirService = FHIRServiceView()

    var body: some Scene {
        //Hauptfenster der APP
        WindowGroup {

            //Es wird geprüft ob Benutzer nicht eingeloggt ist
            if !fhirService.isLoggedIn {
                // Zeigt die Login-Ansicht
                AnmeldungView()
                // Übergibt das Service-Objekt an die Login-View
                    .environmentObject(fhirService)

            }
            // onboarding ist noch nicht abgeschlossen
            else if !fhirService.hasCompletedOnboarding {

                // Anusicht zur Eingabe der Server-URL
                UrlEingabeView()
                    .environmentObject(fhirService)
            //Benutzer ist eingeloggt
            // URL wurde eingegeben
            // Einführung(Onboarding) noch nicht gesehen
            } else if !fhirService.hasSeenOnboarding {
                // Zeigt die Onboarding-Seiten
                OnboardingView()
                    .environmentObject(fhirService)
             // Alle bedingungen erfüllt
            // User vollständig bereit
            }else {
            // Startet die Haupt-App
                ContentView()
                    .environmentObject(fhirService)
            }
        }
        // initialisiert Swiftdata
        // Erstellt ein Datenbank für Note
        // gilt für die gesammte App
        .modelContainer(for: Note.self)
    }
}
