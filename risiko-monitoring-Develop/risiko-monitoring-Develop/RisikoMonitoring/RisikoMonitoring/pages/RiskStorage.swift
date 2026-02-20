import Foundation

// enum für alle Funktionen zur lokalen Speicherung
enum RiskStorage {
    static let folderName = "RiskAssessments" //in dem unterordner werden die Risikobewertungen gespeichert

    //URL zum lokalen Speicherordner der App
    static var folderURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = docs.appendingPathComponent(folderName, isDirectory: true)
        // Falls der Ordner noch nicht existiert, wird er erstellt
        if !FileManager.default.fileExists(atPath: folder.path) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }
    // Speichert JSON-Daten als Datei im lokalen Ordner
    static func saveJSON(data: Data, fileName: String) throws -> URL {
        let url = folderURL.appendingPathComponent(fileName)
        try data.write(to: url, options: [.atomic])
        return url
    }
    // Listet alle gespeicherten Dateien im Ordner auf
    static func listFiles() -> [URL] {
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )) ?? []
        // Dateien nach Erstellungsdatum sortieren (neueste zuerst)
        return urls.sorted { a, b in
            let da = (try? a.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
            let db = (try? b.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? .distantPast
            return da > db
        }
    }
    // Liest den Textinhalt einer gespeicherten Datei
    static func readText(_ url: URL) -> String {
        (try? String(contentsOf: url, encoding: .utf8)) ?? "Kann Datei nicht lesen."
    }
    // Löscht eine gespeicherte Datei aus dem lokalen Speicher
    static func deleteFile(_ url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}
