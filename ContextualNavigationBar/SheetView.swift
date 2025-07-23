// © 2025  Cristian Felipe Patiño Rojas. Created on 23/7/25.

import SwiftUI

protocol NavigableScreen: View {
    func contextualButtons() -> AnyView
}

struct NavigationItem: Hashable, Equatable {
    let id = UUID()
    let content: () -> any NavigableScreen
    
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


@Observable
class NavigationState {
    var path: [NavigationItem] = []
    
    func push<V: NavigableScreen>(_ view: V) {
        path.append(NavigationItem { view })
    }
}

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navState = NavigationState()
    
    var body: some View {
        NavigationStack(path: $navState.path) {
            InitialSheetScreen()
                .environment(navState)
                .navigationDestination(for: NavigationItem.self) { destination in
                    
                    AnyView(destination.content())
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
        navState.path.last?.content().contextualButtons()
    }
}

struct InitialSheetScreen: View {
    @Environment(NavigationState.self) var navState
    var body: some View {
        Button("Go to second screen") {
            navState.push(Screen2())
        }
    }
}

struct Screen2: NavigableScreen {
    @Environment(NavigationState.self) var navState
    var body: some View {
        Button("Go to third screen") {
            navState.push(Screen3())
        }
    }
    
    func contextualButtons() -> AnyView {
        AnyView(Text("Some button"))
    }
}


struct Screen3: NavigableScreen {
    var body: some View {
       Text("Screen 3")
    }
    
    func contextualButtons() -> AnyView {
        AnyView(Text("Some button"))
    }
}


#Preview {
    SheetView()
}
