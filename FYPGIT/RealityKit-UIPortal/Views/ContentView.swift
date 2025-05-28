//
//  ContentView.swift
//  Tester6
//
//  Created by Amanda on 26/12/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var selectedArea: Area? // Tracks the selected area
    @Environment(AppModel.self) private var appModel // Environment object for app-wide state

    // Group areas by blocks
    private var blocks: [Block] = [
        Block(name: "Block L", areas: [
            Area(name: "FypLab", modelName: "FypLabScene"),
            Area(name: "Hive", modelName: "HiveScene")
        ]),
        Block(name: "Block A", areas: [
            //Area(name: "Hive", modelName: "HiveScene")
        ])
    ]

    var body: some View {
        NavigationSplitView {
            VStack {
                VStack {
                    Image("nyplogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200.0)
                        .padding(.top, 30)
                }
                .padding()
                
                
                
                // Iterate over each block to create a dropdown menu
                ScrollView(.vertical) {
                    ForEach(blocks) { block in
                        DropdownMenu(
                            title: block.name,
                            options: block.areas.map { $0.name },
                            viewMapping: createViewMapping(for: block.areas)
                        ) { selectedOption in
                            // Find and select the corresponding area
                            if let area = block.areas.first(where: { $0.name == selectedOption }) {
                                selectedArea = area
                                appModel.selectedModelName = area.modelName
                            }
                        }
                    }
                }
                Spacer()
            }
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
            //.navigationTitle("Areas")
        }
        detail: {

            if let selectedArea {
                // Use `selectedArea` as a dependency to refresh the view
                UIPortalView(modelName: selectedArea.modelName)
                    .environment(appModel)
                    .id(selectedArea.id) // Add a unique ID to force refresh
            } else {
                Text("Welcome to the NYP Campus App.")
                    .bold()
                    .padding(.bottom, 10)
                Text("Select an area in the dropdown menu to begin your journey.")
            }
        }
        .frame(minWidth: 700, minHeight: 700)
    }

    // Helper function to map areas to AnyViews
    private func createViewMapping(for areas: [Area]) -> [String: AnyView] {
        var mapping = [String: AnyView]()
        for area in areas {
            mapping[area.name] = AnyView(
                UIPortalView(modelName: area.modelName)
                    .environment(appModel)
            )
        }
        return mapping
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable
    @State var appModel = AppModel()
    ContentView().environment(appModel)
}
