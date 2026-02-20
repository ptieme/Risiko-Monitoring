//
//  AnmeldungView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//
// der Import hier ist notwendig  für views, Text, Button und naviagtion
import SwiftUI

// Es wird eine View mit dem Name Anmeldeview definiert und zeigt den Login-Bildschrim
struct AnmeldungView: View {
    // Zugriff auf FHIRServiceVie
    @EnvironmentObject var fhirService : FHIRServiceView
    
    /*
     Lokaler Zustand für Benutzername
     @State View beobachtet diese Variablen
     @State = lokaler Zustand, den SwiftUI beobachtet.
     Wenn sich ein @State ändert, rendert SwiftUI die View neu.
     Aber Startwert ist leerer String
     Für Passwort wird im Securefield benutzt
     NavigateTourUrl steuert Navigation zur nächsten View
     Es wird auch gesteuert ob, Alert angezeigt wird oder nicht
     Es gibt Text für die Alert-Nachricht
     */
    
    @State private var fhirUsername: String = ""
    @State private var fhirPassword: String = ""
    @State private var navigateTourl = false
    @State private var showAlert = false
    @State private var alertMessage = ""
   
    // beschreibt wie die UI aussieht
    var body: some View {
        // ermöglicht navigation zu anderen Views
        NavigationStack{
            //Verticale Anordnung( oben nach unten)
            VStack{
                //horizontal Anordnung(links nach Rechts)
                HStack{
                    // Text auf dem Bildschrim
                    Text("Digitales Risiko\nMonitoring")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
              
                }.padding(.top,0)
                VStack(spacing: 40){
                    // EingabeFeld für benutzername , Keine automatische Großschreibung
                    TextField("FHIR Username", text: $fhirUsername)
                        .textInputAutocapitalization(.never)
                         // Autokorretur deaktivieren
                        .autocorrectionDisabled(true)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                     // Password Eingabefeld und Text wird verborgen
                    SecureField("FHIR Password", text: $fhirPassword)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding()
                        .frame(maxWidth:  .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                 
                .padding(.horizontal,24)
            }
            VStack{
              /*
               Button mit Action-Block und Leerzeichnen beim Username und beim Passwort
               wird entfernt
               wird auch geprüft ob der Feld leer ist dann wird ein Text für Alert gesetzt und Alert wird angezeigt
               */
                Button {
                    let trimmedUser = fhirUsername.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedPass = fhirPassword.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if trimmedUser.isEmpty || trimmedPass.isEmpty {
                        alertMessage = "Bitte füllen Sie alle felder aus."
                        showAlert = true
                        return
                    
                    }
                    //Übergibt  Loging-Daten an den Service und speichert Daten global
                    fhirService.toka(username: trimmedUser, password: trimmedPass)
                    navigateTourl = true
                    // setzt Loging-Status auf true
                    fhirService.isLoggedIn = true
                } label: {
                    Text("Anmelden")
                        .foregroundColor(.white)
                        .font(.title3.bold())
                       
                }.frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.blue)
                    .cornerRadius(14)

            }.padding(.top, 50)
         
        }
        .padding(.horizontal,24)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Fehler"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("Ok")))
        }
    }
}

#Preview {
    AnmeldungView()
        .environmentObject(FHIRServiceView())
}
