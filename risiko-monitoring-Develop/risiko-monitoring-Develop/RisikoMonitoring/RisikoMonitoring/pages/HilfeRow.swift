//
//  HilfeRow.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 02.12.25.
//

import SwiftUI

// Definiert eine einzelne Zeile für die Hilfe-Seite
struct HilfeRow: View {
    // enthält Icon, Titel, und Beschreibung
    let info: CourseHilfe
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Text(info.icon)
                    .font(.largeTitle)
                Text(info.title)
                    .font(.headline)
                
            }
            Text(info.Beschreibung)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.vertical,6)
        
    }
}

#Preview {
    HilfeRow(info: CourseHilfe(icon: "🩺", title: "Zweck der Anwendung", Beschreibung: "Hilfe von Fachpersonal bei der Schnellen Einschätzung des Gesundheitszustands"))
}
