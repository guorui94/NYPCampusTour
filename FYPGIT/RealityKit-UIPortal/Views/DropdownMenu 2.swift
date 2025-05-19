//
//  DropdownMenu.swift
//  NYPCampusTour
//
//  Created by Amanda on 13/12/24.
//

import SwiftUI

/// Purely the dropdown menu button.
struct DropdownMenu: View {
    let title: String
    let options: [String]
    let viewMapping: [String: AnyView]
    var onSelect: (String) -> Void // Callback for selection
    
    @State private var isOpen: Bool = false
    @State private var selectedOption: String? = nil //Tracting the selected option
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Dropdown button
            Button(action: {
                withAnimation {
                    isOpen.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                        .animation(.easeInOut(duration: 0.4), value: isOpen)
                        .padding(.trailing, 10)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            // Dropdown content
            if isOpen {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            onSelect(option) // Trigger selection callback
                            
                            selectedOption = option
                            isOpen = false
                        }) {
                            Text(option)
                                .font(.body)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .cornerRadius(5)
                                
                        }
                        .background(selectedOption == option ? Color.blue.opacity(0.3) : Color.clear)
                    }
                    Divider()
                }
                .transition(.opacity) // Smooth fade-in/out animation
            }
        }
        .cornerRadius(8)
        .padding(.horizontal, 10)
        
    }
}


/// Test to see what it looks like.
struct TestView: View {
    @State private var selectedArea: Area? // Tracks the selected area
        @Environment(AppModel.self) private var appModel // Environment object for app-wide state
        private var areas = [
            Area(name: "Block L", modelName: "FypLabScene"),
            Area(name: "Block A", modelName: "HiveScene")
        ]
        
        // Dropdown options
        private var dropdownOptions: [String] {
            areas.map { $0.name }
        }
        
        var body: some View {
            NavigationSplitView {
                VStack {
                    // Dropdown Menu
                    DropdownMenu(
                        title: selectedArea?.name ?? "Select an Area",
                        options: dropdownOptions,
                        viewMapping: areaViewMapping
                    ) { selectedOption in
                        // Find and select the corresponding area
                        if let area = areas.first(where: { $0.name == selectedOption }) {
                            selectedArea = area
                            appModel.selectedModelName = area.modelName
                        }
                    }
                    Spacer()
                }
                .navigationTitle("Areas")
            }
            detail: {
                if let selectedArea {
                    // Use `selectedArea` as a dependency to refresh the view
                    UIPortalView(modelName: selectedArea.modelName)
                        .environment(appModel)
                        .id(selectedArea.id) // Add a unique ID to force refresh
                } else {
                    Text("Select an area.")
                }
            }
            .frame(minWidth: 700, minHeight: 700)
        }
        
        // Mapping area names to AnyViews
        private var areaViewMapping: [String: AnyView] {
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


struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        @Previewable
        @State var appModel = AppModel()
        TestView().environment(appModel)
    }
}
