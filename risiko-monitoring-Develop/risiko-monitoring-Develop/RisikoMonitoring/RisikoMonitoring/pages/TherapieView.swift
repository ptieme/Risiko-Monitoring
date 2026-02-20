//
//  TherapieView.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 29.11.25.
//

import SwiftUI

// Diese View zeigt therapie/ Risiko-Stufen
struct TherapieView: View {
    // Binding zur aktuellen Version
    //wird von einer anderen View gesteuert
    // Änderung wirkt sofort überall
    @Binding var currentIndex: Int
    
    // Gibt den aktuell ausgewälten so zu sagen Circle() zurück
    var currentPlanet: Planet {
        // holt den Circle hier als Planet gennant aus der Liste  mit dem aktuellen Index
        return Datas2.shared2.allPlanets[currentIndex]
    }
    //Funktion gibt eine Farbe zurück
    // Abhängig von der Risiko-Stuge
    func color(for planet: Planet) -> Color {
        //wird die Position geprüft
        switch planet.position {
        case 1: return.red
        case 2: return.yellow
        case 3: return.green
        default: return.gray
        }
    }
    var body: some View {
        NavigationStack{
            HStack{
                // Button geht einen Schritt zurück
                Button {
                    moveBackwards()
                } label: {
                    Image(systemName: "signpost.left.fill")
                        .font(.title)
                        .tint(.secondary)
                }
                Spacer()
                Text(currentPlanet.name)
                    .font(.title2.bold())
                    .italic()
                Spacer()
                // Button geht einen Schritt vor
                Button {
                    moveForward()
                } label: {
                    Image(systemName: "signpost.right.fill")
                        .font(.title)
                        .tint(.secondary)
                }

            }
            Divider()
            // Kreis- Form
            Circle()
                .fill(color(for: currentPlanet))
                .frame(width: 80, height: 80)
                .padding(.top, 8)
            // Zeigt Risiko-Stufe als Text
            Text("Risiko Stufe: \(currentPlanet.position)")
                .italic()
                .foregroundStyle(.secondary)
            Divider()
            
            
            ScrollView {
                Text(currentPlanet.description())
                    .padding()
            }
            
            
             
           
           Spacer()
            ScrollView(.horizontal) {
                HStack(spacing: 120) {
                    // Position als eindeutuge ID
                    ForEach(Datas2.shared2.allPlanets,id: \.position) { planet in
                        Button {
                            currentIndex = planet.position - 1
                        } label: {
                            VStack{
                                Circle()
                                    .fill(color(for: planet))
                                    .frame(width: 40, height: 40)
                                Text(planet.name)
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                            }
                        }

                       
                    }
                
                }
               
            }.padding()
                .background(.quaternary)
                .clipShape(RoundedRectangle(cornerRadius: 50))
               
            
        }
       
        
        

        
    }
    // Diese Funktion erhöht den Index
   func moveForward () {
       // Wenn letzter Planet erreicht
       if currentIndex == Datas2.shared2.allPlanets.count - 1 {
           // Sprint zurück zum ersten
           currentIndex = 0
       } else {
           // geh einen Schritt weiter
           currentIndex += 1
       }
    }
    // Rückwerts bewegen  verringert den Index
    func moveBackwards() {
        // Wenn sich auf der ersten Platen beziehungsweise erste Circle
        if currentIndex == 0 {
            // Sprint zum Letzten
            currentIndex = Datas2.shared2.allPlanets.count - 1
        } else {
            //Geh einen Schritt zurück.
            currentIndex  -= 1
        }
    }
}

#Preview {
    TherapieView(currentIndex: .constant(1))
}
