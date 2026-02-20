//
//  APITypes.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 25.12.25.
//

import Foundation
// Codable bedeutet JSON zu Swift
// Senadble sicher für Parallele Threads
struct APIPatient: Codable , Sendable{
    // eindeutige ID des Patienten
    let id: Int
    // Daten von Patient
    let firstName: String
    let lastName: String
    let birthDate: String?
    let gender: String?
    
    // Verbindung Json-Namen mit Swift-name
    enum CodingKeys: String, CodingKey {
        // Gleicher Name in Json und Swift etc..
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case gender
        
    }
}
// Antwort der API mit mehreren Patienten
struct  APIPatientListResponse: Codable , Sendable {
    //Liste aller Patienten
    let items: [APIPatient]
    //Anzahl aller Patienten
    let count: Int?
    //Maximale Anzahl pro Anfrage
    let limit: Int?
    //Startposition der Liste(Pagination)
    let offset: Int?
}
 //Struktur für Vitaldaten eines Patienten
struct APIVital: Codable , Sendable {
    // Id des Vitalswertes
    let id: Int?
    // Zeitpunkt
    let measuredAt: String?
    // pulswert
    let pulse: Int?
    //sys Blutdruck
    let systolicBp: Int?
    //dia Blutdruck
    let diastolicBp: Int?
    //Körpertemperatur
    let temperature: Double?
    
    //Mapping von JSON zu Swift
    
    enum CodingKeys: String, CodingKey {
        // ID unverändert
        case id
        case measuredAt = "measured_at"
        case pulse
        case systolicBp = "systolic_bp"
        case diastolicBp = "diastolic_bp"
        case temperature
    }
    
}
// Antwort mit den neuesten Vitaldaten

struct APIVitalsLatestResponse: Codable, Sendable {
    //Patient-ID
    let patientId: Int
    //letzter Vitalwert
    //Optional
    let latest: APIVital?
    
    // Json Mapping
    
    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        // letzte Vitaldaten
        case latest
    }
}

//Struktur für Diagnosen-Daten
struct APIDiagnostic: Codable , Sendable {
    let id: Int?
    let diagnosticName: String?
    let diagnosticDate: String?
    // Json Mapping
    enum CodingKeys: String, CodingKey {
        case id
        case diagnosticName = "diagnostic_name"
        case diagnosticDate = "diagnostic_date"
    }
}
// Antwort mit mehreren Diagnosen
struct APIDiagnosticsResponse: Codable , Sendable {
    let patientId: Int
    // Liste der Diagnoses
    let items: [APIDiagnostic]
    
    // JSON Mapping
    
    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        // Diagnose Liste
        case items
        
    }
}
// Struktur für Medikament

struct APIMedicationItem: Codable {
    let id: Int?
    let patientId: Int?
    let medicationId: Int?
    let medicationName: String?
    let dosage: String?
    let startDate: String?
    let endDate: String?
    
    // jSON Mapping
    
    enum CodingKeys: String, CodingKey {
        case id
        case patientId = "patient_id"
        case medicationId = "medication_id"
        case medicationName = "medication_name"
        case dosage
        case startDate  = "start_date"
        case endDate = "end_date"
    }
}

//Antwort mit mehreren Medikamenten
struct APIMedicationsResponse: Codable {
    let patientId: Int
    // Liste der Medikamente
    let items: [APIMedicationItem]
    
    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case items
    }
}
// Risiko-Bewertung des Patienten
struct APIRiskResponse: Codable {
    let patientId: Int
    let score: Int
    let level: String
    let reasons: [String]
    let usedLatestVitals: APIVital?
    let usedLatestDiagnostic: APIDiagnostic?
    
    // Json Mapping
    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case score
        case level
        case reasons
        case usedLatestVitals = "used_latest_vitals"
        case usedLatestDiagnostic = "used_latest_diagnostic"
    }
}

// Antwort mit mehreren Vitalwerten
struct APIVitalsResponse: Codable, Sendable  {
    let patientId: Int?
    // Liste der Vitaldaten
    let items: [APIVital]
    
    // Json Mapping
    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case items
    }
}
