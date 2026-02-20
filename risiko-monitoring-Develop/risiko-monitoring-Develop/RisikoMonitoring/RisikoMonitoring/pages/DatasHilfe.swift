//
//  DatasHilfe.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 02.12.25.
//

import Foundation
import SwiftUI

// Enhält statische Hilfdaten für die APP
class DatasHilfe {
    // Singleton- instanz
    // wird überall in der APP benutzt
    // Es gibt nur eine Instanz von DatasHilfe
    static let shared3 = DatasHilfe()
    
    // Konstante Liste von Hilfe-Elementen
    // Array von CourseHilfe
    let hilfeSection1Points: [CourseHilfe] = [
        // Erstes Hilfe-Objekt
        // icon ist ein Emoji für medzinischen Kontex
        CourseHilfe(icon:"🩺" ,
                    title: "Die App untertützt Medizinisches Fachpersonal bei schnellen Enschätzunng des Gesundheitszustands einer Patientin oder eines Patienten",
                    Beschreibung: "Die App hilf insbesondere bei:\n •frühzeitiger Erkennung kritischer Vitalwerte\n • Strukturierter Risikoanalyse\n •Dokumentation medizinischer Therapieempfehlungen\n •Verlaufskontrolle Und Entscheidungsunterstützung"),
        
        CourseHilfe(icon: "",
                    title: "Die App Verwendet drei standardisierte Risikostufen",
                    Beschreibung: "🔴 Hohes Risiko\n •Sofortige medizinische Intervantion erforderlich\n •Engmaschige Überwachung nötig\n •Therapieanpassung oder Eskalation kann  notwendig sein\n  🟡 Mittleres Risiko\n •Werte außerhalb der Normalbereiche\n •Erhöhtes Risiko, jedoc nicht akut kritisch\n  •Regelmäßige Kontrolle & Beobachtung erforderlich\n 🟢 Niedriges Risiko\n •Werte im Normalbereich\n •Routinekontrolle ausreichend\n •Kein unmittelbarer Handlungsbedarf"),
        
        CourseHilfe(icon: "💊",
                    title: "Was kann im Bereich Therapie gemacht werden",
                    Beschreibung: "Medizinisches Personal kann\n •Standardtherapien für jede Risikostufe einsehen\n •Eigene individuelle Therapiepläne hinzufügen\n •Einträge bearbeiten oder löschen\n • Therapien dauerhaft speichern(SwiftData)\n"),
        
        CourseHilfe(icon: "👤",
                    title: "In diesem Bereich können Benutzer\n",
                    Beschreibung: "•Nach ID, Name oder Vorname Suchen\n •Eine beliebige Anzahl an Patienten abfrage\n •Vitalparameterabrufen(Blutdruck, Puls, Temperatur)\n •Diagnosen und Medikation einsehen\n •Fehlende Daten werden Klar gekennzeichnet(nicht vorhanden)" ),
        
        CourseHilfe(icon: "📈",
                    title: "Risikoanalyse-Seite zeigt",
                    Beschreibung: "•Aktuelle Risikostufen pro Patient\n •Trendverläufe über Zeit(Diagramme)\n •Veränderungen der Vitalwerte\n •Export möglich(z.B. Json)"),
        
        CourseHilfe(icon: "🔐",
                    title: "Die App speichert keine persönlichen Daten extern.\n Alle Daten verbleiben lokal auf dem Gerät oder werden direkt aus dem FHIR-Server gelesen",
                    Beschreibung: "•Keine Weitergabe an Dritte\n •Authentifizierung notwendig\n •Lokale SwiftData-Speicherung")
        
    ]
}
