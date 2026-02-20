//
//  PatientResultView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 06.12.25.
//

import SwiftUI
// wird für den typ CGFloat benutzt
import CoreGraphics


//enum für feste Spaltenbreiten
//Wird für Tabellen-Layout verwendet

 enum Col {
     //Breite für verschieden Spalten
    static let check: CGFloat = 32
    static let name: CGFloat = 120
    static let vorname: CGFloat = 120
    static let gender: CGFloat = 80
    static let birth: CGFloat = 100
    static let risk: CGFloat = 1120
}

// Struktur für einen Patienten in der Ergebnisliste
// Identifiable ist notwendig für SwiftUI Listen
// Hashable erlaubt vergleiche und Sets
struct PatientResult : Identifiable, Hashable{
    let id = UUID()
    let patientID: String
    let name: String
    let vorname: String
    let geburtsdatum: String
    let geschlecht: String
    //Text für Risiko-Anzeige
    // Standartwert: unbekant
    var risikoText: String = "unbekant"
    // Farbe für Risiko
    //Kein Risikobekannt
    var  risikofarbe: Color = .gray
    
    // VitalDaten
    var  puls: String = "nicht vorhanden"
    var blutdruckSys: String = "nicht vorhanden"
    var blutdruckDia: String =  "nicht vorhanden"
    var temperatur: String   =   "nicht vorhanden"
    
    
   
}
