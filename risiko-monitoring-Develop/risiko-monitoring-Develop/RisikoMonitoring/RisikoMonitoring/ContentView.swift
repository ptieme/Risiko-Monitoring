//
//  ContentView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//

import SwiftUI

import SwiftData
 //Startpunkt der Benutzeroberläsche
struct ContentView: View {
    
    @EnvironmentObject var fhirService: FHIRServiceView
    // Es wird den aktuellen Index gespeichert
    // Es wird für die Therapie-Naviagtion benutzt
    @State var currentIndex = 0
    // gibt den aktuell ausgewälhten Planeten Zurück
    var currentPlanet: Planet {
        // Holt den Planeten aus der Zentralen Datenquelle
        return Datas2.shared2.allPlanets[currentIndex]
    }
    
    var body: some View {
        // Tabview erstellt die unteren Navigation
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Startseite", systemImage: "house.fill") }

            NavigationStack {
                PatientenSucheView()
            }
            .tabItem { Label("Suche", systemImage: "magnifyingglass") }

            NavigationStack {
                GespeicherteView()
            }
            .tabItem { Label("Gespeichert", systemImage: "tray.fill") }

            NavigationStack {
                TherapieView(currentIndex: $currentIndex)
            }
            .tabItem { Label("Therapie", systemImage: "pills.fill") }

            NavigationStack {
                HilfeView()
            }
            .tabItem { Label("Hilfe", systemImage: "questionmark.circle.fill") }
            
            NavigationStack {
                LogoutView()
            }
            .tabItem {
                Label("Abmelden", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(FHIRServiceView())
}

