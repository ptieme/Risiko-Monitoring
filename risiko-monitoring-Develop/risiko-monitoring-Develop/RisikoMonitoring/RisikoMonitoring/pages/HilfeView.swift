//
//  HilfeView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//

import SwiftUI

// Diese View zeigt Hilfe und Informationsinhalte

struct HilfeView: View {
  
    // holt die Hilfdaten aus einer gemeinsamen Datenquelle
    let infos = DatasHilfe.shared3.hilfeSection1Points
    var body: some View {
        NavigationStack{
                    List {
                        // Definiert einen Abschnitt in der Liste
                        Section {
                            // Schleife über alle Hilfe-Elemente
                            ForEach(infos) { info in
                                //zeigt jede Hilfe-Zeile mit einer eigenen View
                                HilfeRow(info: info)
                            }
                        } header: {
                            HStack{
                               Label("Hilfe und Information", systemImage: "questionmark.cycle")
                                    .font(.largeTitle.bold())
                            }
                        }

                    }
                    .navigationTitle("Hilfe")
                    .listStyle(.insetGrouped)
            }
        }
    }


#Preview {
    HilfeView()
}
