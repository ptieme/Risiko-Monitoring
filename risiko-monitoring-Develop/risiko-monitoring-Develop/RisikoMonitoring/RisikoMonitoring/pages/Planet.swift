//
//  Planet.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 30.11.25.
//

import Foundation
// Diese View  wird für Basis-Typen benutzt
struct Planet {
    // Position des PLaneten
    var position: Int
    // name
    var name: String
    // gibt den Namen des Bildes zurück
    var iamgeName: String{
        return name.lowercased()
    }
    
    // Diese Funktion gibt die Beschreibung des Planeten Zurück
    func description() -> String{
        // berechnet Index für Array
        // Position beginnt bei 1 array bei 0
        let  index = position - 1
        // Holt die Beschreibung aus der gemeinsamen Datenquellen
        let Beschreibung = Datas2.shared2.desc[index]
        // Gubt die Beschreibung zurück.
        return Beschreibung
    }
}
