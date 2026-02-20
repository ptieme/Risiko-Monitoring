//
//  APIClient.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 23.12.25.

//enthält URL, Url Requests und Data ...
//Ohne foundation kann man keine Netzwerk-Request bauen

import Foundation

// Sendable bedeutet die Struktur darf sich in async/parallel code benutzt werden
// Eine Hilfstruktur, die HTTP-Requests für die App erstellt

struct APIClient: Sendable {
    //speichert die Basis-Url des Servers
    let baseUrl: String
    let username: String
    let password: String
    
    // Die Funktion hier baut einen fertigen HTTP GET Request
    // Mit Server-Url , Endpoint, Optionalen Query-Parametern
    // Basic-Auth Header und Json Accept Header
    // Throws bedeutet Die Funktion kann Fehler werfen, wenn etwas falsch ist
    
     func makeRequest (_ endpoint: String , queryItems: [URLQueryItem] = []) throws ->  URLRequest  {
        let trimmed = baseUrl.trimmingCharacters(in: .whitespacesAndNewlines)
         // prüf ,ob die URL leer ist, wenn leer ,fehler wird geworfen.
         // Fehlertext wird in der UI angezeigt
        guard !trimmed.isEmpty else { throw NSError(domain: "API", code: 1, userInfo: [NSLocalizedDescriptionKey: "Bitte zu erst eine Server-URL eingeben"])}
         // Prüfung ob die Url mit / endet
         // Wenn ja wird es entfernt . wenn nein Url bleit dann gleiche
        let root = trimmed.hasSuffix("/") ? String(trimmed.dropLast()) : trimmed
         //Baut URLComponents aus Basis-URL + Endpoint
        guard var comps = URLComponents(string: root + endpoint) else {
            //Wenn URL ungültig Fehler werfen
            throw NSError(domain: "API", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL."])
        }
         // prüfung,ob es query-Parameter gibt
         // wird Query-Parameter hinzugefügt
        if !queryItems.isEmpty {comps.queryItems = queryItems}
        // erzeugt eine finale Url aus den Components
         // wenn das fhelschlägt fehler werfen
        guard let url = comps.url else {
            throw NSError(domain: "API", code: 3, userInfo: [NSLocalizedDescriptionKey: "Fehlerhafte URL."])
        }
         //Erstellt ein URLRequest-objekt mit der URL
        var req = URLRequest(url: url)
         //Setzt die HTTP-Methoden auf GET(nur lesen nichts ändern)
        req.httpMethod = "GET"
         // sagt dem server , ich antworte als JSON
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
         // Baut einen String für Basic Auth
         // wandelt den Auth-String in Base64 um
         
        let auth = "\(username):\(password)"
        let encoded = Data(auth.utf8).base64EncodedString()
         //Setzt den HTTP Header Authorization
        req.setValue("Basic \(encoded)", forHTTPHeaderField: "Authorization")
        //Gibt den fertigen URLRequest zurück
        // Dieser Request kann jetzt mit URLSession gesendet werden
        return req
    }
    
    
    
}
