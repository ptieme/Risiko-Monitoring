//
//  RiskBadge.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 06.01.26.
//

import SwiftUI

// Diese View zeigt das Risiko als Badge
struct RiskBadge: View {
    // Risiko-Level als Text
    let riskLevel: String
    
    var body: some View {
        Text(label)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
    // Diese Funktion wandelt Risiko-Farbe in Text um
    private var label: String{
        switch riskLevel {
        case "GREEN": return "LOW"
        case "YELLOW": return "MEDIUM"
        case "RED": return "HIGH"
        default: return "-"
        }
    }
    // Diese Funktion gibt die Passende Farbe zurück
    private var color: Color {
        switch riskLevel {
        case "GREEN": return .green
        case "YELLOW": return .yellow
        case "RED": return .red
        default: return .gray
        }
    }
}
