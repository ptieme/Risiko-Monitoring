//
//  Datas2.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 30.11.25.
//

import Foundation

// Enthält Risiko-Therapien
class Datas2 {
    // singleton-Instanz
    // Eine gemeinsame Datenquelle für die ganze APP
    static let shared2 = Datas2()
    
    // Erstellt einen Planetten mit Risiko-Stufe 1
    let hoch = Planet(position: 1, name: "Hoch")
    let mittel = Planet(position: 2, name: "Mittel")
    let niedrig = Planet(position: 3, name: "Niedrig")
    
    //gibt alle Planeten als Liste zrück
    var allPlanets:[Planet] {
        return [hoch, mittel, niedrig]
    }
    // Jede Beschreibung gehört zu einer Risiko-Stufe
    let desc: [String] = [
        "Roter Bereich-Akute Gefährdung/Hochrisiko. Der Patient befindet sich in einem kritischen Zustand. Es Sind sorfortige Maßnahmen erforderlich. Empfohlene Therapie: engmachiges Monitoring, sofortige klinische Abklärung, Anpassung der Medikation nach ärtzlicher Rücksprache sowie ggf. Einweisung  in eine Notfallbehandlung.",
        "Gelber bereich-Mittelrisiko / Beobachtung erforderlich. Der Patient zeigt auffällige, aber nicht akut bedrohliche Werte. Empfohlene Therapie: regelmäßiges Monitoring, Überprüfung der aktuellen Medikation, Anpassung des Lebensstils(Bewerbung, Ernährung),sowie erneute Bewertung durch medizinisches Fachpersonal.",
        "Grüner Bereich-Niedriges Risiko / stabiler Zustand. Der Zustand des Patienten ist stabil. Empfohlene Therapie: Standardkontrollen in regulären Intervallen, Förderung eines gesunden Lebensstils und fortlaufende Dokumentation ohne akuten Intervationsbedarf."
    ]
}
