//
//  ChartData.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 07.12.25.
//

import SwiftUI
// Diese definiert Datenstruktur für Diagramm-Daten
// Identifiable ist wichtig für SwiftUI
struct ChartData : Identifiable {
   let id = UUID()
   let patientID:  String
   let patientName: String
   let date: Date
   let value: Double
   let type: VitalType             
    
}
 // enum für die Art des Vitalwertes
// String wird für Anzeige/ Farben benutzt
enum VitalType: String {
    case pulse
    case temperature
    case systolicBP
    case diastolicBP
}

//enthält Funktion zum parsen von Datum-String
enum DateParser {
    //Diese Funktion wandelt einen String in ein Date um
    static func parse(_ s: String) -> Date? {
        // erstellt ISO-Formater
        let  iso = ISO8601DateFormatter()
        // unterstüzt ISO-Format mit Millisekunden
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        // Wenn Datum erkannt wird . sofort zurückgeben
        if let d = iso.date(from: s) { return d}
        // ISO-Format ohne millisekunden
        iso.formatOptions = [.withInternetDateTime]
        // wenn erkannt Datum zurückgeben
        if let d = iso.date(from: s) { return d }
        
        // Liste der möglichen Datumsformaten
        let fmt = [
            // ISO mit vielen Millisekunden
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            // ISO mit 3 Millisekunden
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            // ISO mit  2 Millisekunden
            "yyyy-MM-dd'T'HH:mm:ss.SS",
            // Einfaches Datum mit Zeit
            "yyyy-MM-dd HH:mm:ss"
            
        ]
        // Erstellt einen Datenformater
        let df = DateFormatter()
        // Stellt sichere Locale ein
        df.locale = Locale(identifier: "en_US_POSIX")
        // Wichtig für Sever-Daten
        df.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Schleife über alle Formarte
        for f in fmt {
            // setzt aktuelles Format
            df.dateFormat = f
            // Wenn String passt. Datum zurückgeben
            if let d = df.date(from: s) { return d}
        }
        // Kein Datum erkannt 
        return nil
        
    }
}
