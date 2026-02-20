//
//  RangeChartData.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 07.12.25.
//

import Foundation
 // Diese Definiert eine Datenstruktur für ein Bereichs-Diagramm
// Identifiable wird für SwiftUI Listen und Charts benötigt
struct RangeChartData: Identifiable {
    // Eindeutuge
    var id = UUID()
    // X-Achse Wert
    var x: String
    // Minimaler Messwert
    var minY: Double
    // Maximaler  Messwert
    var maxY: Double
}
