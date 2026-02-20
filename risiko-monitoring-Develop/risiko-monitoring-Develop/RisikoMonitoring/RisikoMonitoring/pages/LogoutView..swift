//
//  LogoutView..swift
//  RisikoMonitoring
//
//  Created by Mahmoud Chahen on 14.02.26.
//

import SwiftUI

struct LogoutView: View {
    @EnvironmentObject var fhirService: FHIRServiceView

    var body: some View {
        VStack(spacing: 16) {
            Text("Sie werden abgemeldet …")
                .font(.title3)
            ProgressView()
        }
        .onAppear {
            fhirService.logout()
        }
    }
}

#Preview {
    LogoutView()
        .environmentObject(FHIRServiceView())
}
