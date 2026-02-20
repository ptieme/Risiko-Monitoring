//
//  CourseHilfe.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 02.12.25.
//

import SwiftUI
import Combine


//diese View definiert ein Datenmodell für einen Hilfe-Eintrag
// Identifiable wird für Foreach in Listen benötigt
struct CourseHilfe: Identifiable {
 
    // Eindeutige ID
    let id = UUID()
    // Icon als String
    
    let icon: String
    // Beschreibung des Hilfe-Punktes
    let title: String
    // längerer erklärender Tetxt
    let Beschreibung: String
}
