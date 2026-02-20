//
//  HomeView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//
import SwiftUI
import UIKit
// Das ist der Hauptseite der APP
struct HomeView: View {
    // enthält ergebnisSuche etc..
    @EnvironmentObject var fhirService: FHIRServiceView
     // Zeigt Alert an, wenn true
    @State private var showRiskAlert = false
    // Es steuert Naviagtion zur Risiko und ergbinsseite, wenn true
    @State private var goToRisk = false

    var body: some View {
        // Scrollbarer Bereich
        ScrollView {
            VStack(spacing: 6) {
                Text("Willkommen im Risiko-Monitoring")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Für medizinisches Fachpersonal entwickelt")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Wählen Sie eine Funktion aus, um zu beginnen")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.top, 8)

            Divider()
                .overlay(.red)
                .padding()
            /*
             Schleife über alle courses
             Für jeden Kurs wird eine Card gezeigt
             course ist das aktuelle Element
             */
            ForEach(Datas.shared.courses) { course in
                // Wenn der Kurs-Name Therapie ist
                if course.name == "Therapie" {
                    NavigationLink(destination: NeuetherapieHinfu_gen()) {
                        // Zeigt Card für diesen Kurs
                        Card(course: course)
                    }
                   

                } else if course.name == "Patienten Suchen" {
                    NavigationLink(destination: PatientenSucheView()) {
                        Card(course: course)
                    }
                    //Extra Tap-Geste gleichzeitig mit Navigation
                    .simultaneousGesture(TapGesture().onEnded {
                        //Leichte Vibration
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    })
                    // legt ein Element über die Card drüber
                    .overlay(
                        Text("Empfohlen")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.9))
                            .clipShape(Capsule())
                            .padding(10),
                        alignment: .topTrailing
                    )


                } else if course.name == "Risikobewertung" {

                   // Card anzeigen(aber ohne direkten NaviagtionLin)
                    Card(course: course)
                    //macht die ganze Card Klickbar
                        .contentShape(Rectangle())
                    // wird ausgeführt beim Tippen
                        .onTapGesture {
                            UIImpactFeedbackGenerator(style:.light).impactOccurred()
                            // wenn suchergebnisse leer sind(Kein Patient gesucht)
                            if fhirService.ergebnissSuche.isEmpty {
                                // Alert auslösen
                                showRiskAlert = true
                            } else {
                                // Naviagtion Aktivieren
                                goToRisk = true
                            }
                        }
                    /*
                     Hintergrund wird benutzt um NavigationLink unsichtbar zu platzieren
                     */
                        .background(
                            NavigationLink(
                                destination: ErgebnissView(results: fhirService.ergebnissSuche), // <-- adapte si besoin
                                isActive: $goToRisk
                            ) { EmptyView() }
                            .hidden()
                        )

                } else {
                    Card(course: course)
                }
            }
        }
        .navigationTitle("Risiko-Monitoring")
        // Logo
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                    Image("logo no bg")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 60)
                        .accessibilityLabel("Company Logo")

                
            }
        }

        // Alert, wenn keine Patientendaten da sind
        .alert("Keine Daten", isPresented: $showRiskAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            // User soll zuerst Patient suchen
            Text("Bitte suchen Sie zuerst einen Patienten, bevor Sie die Risikobewertung öffnen.")
        }
    }
}

#Preview {
    HomeView()
}

