//
//  Datas.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 30.11.25.
//

import Foundation
import SwiftUI

// Diese Klasse speichert zentrale Daten der App
class Datas {
    //singleton-Pattern es gibt nur eine einzige Instanz von Datas
    // Überall in der App kann man auf dieselben Daten zugreifen
    // Beispeil ist Datas.shared.courses
    static let shared  = Datas()
    
        // Variable courses,Array von Course
        // Enthält alle Karten, die auf Homeview angezeigt werden
        // Name des courses, Hauptfarbe der Card, SF-Symbol, Beschreibungtext der Card
        var  courses:[Course] = [
        Course(name: "Patienten Suchen", color: .blue, image: "magnifyingglass" , description: "Suchen Sie nach einem oder Mehreren Patienten und greifen Sie auf Vitaldaten zu."),
        Course(name: "Risikobewertung", color: .green, image: "waveform.path.ecg", description: "Analysieren Sie Trends, Warnungen und Therapie-Empfehlung"),
        Course(name: "Gespeicherte Ergebnisee", color: .indigo, image: "tray.fill", description: "Zeigen Sie gespeicherte Analysen erneut an"),
        
        Course(name: "Therapie", color: .purple, image: "pill.fill", description: "Sie Können weitere Therapien hier Hinfügen")
        
    ]
}
