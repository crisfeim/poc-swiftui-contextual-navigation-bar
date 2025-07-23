// © 2025  Cristian Felipe Patiño Rojas. Created on 23/7/25.

import SwiftUI

struct NavigationItem: Hashable, Equatable {
    let id = UUID()
    let content: () -> AnyView
    
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
    var contextualButtons: AnyView?
    
    func push<V: View>(_ view: V) {
        path.append(NavigationItem { AnyView(view) })
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
    
    @ViewBuilder
    var contextualButtons: some View {
        navState.contextualButtons
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

struct Screen2: View {
    @Environment(NavigationState.self) var navState
    var body: some View {
        Button("Go to third screen") {
            navState.push(Screen3())
        }
        .customNavigationButtons(Text("Some button"))
    }
}

struct Screen3: View {
   
    @State var count = 0
    var body: some View {
        Text(count.description)
            .customNavigationButtons(contextualButtons)
    }
    
    var contextualButtons: some View {
        Button("+") {
            count += 1
        }
    }
}

extension View {
    func customNavigationButtons<V: View>(_ buttons: V) -> some View {
        NavStateGetter(content: {AnyView(self)}, contextButtons: {AnyView(buttons)})
    }
}

fileprivate struct NavStateGetter: View {
    @Environment(NavigationState.self) var navState
    @ViewBuilder let content: () -> AnyView
    @ViewBuilder let contextButtons: () -> AnyView
    var body: some View {
        content()
            .onAppear {
                navState.contextualButtons = contextButtons()
            }
            .onDisappear {
                navState.contextualButtons = nil
            }
    }
}


#Preview {
    SheetView()
}
