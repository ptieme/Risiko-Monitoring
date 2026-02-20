import SwiftUI

struct RootView: View {
    @EnvironmentObject var fhirService: FHIRServiceView

    var body: some View {
            NavigationStack {
                if fhirService.isLoggedIn {
                    HomeView()
                } else {
                    AnmeldungView()
            }
        }
    }
}
