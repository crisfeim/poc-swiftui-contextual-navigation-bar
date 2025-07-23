// © 2025  Cristian Felipe Patiño Rojas. Created on 23/7/25.

import SwiftUI

enum Destinations: String, View {
    case secondScreen
    case thirdScreen
    
    var body: some View {
        switch self {
        case .secondScreen: Screen2()
        case .thirdScreen: Text("Third and last screen")
        }
    }
    
    @ViewBuilder
    var contextualButtons: some View {
        switch self {
        case .secondScreen: Text("Contextual buttons")
        case .thirdScreen: Text("Some other buttons")
        }
    }
}

@Observable
class NavigationState {
    var path: [Destinations] = []
}

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navState = NavigationState()
    
    var body: some View {
        NavigationStack(path: $navState.path) {
            InitialSheetScreen()
                .environment(navState)
                .navigationDestination(for: Destinations.self) { destination in
                    
                    destination
                        .environment(navState)
                        .navigationBarHidden(true)
                    
                }
                .navigationBarHidden(true)
        }
        .overlay(navigationBar, alignment: .top)
        
    }
    
    var navigationBar: some View {
        HStack {
            backButton
            Spacer()
            contextualButtons
        }
        .padding()
        // Needs a background
        // to prevent taps to pass through
        .background(.white)
    }
    
    var backButton: some View {
        Button {
            if navState.path.isEmpty {
                dismiss()
            } else {
                navState.path.removeLast()
            }
        } label: {
            Image(systemName: "chevron.down")
                .rotationEffect(rotationAngle)
                .animation(.easeInOut, value: navState.path)
        }
    }
    
    var rotationAngle: Angle {
        Angle(degrees: navState.path.isEmpty ? 0 : 90)
    }
    
    var contextualButtons: some View {
        navState.path.last?.contextualButtons
    }
}

struct InitialSheetScreen: View {
    @Environment(NavigationState.self) var navState
    var body: some View {
        Button("Go to second screen") {
            navState.path.append(.secondScreen)
        }
    }
}

struct Screen2: View {
    @Environment(NavigationState.self) var navState
    var body: some View {
        Button("Go to third screen") {
            navState.path.append(.thirdScreen)
        }
    }
}


#Preview {
    SheetView()
}
