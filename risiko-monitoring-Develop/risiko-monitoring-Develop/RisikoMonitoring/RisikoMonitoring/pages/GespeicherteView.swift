import SwiftUI

// View, die gespeicherte Risikobewertungen als Dateien anzeigt,
// löschen kann und eine Text-Vorschau in einem Sheet öffnet

struct GespeicherteView: View {
    @State private var files: [URL] = []

    @State private var selectedPreviewURL: URL? = nil
    @State private var showPreview = false
    @State private var previewText = ""

    var body: some View {
        // Hauptliste der gespeicherten Dateien
        List {
            if files.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Keine gespeicherten Risikobewertungen.")
                        .font(.headline)
                    Text("Tippe in der Risikobewertung auf „Speichern“, damit hier Dateien erscheinen.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            ForEach(files, id: \.self) { url in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(url.lastPathComponent)
                            .font(.headline)
                            .lineLimit(2)

                        if let date = (try? url.resourceValues(forKeys: [.creationDateKey]).creationDate) {
                            Text(date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Image(systemName: "doc.text")
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedPreviewURL = url
                    showPreview = true
                }
            }
            // Aktiviert Swipe-to-Delete (Wischen zum Löschen)
            .onDelete(perform: delete)
        }
        .navigationTitle("Gespeichert")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Aktualisieren") { reload() }
            }
        }
        .onAppear { reload() }

        // Vorschau (kein Teilen)
        .sheet(isPresented: $showPreview) {
            NavigationStack {
                ScrollView {
                    Text(previewText.isEmpty ? "Datei ist leer oder konnte nicht geladen werden." : previewText)
                        .font(.system(.footnote, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle("Vorschau")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Schließen") { showPreview = false }
                    }
                }
                .onAppear {
                    if let url = selectedPreviewURL {
                        previewText = RiskStorage.readText(url)
                    } else {
                        previewText = ""
                    }
                }
            }
        }
    }
    // Lädt die Liste der gespeicherten Dateien neu
    private func reload() {
        files = RiskStorage.listFiles()
    }
    // Lädt die Liste der gespeicherten Dateien neu
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let url = files[index]
            try? RiskStorage.deleteFile(url)
        }
        // Löscht ausgewählte Dateien aus der Liste
        reload()
    }
}
