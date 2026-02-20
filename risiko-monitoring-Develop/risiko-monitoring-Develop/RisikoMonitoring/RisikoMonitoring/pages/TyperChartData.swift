//
//  TyperChartData.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 07.12.25.
//

import Foundation
// Diese definiert eine Datenstrukrtur für Diagramm-Daten
// Identifiable wird für SwiftUI Charts benötigt
struct TyperChartData: Identifiable {
    // Eindeutige ID
    var id = UUID()
    // Wert für die X-Achse
    var X: String
    // Wert für die Y-Achse
    var Y: Double
    // typ des Messwert
    var type: String
}
