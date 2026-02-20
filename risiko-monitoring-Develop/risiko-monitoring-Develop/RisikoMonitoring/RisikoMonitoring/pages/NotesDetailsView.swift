//
//  NotesDetailsView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 01.12.25.
//
import SwiftUI
import SwiftData

// Diese View ist für die Detailansicht einer Notiz
struct NoteDetailView: View {
    // Bindable Objekt aus Swiftdata
    // Änderungen werden automatisch gespeichert
    // note ist die Notiz, die bearbeitet wird
    @Bindable var note: Note
    
    var body: some View {
        List{
            VStack(alignment: .leading){
                Text("Nom: ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                // bindet Text an note.name
                TextField(note.name, text: $note.name)
            }
            VStack(alignment: .leading){
                 Text("Description: ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                // bindent Text an note.bsch
                TextEditor(text:$note.besch)
                    .frame(height: 150)
            }
            // Wird aufgerufen wenn note.name sich ändert
            // gibt alten und neuen Wert
            .onChange(of: note.name) { oldValue, newValue in
                // Aktualisiert Das Datum der Notiz
                note.updateDate()
            }
            .onChange(of: note.besch) { oldValue, newValue in
                note.updateDate()
            }
        }
    }
}
