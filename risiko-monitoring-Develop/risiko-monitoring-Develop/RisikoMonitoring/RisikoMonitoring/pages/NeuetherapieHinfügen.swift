//
//  NeuetherapieHinfügen.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 01.12.25.
//

import SwiftUI
import SwiftData

// Diese View ist für die Verwaltung  neuer Therapien
struct NeuetherapieHinfu_gen: View {
    // Zugriff auf den SwiftData Databank-Kontext
    // es Wird für insert und delete benutzt
    @Environment(\.modelContext) var modelContext
    // lädt alle Notizen aus der Datenbank
    // Sortiert nach lastUpdate
    @Query(sort:\Note.lastUpdate, order: .reverse) var notes: [Note]
    // Steuert ob das Eingabe-Fenter angezeigt wird
    @State var showSheet =  false
    // Text für den Namen der neuen Therapie
    @State var text = ""
    var body: some View {
        NavigationStack {
            VStack {
                //Zeigt die Anzahl der gespeicherten Therapie
                Text("Anzahl von neuen Therapien: \(notes.count)")
                List {
                    //schleife über alle Notizen
                    ForEach(notes) { note in
                        NavigationLink {
                            NoteDetailView(note: note)
                        } label: {
                            VStack {
                                Text(note.name)
                                Text(note.dateString)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                
                            }
                        }
                    // wird aufgerufen beim Löschen
                    }.onDelete { indexSet in
                        //Schleife über ausgewählte Indizes
                        for index in indexSet {
                            //Löscht die Notiz aus der Datenbank
                            modelContext.delete(notes[index])
                        }
                    }
                }
            }
            .navigationTitle("Neue Therapien")
            .toolbar(content: {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        showSheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })

                }
                
            })
            .sheet(isPresented: $showSheet) {
                VStack{
                    Text("Fügen Sie eine neue  Therapie")
                    TextField("", text: $text)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200)
                    // Button hinfügen
                    Button("Hinfügen") {
                        // erstellt neue Notiz
                        let note =  Note(name: text,
                                         besch: "",
                                         lastUpdate: Date())
                        // Speichert Notizen in  der Datenbank
                        modelContext.insert(note)
                        text = ""
                        showSheet = false
                        //Button deaktiviert wenn Text leer ist.
                    }.disabled(text.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NeuetherapieHinfu_gen()
}
