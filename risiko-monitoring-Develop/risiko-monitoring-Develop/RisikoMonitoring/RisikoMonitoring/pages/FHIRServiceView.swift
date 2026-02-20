//
//  FHIRServiceView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 08.12.25.
//

/*
 Zweck der Datei. Diese Datei FhirserviceView.swift ist die Zentrale Logik der klasse der APP.
 Die Datei verwaltet die Verbindung zum FHIR-Server, speichert Benutzername und passwort und führt Patienten suche aus. Desweiterens lädt Risiko-Daten
 Vitalwerte, Diagnosen und Medikamente. Man kann auch feststellen,dass die Datei globale-App Zustände bereitstellt nämlich Login Onboarding und Navigation.
 */



/*
 SwiftUI ist notwendig für ObservableObject @Publisched,Color. Weiterhin ist Combine für automatische Aktiualisierung der UI bei Datenänderungen
 */
import Foundation
import SwiftUI
import Combine


/*
 Jetzt stellt sich die Frage warum @Mainactor. Laut Dokumentation passieren alle Änderungen auf dem Haupt-Thread und SwiftUI darf nur von Main Thread aktualisiert werden und verhindert sogar Abstürze und Swift-Concurrency-Fehler
 */
@MainActor


/*
jetzt kann die Klasse von Views beobachtet werden, deshabl verwendet man @EnvironmentObject.
 */

final class FHIRServiceView: ObservableObject {
    // Publisched macht eine Variable beobachtbar
    
    /*
     information über @Publisched Variablen
     Risiko-Infos Pro patient wird gespeichert
     Suchergebnisse werden gespeichert
     Vitalwerte pro Patient wird gespeichert
     */
    
    @Published var patientRiskInfo: [String: APIRiskResponse] = [:]
    @Published var ergebnissSuche:[PatientResult] = []
    @Published var patientVitals: [String: [APIVital]] = [:]
    
    /*
     Verbindung und Sitzung
     Loging-Status und Fehlermeldungen
     */
    @Published var baseUrl: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    
    @Published var isConnected: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var connectionError: String? = nil
    
    @Published var patient: [PatientResult] = []
    @Published var isLoading: Bool = false
    @Published var totalPatientsFound: Int = 0
    //Diagnosen und Medikamente pro Patient
    
    
    @Published var patientDiagnosen: [String: [String]] = [:]
    @Published var patientenMedikamente: [String: [String]] = [:]
    //Naviagtion und Auswahl
    @Published var selectedPatient: PatientResult? = nil
    @Published var navigateToRisk: Bool = false
    //Onboading-Status der App
    @Published var hasCompletedOnboarding: Bool = false
    @Published var hasSeenOnboarding: Bool = false


    
    /*
     Diese Funktion speichert die Server-Url und Leerzeichen am Anfang und Ende werden entfernt
     */
    func konfiguration(url: String) {
        self.baseUrl = url.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    /*
     Hier hat man eine weitere Funktion aber warum ist es Privat. Es wird intern benutzt und erzeugt immer ein Client mit Aktuellen Login-Daten.
     Zentrale Stelle für API-Zugriffe
     */
    private  func makeClient() -> APIClient {
        APIClient(baseUrl: baseUrl, username: username, password: password)
    }
    
    /*
     Die Funktion toka speichert Benutzername und Passwort und wird von AnmeldungView aufgerufen
     */
    
    
    func toka(username: String , password: String) {
        self.username = username
        self.password = password
    }
    
    
    
    
    /*
     Die Funktion hier läuft asynchron und await wartet auf Netzwerk-Antwrot
     */
     func testVerbindung () async {
         await MainActor.run {
             connectionError = nil
             isConnected = false
         }
        
       
        var trimmed = baseUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        trimmed = trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        let client = makeClient()
        guard var url = URL(string: trimmed) else {
            await MainActor.run {
                connectionError = "Ungültige URL"
            }
            return
        }
        
        
        
        do {
            
            let req = try client.makeRequest("/health")
            let(_, response) = try await URLSession.shared.data(for: req)
            
            guard let http = response as? HTTPURLResponse else {
                await MainActor.run {
                    connectionError = "Ungültige Serverantwort"
                  
                }
                return
            }
            if (200..<300).contains(http.statusCode) {
                await MainActor.run {
                    isConnected = true
                }
            } else if http.statusCode == 401 {
                await MainActor.run {
                    connectionError = "401: Unbefugter Zugriff -  Benutzername/ Passwort prüfen"
                }
            } else {
                await MainActor.run {
                    connectionError = "Serverfehler(\(http.statusCode))"
                }
            }
        } catch {
            await MainActor.run{
                connectionError = "Netzwerkfehler: \(error.localizedDescription)"
            }
        }
        
    }
    
    
    
    /*
     Diese Funktion sucht Patient über ID oder Vorname/Nachname und lädt danach automatisch Risiko-Daten.
     Es wird auch isloading für UI-Loader genutzt
     */
    
     func PatientSuche(patientID: String, nachname: String, vorname: String) async {
         /*
          hier wird UI werte gesetzt ,falls es Alte Fehler gibt wird gelöscht, alte ergebnisse auch gelöscht , falls man was neues ausfühgrt und loader wird auch aktiviert Beziehungsweise an und der Mainactor endet und am Ende ist loader aus
          */
         await MainActor.run {
             self.connectionError = nil
             self.ergebnissSuche = []
             self.totalPatientsFound = 0
             self.isLoading = true
         }
         defer { Task{ @MainActor in self.isLoading = false}}
        
      /*
       hier geht um ID Trimmen vorname trimmen
       */
        
        let idTrim = patientID.trimmingCharacters(in: .whitespacesAndNewlines)
        let lnTrim = nachname.trimmingCharacters(in: .whitespacesAndNewlines)
        let fnTrim = vorname.trimmingCharacters(in: .whitespacesAndNewlines)
        
         //APIClient erzeugen.
         
        let client = makeClient()
        /*
         Hier wird ein try catch gestartet .
         ID kann eingegebeben wurde
         ID muss zahl sein
         Die UI muss updated werden , Fehlermeldung kann auch auftreten.
         Danach hat man Ende von MainActor und Ende der Guard
         */
        do {
            if !idTrim.isEmpty {
                guard let idInt = Int(idTrim) else {
                    await MainActor.run {
                        connectionError = "Patienten-ID muss eine Zahl sein."
                        
                    }
                    return
                }
                
                /*
                 Was request hier angeht , haben wir patients mit query und danach hat man parameter patient_id und Ende queryItems
                 */
                let req = try client.makeRequest("/patients", queryItems: [
                    URLQueryItem(name: "patient_id", value: "\(idInt)")
                ])
                /*
                 Mit await erwarten wir immer eine Antwort das heißt,  die Antwort wird verabeiten und danach wird Risiko Daten nachgeladen und dann Ende der ID-Suche
                 */
                
                try await handlePatientListResponse(client: client, req: req, filterVorname: fnTrim, filterNachname: lnTrim)
                await enrichResultsWithBackendRisk()
                return
            }
            
            /*
             Wenn Felder leer sind nämlich Vorname und Nachnahme, muss UI updated werden und der user bekommt einen Hinweis
             */
            if lnTrim.isEmpty && fnTrim.isEmpty {
                await MainActor.run {
                    connectionError = "Bitte vorname/Nachname oder Patient-ID eingeben."
                }
                return
            }
            
            
            /*
             man kann die suche nach Vorname und Nachname machen
             und dann hat mat ein request patients mit suche.
             q=suche und der limit liegt bei 200 (Max) damit die App nicht langsam
             wird. offset ist hier mit erste Seite gemeint.
             */
            let q = !lnTrim.isEmpty ? lnTrim :  fnTrim
            
            let req = try client.makeRequest("/patients", queryItems: [
                URLQueryItem(name: "q", value: q),
                URLQueryItem(name: "limit", value: "200"),
                URLQueryItem(name: "offset", value: "0")
            ])
            
            /*
             Wie schon mal oben erwähnt Antwort verarbeiten und Risiko wird nachgeladen
             */
            
            try await handlePatientListResponse(client: client, req: req , filterVorname: fnTrim, filterNachname: lnTrim)
            await enrichResultsWithBackendRisk()
            
            /*
             Fehler beim Request kann auch auftreten. UI muss immer updatet werden und Fehlertext muss klar angezeigt werden
             */
        } catch {
            await MainActor.run {
                connectionError = error.localizedDescription
            }
           
        }
        
        
        
    }
    /*
     Diese Funktion verarbeitet Patient-Response.
     Request wird wird gesendet und Datenholen
     Es wird auch HTTP antwort geprüft  und Fehler geworfen
     */
    
    private func handlePatientListResponse(client: APIClient, req: URLRequest, filterVorname: String, filterNachname: String) async throws {
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "API", code: 10, userInfo: [NSLocalizedDescriptionKey: "Ungültige Serverantwort"])
        }
        
        // Wenn Status nicht ok ist , wenn 401 Fehler werfen
        guard (200..<300).contains(http.statusCode) else {
            if http.statusCode == 401 {
                throw NSError(domain: "API", code: 401, userInfo: [NSLocalizedDescriptionKey: "401: Unauthorized (Basic Auth prüfen)"])
            }
            throw NSError(domain: "API", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Serverfehler(\(http.statusCode)"])
        }
        // Json Decoder erzeugen
        let decoder  = JSONDecoder()
        /*
         Wrapper Format. Items aus Wrapper wird geholt.
         Filter wird angewendet und in PatientResult umwandeln.
         Wie auch Immer UI muss updated werden und Trefferzahl gesetzt
         Ergebniss wird gesetzt und fetig
         Ende der Wrapper decode
         
         */
        if let wrapper = try? decoder.decode(APIPatientListResponse.self, from: data) {
            var items = wrapper.items
            // filtrer si user a mis vorname et nachname
            items = filterPatients(items, vorname: filterVorname, nachname: filterNachname)
            let mapped = items.map{ mapPatientToResult(client: client, $0)}
            await MainActor.run {
                self.totalPatientsFound = wrapper.count ?? items.count
                self.ergebnissSuche = mapped
                    
            }
            return
                
            
           
        }
        
        /*
         Die Liste wird hier direkt decoded und filtern anweden und  in PatientResult
         anwenden. UI muss updated werden.
         Trefferzahl und Ergebniss  wird gesetzt
         Ende Funktion handlePatientListResponse
         */
        
        let list = try decoder.decode([APIPatient].self, from: data)
        let filtered = filterPatients(list, vorname: filterVorname, nachname: filterNachname)
        let mapped = filtered.map{ mapPatientToResult(client: client, $0)}
        await MainActor.run {
            self.totalPatientsFound = mapped.count
            self.ergebnissSuche = mapped
            
        }
      
    }
    // filtert patientenListe
    private  func filterPatients (_ patients: [APIPatient], vorname: String, nachname: String) -> [APIPatient] {
        //vorname und Nachname in klein
        let fn = vorname.lowercased()
        let ln = nachname.lowercased()
        
        // Filter anwenden, Patient-Vorname und Nachmane in klein
        return patients.filter{ p in
            let pf = p.firstName.lowercased()
            let pl = p.lastName.lowercased()
            
            
            /*
             Wenn kein vorname, ok sonst contains
             Wenn kein nachname, ok sonst contains
             Die beiden Bedingungen müssen stimmen
             */
            let okFn = fn.isEmpty ? true : pf.contains(fn)
            let okLn = ln.isEmpty ? true: pl.contains(ln)
            return okFn && okLn
            
            
        }
    }
        
        
        
        
        
    /*
     PatientResult.
     Gender sicher lesen
     Männlich Weiblich sonst nicht vorhanden
     Patientresult wird gebaut, ID als String
     */
    private func mapPatientToResult(client: APIClient, _ p: APIPatient) -> PatientResult {
        let gender = TextUtil.safeText(p.gender).uppercased()
            let genderText: String
            if gender == "M" {genderText = "Männlich"}
            else  if gender == "F" {genderText = "Weiblich"}
            else { genderText = (gender == "Nicht Vorhanden") ? "nicht vorhanden" : gender}
            
            return PatientResult(
                patientID: "\(p.id)",
                name: TextUtil.safeText(p.lastName),
                vorname: TextUtil.safeText(p.firstName),
                geburtsdatum: TextUtil.safeText(p.birthDate), geschlecht: genderText
                
            )
            
        }
        
        
    /*
     Risiko pro patient nachladen , client erzeugen ,
     Aktuelle Ergebnisse holen. wenn es leer ist , abbrechen
     IDS in Int umwandeln wenn keine IDS , abbrechen
     Kopie, damit wir lokal ändern
     */
    private func enrichResultsWithBackendRisk() async {
        let client = makeClient()

        let current = await MainActor.run { self.ergebnissSuche }
        guard !current.isEmpty else { return }

        let ids = current.compactMap { Int($0.patientID) }
        guard !ids.isEmpty else { return }

        var updated = current

        /*
         Parallel Tasks starten . für jede Patient Task hinfügen
         */
        let riskMap: [Int: APIRiskResponse] = await withTaskGroup(of: (Int, APIRiskResponse?).self) { group in
            for id in ids {
                group.addTask {
                    do {
                    

                        let  req = try await MainActor.run{
                            try client.makeRequest("/patients/\(id)/risk")
                        }
                        // Request senden
                        let (data, resp) = try await URLSession.shared.data(for: req)
                        // Antwort wird geprüft  . wenn es nicht okay ist nil risiko
                        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                            return (id, nil)
                        }

                      
                        //Decode auf Mainactor und json APIRiskResponse
                        let risk = try await MainActor.run {
                            try  JSONDecoder().decode(APIRiskResponse.self, from: data)
                        }
                        // ergebniss zurück. wenn fehler dann Risiko nil
                        return (id, risk)
                    } catch {
                        return (id, nil)
                    }
                }
            }
            // Temeporär Map und Ergebnisse aller Tasks sammeln. Nur wenn Risiko da wird es gespeichert
            var tmp: [Int: APIRiskResponse] = [:]
            for await (id, r) in group {
                if let r { tmp[id] = r }
            }
            //Map zurück geben
            return tmp
        }

        // Alle Patienten in updated durchgehen und ID in int sonst skip
        for i in updated.indices {
            guard let id = Int(updated[i].patientID) else { continue }
            // Wenn risiko Vorhanden
            if let r = riskMap[id] {
                // Globale cache setzen
                await MainActor.run { self.patientRiskInfo["\(id)"] = r }
                /*
                 Wenn vitalwerte im risiko vorhanden, pulls setzen oder Fallback
                 sys setzen,Dia setzen, Temp formatieren
                 Aber wenn es keine Vitals im Risiko Fallback
                 */
                if let v = r.usedLatestVitals {
                    updated[i].puls = v.pulse.map(String.init) ?? "nicht vorhanden"
                    updated[i].blutdruckSys = v.systolicBp.map(String.init) ?? "nicht vorhanden"
                    updated[i].blutdruckDia = v.diastolicBp.map(String.init) ?? "nicht vorhanden"
                    updated[i].temperatur = v.temperature.map { String(format: "%.1f", $0) } ?? "nicht vorhanden"
                } else {
                    updated[i].puls = "nicht vorhanden"
                    updated[i].blutdruckSys = "nicht vorhanden"
                    updated[i].blutdruckDia = "nicht vorhanden"
                    updated[i].temperatur = "nicht vorhanden"
                }
                
                /*
                 Risikolevel text plus farbe . Text wird in ergebniss gespeichert
                 Farbe ähnlich
                 */

                let (text, color) = mapBackendRisk(level: r.level)
                updated[i].risikoText = text
                updated[i].risikofarbe = color
                
                // Wenn keine  Risiko dann Fallback
            } else {
                updated[i].risikoText = "Risiko unbekannt"
                updated[i].risikofarbe = .gray
            }
        }
         // UI- list aktualisieren
        await MainActor.run { self.ergebnissSuche = updated }
    }

            
            
        
        
        /*
         wandelt-Backend-werte um HIGH zu Rot, MEDIUM zu Geld, Low zu Grün
         */
       private func mapBackendRisk(level: String) -> (String, Color) {
           switch level.uppercased() {
           case "HIGH":  return ("Hohes Risiko", .red)
           case "MEDIUM": return ("Mittleres Risiko", .yellow)
           case "LOW": return ("Niedriges Risiko", .green)
           default:  return ("Risiko unbekannt", .gray)
           }
         }
        
        
        
        
        
        
        
        
        /*
         lädt dignosen und Medikamente pro Patient. Fehler werden pro Patient abgefangen
         */
     func ladeDetailsVonPatient (patientIDs: [String]) async throws {
           
         // Diagnose löschen Medikamente
            await MainActor.run {
                 patientDiagnosen = [:]
                 patientenMedikamente = [:]
            }
            
          // Client bauen , IDS string in int, Wenn es leer ist, passiert nicht
            let client = makeClient()
            let  ids = patientIDs.compactMap { Int($0)}
            if ids.isEmpty { return }
           /*
            Parallel pro patient arbeiten.
            Für jede ID
            Task, self weak um Memory-Leaks zu vermeiden
            wenn self weg ist Task abbrechen
            */
            try await withThrowingTaskGroup(of: Void.self) { group in
                for id in ids {
                    group.addTask {[weak self] in
                        guard let self else {return}
                        
                        do {
                            // Bereich von Diagnoses und Endpoint Diagnosen
                            
                            let req = try await MainActor.run {
                                try client.makeRequest("/patients/\(id)/diagnostics")
                            }
                            /*
                             Request wird gesendet und status prüfen.
                             Wenn Fehler dann leere Liste
                             Abbruch dieses Blocks
                             Ende Guard
                             decoder
                             decoder auf MainActor
                             */
                            let (data, resp) = try await URLSession.shared.data(for: req)
                            guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                                await MainActor.run {
                                    self.patientDiagnosen["\(id)"] = []
                                }
                                return
                            }
                            let  dec = JSONDecoder()
                            // json wrapper
                            let wrapper = try await MainActor.run {
                                try dec.decode(APIDiagnosticsResponse.self, from: data)
                            }
                            /*
                             liste im Mainactor bauen
                             Items und Name sicher und Nicht-Vorhanden raus
                             */
                            let list =  await MainActor.run {
                                wrapper.items.compactMap {TextUtil.safeText($0.diagnosticName)}
                                    .filter { $0 != "nicht vorhanden" }
                            }
                            /*
                             Speichern und wenn Fehler auftritt, leere liste setzen
                             */
                            await MainActor.run { self.patientDiagnosen["\(id)"] = list}
                        } catch {
                            await MainActor.run { self.patientDiagnosen["\(id)"] = []}
                        }
                        
                        // Bereiche von Medikamenten und selbe Prinzip wie Diagnose
                        do {
                            let req = try await MainActor.run {
                                try client.makeRequest("/patients/\(id)/medications")
                            }
                            let(data, resp) = try await URLSession.shared.data(for: req)
                            guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                                await MainActor.run {
                                    self.patientenMedikamente["\(id)"] = []
                                }
                                return
                            }
                            let dec = JSONDecoder()
                            let wrapper = try await MainActor.run {
                                try dec.decode(APIMedicationsResponse.self, from: data)
                            }
                            let list = wrapper.items.map { m in
                                
                                let name = TextUtil.safeText(m.medicationName)
                                let dose = TextUtil.safeText(m.dosage)
                                if name == "nicht vorhanden" { return "nicht vorhanden"}
                                return dose == "nicht vorhanden" ? name: "\(name) (\(dose))"
                            }.filter { $0 != "nicht vorhanden" }
                            await MainActor.run { self.patientenMedikamente["\(id)"] = list}
                        } catch {
                            await MainActor.run {self.patientenMedikamente["\(id)"] = []}
                        }
                    }
                }
                
                try await group.waitForAll()
            }
        }
        
      /*
       Die hier lädt Vitalwerte(Puls, Blutdruck , Temperatur) und nutzt limit für Performance und speichert Daten in Dictionary
       */
    func ladeVitalsVonPatient(patientIDs: [String], limit: Int = 200) async throws {
   
        let client = makeClient()
        let ids = patientIDs.compactMap {Int($0)}
        if ids.isEmpty { return }
        
        try await withThrowingTaskGroup(of:  (Int, [APIVital]).self) { group in
            for id in ids {
                group.addTask {
                    let req = try await MainActor.run {
                        try client.makeRequest("/patients/\(id)/vitals", queryItems: [
                            URLQueryItem(name: "limit", value: "\(limit)")
                        ])
                    }
                    
                    let (data, resp) = try await URLSession.shared.data(for: req)
                    
                    guard let http = resp as? HTTPURLResponse else {
                        throw NSError(domain: "API", code: 10, userInfo: [NSLocalizedDescriptionKey: "Ungültige Serverantwort"])
                    }
                    
                    guard (200..<300).contains(http.statusCode) else {
                        if http.statusCode == 401 {
                            throw NSError(domain: "API", code: 401, userInfo: [NSLocalizedDescriptionKey:"401: Unauthorized (Basic Auth prüfen)"])
                        }
                        throw NSError(domain: "API", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey:"Serverfehler(\(http.statusCode)"])
                    }
                    let wrapper: APIVitalsResponse = try await MainActor.run {
                        //APIvitalresponse
                        try JSONDecoder().decode(APIVitalsResponse.self, from: data)
                    }
                    //Rückgabe von id + vitals-items
                    return (id, wrapper.items)
                }
            }
            /*
             Temp dictionary(string id zu vitals)
             */
            var tmp: [String: [APIVital]] = [:]
            // ergebniss wird gesammelt und in tmp gespeichert
            for try await(id,items) in group {
                tmp["\(id)"] = items
            }
            // UI wird updated , ende MainActor , ende Taskgroup  und ende der Funktion
            await MainActor.run {
                self.patientVitals = tmp
            }
        }
    }
        
    func logout() {
        // Login/Sitzung zurücksetzen
        isLoggedIn = false
        isConnected = false
        connectionError = nil

        // Zugangsdaten löschen
        username = ""
        password = ""

        // Onboarding/Setup zurücksetzen
        hasCompletedOnboarding = false
        hasSeenOnboarding = false
        baseUrl = ""

        // Navigation/Selection zurücksetzen
        selectedPatient = nil
        navigateToRisk = false

        // Daten-Caches leeren
        ergebnissSuche = []
        patient = []
        totalPatientsFound = 0

        patientRiskInfo = [:]
        patientVitals = [:]
        patientDiagnosen = [:]
        patientenMedikamente = [:]
    }
}

    


