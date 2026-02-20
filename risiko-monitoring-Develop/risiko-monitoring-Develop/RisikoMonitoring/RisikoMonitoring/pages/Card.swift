//
//  Card.swift
//  RisikoMonitoring
//
//  Created by Laetitia  on 30.11.25.
//

import SwiftUI
// Diese zeigt eine Karte für ein Course-Element
struct Card: View {
    
     //List das System-Theme(Hell/Dunkle) aus
    @Environment(\.colorScheme) private var scheme
    /*
     @State bedeutet wenn course sich ändert, wird die Card neu gezeichnet
     hier enthält course z.B Name, Beschreibung, Icon, Farbe
     */
    @State var course: Course
    var body: some View {
        VStack{
            HStack(alignment: .bottom, content: {
                //Name kommt aus course.image
                Image(systemName: course.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 42, height: 42)
                    .foregroundColor(.white)
                    
                Spacer()
                Text(course.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    
            })
            Divider()
                .background(Color.white.opacity(0.4))
            Text(course.description)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        
                
        }
        .padding()
        .frame(minHeight: 150)
        .background {
            LinearGradient(
                colors: [course.color.opacity(0.85), course.color.opacity(1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay {
                //Nur im Dark Mode wird eine dunkle Schicht über den Verlauf gelegt
                //Dadurch wirkt die Karte dunkler und angenehmer für Nachtmodus
                if scheme == .dark {
                    Color.black.opacity(0.25)   // Stärke anpassen: 0.15–0.35
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(
            color: .black.opacity(scheme == .dark ? 0.35 : 0.15),
            radius: 6,
            y: 4
        )
        
        
        
    }
}

#Preview {
    VStack(spacing: 20) {
        Card(course: Datas.shared.courses[0])
            .preferredColorScheme(.light)

        Card(course: Datas.shared.courses[0])
            .preferredColorScheme(.dark)
    }
    .padding()
}
