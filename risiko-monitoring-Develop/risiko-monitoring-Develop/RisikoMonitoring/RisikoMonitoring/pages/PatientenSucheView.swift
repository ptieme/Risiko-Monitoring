//
//  PatientenSucheView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//

import SwiftUI
//Diese View definiert patientenSuche
struct PatientenSucheView: View {
    // enthält Logik und Daten aus der API.
    @EnvironmentObject var fhirService: FHIRServiceView
    
    // Eingabefeld für id, vorname und Nachname
    @State var patientID: String = ""
    @State var nachname: String =  ""
    @State var vorname: String = ""
    // Zeigt ob die eine suche läuft gut für den User
    @State var isLoading: Bool = false
    // Stuert die Anzeige des Fehler-Dialogs
    @State var showAlert: Bool = false
    // Text für Fehlermeldung
    @State var alertMessage: String = ""
  
    // steuert die Navigation zur ergebnis-Seite
    @State  private var showResults: Bool = false
    
    var body: some View {
                    // formular für Eingaben
                    Form {
                        
                        Section(header: Text("Suchkriterien")) {
                            // Textfeld für Patienten-Id
                            TextField("ID", text: $patientID)
                                .textInputAutocapitalization(.never)
                                 // Tastatur
                                .keyboardType(.numbersAndPunctuation)
                            // Textfeld für Patienten-name
                            TextField("Name", text: $nachname)
                                .textInputAutocapitalization(.words)
                            // Textfeld für Patienten-vorname
                            TextField("vorname", text:$vorname)
                                .textInputAutocapitalization(.words)
                        }
                        
                        Section {
                            Button{
                                Task { await onSearch() }
                            } label: {
                                Text(fhirService.isLoading ? "Suche..." : "Suchen")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .disabled(fhirService.isLoading)
                            //Fußtext
                        } footer: {
                            Text("mindesten ein Suchfeld sollte ausgefüllt sein.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        // es wird geprüft, ob Patienten gefunden wurden
                        // zeigt Anzahl gefundenen Patienten
                        if fhirService.totalPatientsFound > 0 {
                            Text("\(fhirService.totalPatientsFound) Patienten gefunden")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .navigationTitle("Patientensuche")
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color(.systemBackground))
                    
         
                    .navigationDestination(isPresented: $showResults) {
                        ErgebnissView(results: fhirService.ergebnissSuche)
                            .environmentObject(fhirService)
                    }
         
                    .alert("Fehler", isPresented: $showAlert) {
                        Button("Ok", role: .cancel) {
                            
                        }
                    } message: {
                        Text(alertMessage)
                    }
             
        
       
    }
    // Funktion für die PatientenSuche
    
    private func onSearch () async {
        // es wird geprüft ob
        // Nachname eingegeben ist
        // vorname eingegeben ist
        // id eingegeben ist.
        let idOk = !patientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let nOk = !nachname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let vok = !vorname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // keine Feld ausgefüllt ? Fehlermeldung setzen
        if !idOk && !nOk && !vok {
            alertMessage = "Bitte mindestens ein Suchfeld ausfüllen."
            showAlert = true
            return
        }
        // Alte sucheregebnisse köschen
        fhirService.ergebnissSuche = []
        //Zähler zurücksetzen
        fhirService.totalPatientsFound = 0
        // Navigation deaktivieren
        showResults = false
        // startet die API-Suche
        await fhirService.PatientSuche(patientID: patientID, nachname: nachname, vorname: vorname)
        
       // es wird geprüft ob fehler existiert, sonst Fehlertext setzen
        if let err = fhirService.connectionError {
            // Alert Anzeigen
            alertMessage = err
            showAlert = true
            showResults = false
            // Navigation stoppen
            return
        }
        // Prüft, ob Ergebnisse existieren
        if !fhirService.ergebnissSuche.isEmpty {
            // Navigation zur Ergebnis-Seite
            showResults = true
        } else {
            // Keine Ergebnisse
            showResults = false
        }
    }
}

#Preview {
    PatientenSucheView()
        .environmentObject(FHIRServiceView())
}
