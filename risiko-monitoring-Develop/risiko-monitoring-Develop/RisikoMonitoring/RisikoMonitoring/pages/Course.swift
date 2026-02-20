//
//  Course.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 30.11.25.
//

import SwiftUI
/*
 Identifiable hat eine eindeutige id (wichtig wenn man sich für Foreach entscheidet)
 Equatable man kann zwei courses vergleichen
 */
struct Course: Identifiable , Equatable {
    /*
     jede course bekommt eine id
     Name der course z.B Patienten Suchen
     Hauptfarbe für card/UI
     Name von Icon
     BescheribungText für Card
     */
    var id = UUID()
    var name: String
    var color: Color
    var image: String
    var  description: String
    
    //berechnete Variable sie ist wie kleine Funktion ohne Parameter
    // Konvertiert UIKit-Farbe systemBackground in swuiftUI color
    //Passt sich automatisch an Dark Mode und Light Mode an
    var color2: Color {
        return Color(uiColor: UIColor.systemBackground)
    }
    /*
     Berechnete Variable gibt ein Array von Farben zurück
     sie liefert zwie Farben für einen Verlauf color und color2
     Ergebniss ist ein Array mit zwei Farben
     Erste Farbe color(Hauptfarbe)
     zweite Farbe: color2(System-Hintergrund)
     */
    var gradientColors:[Color] {
        return[color, color2] // Color2 est la varialble Calculer
    }
}
