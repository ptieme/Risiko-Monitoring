//
//  TextUtil.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 26.12.25.
//

import Foundation

// makiert den gesammten Enum
@MainActor

// Enthält nur statische Funktionen
enum TextUtil {
    // Statische Hilfunktion
    // nonisolate darf außerhalb des MainActors benutzt werden
    // nimmt einen Optionalen String
    nonisolated static func safeText(_ value: String?) -> String {
        //wenn Text nil ist. dann wird string leerer
        let t = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        // Wenn text leer ist  nicht vorhanden
        // Sonst Originaltext anzeigen.
        return t.isEmpty ? "nicht vorhanden" : t
    }
}
