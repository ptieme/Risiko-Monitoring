//
//  ErgebnissView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//

import SwiftUI
// Diese View für die Anzeige der Suchergebnisse
struct ErgebnissView: View {
    // enthält API-Logik und Daten
    @EnvironmentObject var fhirService: FHIRServiceView
    //speichert die ausgewälhten Patienten-IDS
    @State private var auswahlIDs: Set<String> = []
    // Zeigt Alert bei mehr als 3 Patienten
    @State private var showLimitAlert = false
    //steuert Navigation zur Risikobewertung
    @State private var goRisk = false
    // Liste der ausgewählten Patienten
    @State private var patientAuswahl: [PatientResult] = []
    // Zeigt fehler beim laden
    @State private var showLoadErrorAlert = false
    // Text der Fehlermeldung
    @State private var  loadErrorMessage = ""
    
    
    
    // Suchergebnisse von der vorherigen View
    let results: [PatientResult]
    var body: some View {
            VStack(spacing: 12) {
                //Prüft, ob keine Patienten gefunden wurden
                if results.isEmpty {
                    //Meldung für den Benutzer
                    Text("Keine Patienten gefunden")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ScrollView(.horizontal, showsIndicators: true) {
                        ScrollView {
                            VStack(spacing: 0) {
                                headerRow
                                // effiziente Liste für viele Daten
                                LazyVStack(spacing: 0) {
                                    // Schleife über alle Patienten
                                    ForEach(results) { p in
                                        // eine Ziele pro Patient
                                        row(p)
                                        Divider()
                                    }
                                }
                               
                            }
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 12)
                            .padding(.bottom, 12)
                        }
                       
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
                // Startet asynchronen Prozess
                Button {
                    Task { await startRisk()}
                } label: {
                    Text("Risikobewertung (\(auswahlIDs.count)/3)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(auswahlIDs.isEmpty)
                .padding(.horizontal, 12)
                .padding(.bottom,8)
                
            }
            .navigationTitle("Suchergebnisse")
            .navigationBarTitleDisplayMode(.inline)
            
            // Übergibt die ausgewählte Patienten
            .navigationDestination(isPresented: $goRisk) {
                RisikoBewertungView(patients: patientAuswahl)
                    .environmentObject(fhirService)
            }
            // zeigt warnung bei zu vielen Patienten
            .alert("Maximal 3 Patienten",  isPresented: $showLimitAlert) {
                Button("Ok", role: .cancel) {
                    
                }
            } message: {
                Text("Du kannst höchstens 3 Patienten auswählen")
            }
            // Fehler beim Laden von Patienten
            .alert("Fehler beim laden", isPresented: $showLoadErrorAlert) {
                Button("OK", role: .cancel) {
                    
                }
                //zeigt konkrete Fehlermeldung
            } message: {
                Text(loadErrorMessage.isEmpty ? "Unbekannter Fehler" : loadErrorMessage)
            }
            
        
    }
    
    
    
    
    //Kopfzeile der Tabelle
    private var headerRow: some View {
        HStack {
            Spacer().frame(width: Col.check)
            
            Text("Name").frame(width: Col.name, alignment: .leading)
            Text("Vorname").frame(width: Col.vorname, alignment: .leading)
            Text("Geschlecht").frame(width: Col.gender, alignment: .leading)
            Text("Geburt").frame(width: Col.birth , alignment: .leading)
            Text("Risiko").frame(width: Col.risk, alignment: .leading)
            
            
            
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal,12)
        .padding(.top, 6)
    }
    
    
    // es wird eine Zeile für einen Patienten erstellt
    private func row(_ p: PatientResult) -> some View {
        // es wird geprüft, ob Patient ausgewählt ist
        let isSelected = auswahlIDs.contains(p.patientID)
        
        return HStack(spacing: 10) {
            //checkbox Symbole
            //Breite der Checkbox
            // Blau , wenn es ausgewählt ist
            
            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                .frame(width: Col.check)
                .foregroundStyle(isSelected ? .blue : .secondary)
            // Nachname anzeigen, vorname etc...
            field(p.name, width: Col.name)
            field(p.vorname, width: Col.vorname)
            field(p.geschlecht, width: Col.gender)
            field(p.geburtsdatum, width: Col.birth)
            
            HStack(spacing: 6){
                // Kreis für risiko-Farbe
                Circle()
                    .fill(p.risikofarbe)
                    .frame(width: 10, height: 10)
                // RisikoText anzeigen
                Text(p.risikoText.isEmpty ? "nicht vorhanden" : p.risikoText)
                    .lineLimit(1)
            }
            .frame(width: Col.risk, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        // auswähl ändern
        .onTapGesture {
            toggleSelection(p.patientID)
        }
        
        
        
    }
    
    
    // zeigt Text mit Formatierung
    private func field(_ text: String, width: CGFloat) -> some View {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // es wird geproüft, ob wert fehlt
        let isMissing = t.isEmpty || t.lowercased() == "nicht vorhanden"
        // zeigt standardText
        return Text(isMissing ? "nicht vorhanden" : t)
        // Grau wenn es fehlt
            .foregroundStyle(isMissing ? .secondary : .primary)
            .frame(width: width, alignment: .leading)
        // Maximal 5 zeilen
            .lineLimit(5)
            .fixedSize(horizontal: false, vertical: true)
            .truncationMode(.tail)
            .contextMenu {
                Button("Kopieren") {
                    // Kopiert Text in Zwischenablage
                    UIPasteboard.general.string = t
                }
            }
    }
    
    // diese Funktion fügt Auswahl hinzu oder entfernt sie
    private func toggleSelection(_ id: String) {
        // Wenn bereits ausgewählt wird
        if auswahlIDs.contains(id) {
            //Auswahl entfernen
            auswahlIDs.remove(id)
            return
        }
        // Maximal 3 Patienten erlaubt
        if  auswahlIDs.count >= 3 {
            //alert anzeigen
            showLimitAlert = true
            return
        }
        //Patient auswählen
        auswahlIDs.insert(id)
    }
    
    
    //Diese Funktion startet Risikobewertung
    private func startRisk() async {
        // filtert ausgewählte Patienten
        let picked = results.filter { auswahlIDs.contains($0.patientID)}
        // speichert Auswahl
        patientAuswahl = picked
        
        //Fehlerbehandlung starten
        do {
            //lädt Detaildaten vom Backend
            try await fhirService.ladeDetailsVonPatient(patientIDs: picked.map {$0.patientID})
            // Navigation zur Risiko-View
            goRisk = true
            // Bei Fehler
        } catch {
            //Fehlertext speichern
            loadErrorMessage = error.localizedDescription
            //Fehler-Alert anzeigen
            showLoadErrorAlert = true
        }
    }
    
    
    
    
    
}
