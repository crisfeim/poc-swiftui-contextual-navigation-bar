// © 2025  Cristian Felipe Patiño Rojas. Created on 23/7/25.


import SwiftUI

struct ContentView: View {
    @State var showSheet = false
    var body: some View {
        Button("Show sheet") {
            showSheet = true
        }
            .sheet(isPresented: $showSheet) {
                SheetView()
            }
    }
}


#Preview {
    ContentView()
}
