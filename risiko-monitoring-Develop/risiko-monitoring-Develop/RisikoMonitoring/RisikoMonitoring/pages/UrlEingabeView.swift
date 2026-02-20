//
//  UrlEingabeView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//

import SwiftUI
/*
 Definiert eine View und dies Zeigt die Eingabe der Sever-Url
 */
struct UrlEingabeView: View {
    // Zugriff auf den globalen Service und enthält server-url VerbindungsTest,fehler
    @EnvironmentObject var fhirService: FHIRServiceView
    
    /*
     Lokaler zustabd für die eigegebene URL
     startwert ist leer
     Stuert, ob fehler-Alert angezeigt wird
     wird angezeigt,ob eine Verbindung getestet wird
     */

    @State private var serverUrl: String = ""
    @State private var showErrorAlert = false
    @State private var isLoading = false
    // wird true bei erfolgreicher Verbindung
    @State private var navigateToSuccess = false
     //gibt True oder False zurück und Button ist deaktiviert wenn url leer ist
    var isButtonDisabled: Bool {
        serverUrl.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                // Erklärungstext für den Benutzer
                Text("Hier können Sie die URL des FHIR-Servers eingeben.")
                    .font(.body)
                    .padding(.top, 40)
                // Eingabefeld für die Server-Url
                TextField("https://example.com/fhir", text: $serverUrl)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                // Code wird beim Klick ausgeführt
                 Button {
                    let trimmed = serverUrl.trimmingCharacters(in: .whitespacesAndNewlines)
                   // prüft ob die url gültig ist sonst Fehlermeldung
                    guard URL(string: trimmed) != nil else {
                        fhirService.connectionError = "Ungültige URL."
                        showErrorAlert = true
                        return
                    }
                    //speichert die Url im sitzung
                    fhirService.konfiguration(url: trimmed)
                    isLoading = true
                     // Verbindung wird getestet
                    Task {
                        await fhirService.testVerbindung()
                        isLoading = false
                        // prüft ob Verbindung erfolgreich war , dann Navigation
                        if fhirService.isConnected {
                            navigateToSuccess = true
                            
                        // Wenn Verbindung fehlgeschlagen ist , Fehler-Alert Anzeigen
                        } else {
                            showErrorAlert = true
                        }
                    }

                } label: {
                    Text(isLoading ? "Bitte warten…" : "Verbindung herstellen")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isButtonDisabled ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                // Button ist deaktiviert
                .disabled(isButtonDisabled)

                Spacer()

                // ✅ Navigation contrôlée
                NavigationLink(
                    destination: UrlGespeichertView(serverUrl: serverUrl),
                    isActive: $navigateToSuccess
                ) { EmptyView() }
            }
            .padding()
            .navigationTitle("Server konfigurieren")
            .alert("Verbindungsfehler", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(fhirService.connectionError ?? "Unbekannter Fehler")
            }
        }
    }
}
