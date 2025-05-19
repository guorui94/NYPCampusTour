/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's main entry point.
*/

import SwiftUI
import NYPCampus

@main
struct EntryPoint: App {
    @State private var appModel = AppModel()
    
    init() {
        NYPCampus.PointOfInterestComponent.registerComponent()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)

        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: "OpenedVideo"){
            ZStack{
                OpenedVideoView(videoName: appModel.selectedvideoName){
                    print("Dismissing Second window")
                    appModel.selectedvideoName = nil
                }
                .onAppear{
                    print("OpenedVideo window with: ", appModel.selectedvideoName ?? "nil")
                }
            }
            
            .environment(appModel)
            
        }
        .defaultSize(width: 820, height: 900)
        
        // Defines an immersive space as a part of the scene.
        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView().environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        

    }
}
