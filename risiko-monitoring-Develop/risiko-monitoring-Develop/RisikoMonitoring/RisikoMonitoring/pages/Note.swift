//
//  Note.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 01.12.25.
//
import SwiftUI
import SwiftData

// Markiert die Klasse als Swift-Data-Modell
// wird automatisch in der Datenbank gespeichert
@Model

// Repräsentiert eine Notiz
class Note {
    //Muss eindeutig sien (Kein doppeleter Name erlaubt)
    @Attribute(.unique) var name: String
    // Freier Text
    var besch: String
    // Datum der lezten Änderungen
    var lastUpdate: Date
    // Alle Werte werden beim Erstellen gesetzt
    init(name: String, besch: String, lastUpdate: Date) {
        self.name = name
        self.besch = besch
        self.lastUpdate = lastUpdate
        
    }
    // Gibt das Datum als Text zurück
    var dateString: String {
        // Erstellt einen DatenFormatter
        let formatter = DateFormatter()
        //kurzes Datumformat
        formatter.dateStyle = .short
        // Kurses Zeitformat
        formatter.timeStyle = .short
        //wandelt lastUpdate in einen String um
        return formatter.string(from: lastUpdate)
    }
    //Funktion zum aktualisieren des Datums
    func updateDate () {
        // Setzt das Datum auf Jetzt
        self.lastUpdate = Date()
    }
}
