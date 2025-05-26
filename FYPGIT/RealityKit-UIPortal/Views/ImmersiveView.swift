/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's immersive view.
*/

import SwiftUI
import RealityKit
import AVFoundation
import NYPCampus

/// An immersive view that contains the box environment.
struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    
    static let markersQuery = EntityQuery(where: .has(PointOfInterestComponent.self))
    static let runtimeQuery = EntityQuery(where: .has(PointOfInterestRuntimeComponent.self))
    
    @State private var subscriptions = [EventSubscription]()
    @State private var attachmentsProvider = AttachmentsProvider()
    
    @State private var player: AVAudioPlayer?
    //@State private var audioController: AudioPlaybackController?
    
    // The average human height in meters.
    let avgHeight: Float = 0
    let root = Entity()

    var body: some View {
        
        RealityView { content, attachments in
            do {
                // Create the box environment on the root entity.
                
                // let rotation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0, 1, 0))
                // root.transform.rotation = rotation
                // Set the y-axis position to the average human height.
                // root.position.y += avgHeight
                // Reposition the root so it has a similar placement
                // as when someone views it from the portal.
                // root.position.z -= 1.0
                
                // Load the environment using the selected model name.
                attachmentsProvider.attachments.removeAll()
                try await createEnvironment(on: root, modelName: appModel.selectedModelName)
                content.add(root)
                
                subscriptions.append(content.subscribe(to: ComponentEvents.DidAdd.self, componentType: PointOfInterestComponent.self, { event in
                    createLearnMoreView(for: event.entity)
                }))
                
                playSound(for: appModel.selectedModelName)
                
            } catch {
                print("Failed to load environment: \(error.localizedDescription)")
            }
            
        } update: { content, attachments in
            
            root.scene?.performQuery(Self.runtimeQuery).forEach { entity in
                
                guard let component = entity.components[PointOfInterestRuntimeComponent.self] else { return }
                
                // Get the entity from the collection of attachments keyed by tag.
                guard let attachmentEntity = attachments.entity(for: component.attachmentTag) else { return }
                
                guard attachmentEntity.parent == nil else { return }
                
                // SwiftUI calculates an attachment view's expanded size using the top center as the pivot point. This
                // raises the views so they aren't sunk into the terrain in their initial collapsed state.
                entity.addChild(attachmentEntity)
                attachmentEntity.setPosition([0.0, 0.4, 0.0], relativeTo: entity)
                content.add(entity)
                
            }
        
        } attachments: {
            
            ForEach(attachmentsProvider.sortedTagViewPairs, id: \.tag) { pair in
                Attachment(id: pair.tag) {
                    pair.view
                }
            }
            
//            ForEach(getAttachmentIDs(for: appModel.selectedModelName), id: \.id) { attachment in
//                Attachment(id: attachment.id) {
//                    LearnMoreView(
//                        name: attachment.name,
//                        description: attachment.description,
//                        position: attachment.position,
//                        rotation: attachment.rotation,
//                        imageNames: attachment.imageNames,
//                        videoName: attachment.videoName
//                    )
//                }
//            }
            
        }
        .gesture(TapGesture().targetedToAnyEntity()
            .onEnded({ value in
                // Apply the tap behavior on the entity
                _ = value.entity.applyTapForBehaviors()
            })
        )
    }
    
    private func createLearnMoreView(for entity: Entity) {
        
        // If this entity already has a RuntimeComponent, don't add another one.
        guard entity.components[PointOfInterestRuntimeComponent.self] == nil else { return }
        
        // Get this entity's PointOfInterestComponent, which is in the Reality Composer Pro project.
        guard let pointOfInterest = entity.components[PointOfInterestComponent.self] else { return }
        
        let tag: ObjectIdentifier = entity.id
        let name = LocalizedStringResource(stringLiteral: pointOfInterest.name)
        let description = LocalizedStringResource(stringLiteral: pointOfInterest.description)
        let view = LearnMoreView(name: String(localized: name),
                                 description: String(localized: description),
                                 imageNames: pointOfInterest.imageNameArray,
                                 videoName: pointOfInterest.videoName
        ).tag(tag)
        
//        let view = LearnMoreView(name: String(localized: name),
//                                 description: String(localized: description),
//                                 imageNames: pointOfInterest.imageNames,
//                                 trail: trailEntity,
//                                 viewModel: viewModel)
//            .tag(tag)
        
        entity.components[PointOfInterestRuntimeComponent.self] = PointOfInterestRuntimeComponent(attachmentTag: tag)
        
        attachmentsProvider.attachments[tag] = AnyView(view)
        
    }
    
    @MainActor
    func playSound(for scene: String) {
        // Map scenes to their respective audio files
        let audioFiles: [String: String] = [
            "HiveScene": "Studying.wav",
            "FypLabScene": "Lofi_Rain.wav"
        ]
        
        // Get the corresponding audio file for the selected scene
        guard let fileName = audioFiles[scene],
              let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            print("Audio file not found for scene: \(scene)")
            return
        }
        
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}

// Updated createEnvironment function to accept a modelName
@MainActor
func createEnvironment(on root: Entity, modelName: String) async throws {
    // Load the environment root entity asynchronously.
    //let assetRoot = try await Entity(named: modelName)
    root.removeFromParent()
    root.children.removeAll()
    
    
    let assetRoot = try await Entity(named: modelName, in: NYPCampus.nYPCampusBundle)
    print("AssetRoot: \(assetRoot)")
    

    // Add the environment to the root entity.
    root.addChild(assetRoot)
}

// A struct to hold attachment details.
struct AttachmentInfo {
    let id: String
    let name: String
    let description: String
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let imageNames: [String]
    let videoName: String?
}


//Retrieves the attachment configurations for each environment.
//func getAttachmentIDs(for environment: String) -> [AttachmentInfo] {
//    switch environment {
//    case "HiveScene":
//        return [
//            AttachmentInfo(
//                id: "studyCornerInfo",
//                name: "Study Corner",
//                description: "A serene space designed for focused learning and deep work.",
//                position: SIMD3<Float>(0.0, 1.5, 2.5),
//                rotation: simd_quatf(angle: .pi / 1, axis: SIMD3<Float>(0, 1, 0)),
//                imageNames: ["Hivestudy"],
//                videoName: "null"
//            ),
//            AttachmentInfo(
//                id: "hiveInfo",
//                name: "Hive",
//                description: "A dynamic co-working space fostering collaboration and creativity.",
//                position: SIMD3<Float>(1.0, 1.5, -1.0),
//                rotation: simd_quatf(angle: .pi / 180, axis: SIMD3<Float>(0, 1, 0)),
//                imageNames: ["Hive"],
//                videoName: "null"
//            )
//        ]
//    case "FypLabScene":
//        return [
//            AttachmentInfo(
//                id: "bicycleInfo",
//                name: "Safe Riding Bike",
//                description: "A virtual reality project for safe riding. This project leverages VR to teach road safety to cyclists, in a bid to counter the rise in accidents involving cyclists. The VR experience allows cyclists to practise safe riding behaviour in an immersive, yet safe and controlled environment.",
//                position: SIMD3<Float>(0.0, 0.5, 0.0),
//                rotation: simd_quatf(angle: .pi * 3 / 4, axis: SIMD3<Float>(0, 1, 0)),
//                imageNames: ["Bicycle"],
//                videoName: "null"
//            ),
//            AttachmentInfo(
//                id: "robotInfo",
//                name: "Intelligent Guided Tour Robot",
//                description: "Let out intelligent tour robot, Passion, bring you through a technological journey co-created with our industry partners. The tour is organised into 8 technology sectors, each featuring a collection of interactive projects developed by our students and staff.",
//                position: SIMD3<Float>(-0.8, 0.8, -2.5),
//                rotation: simd_quatf(angle: .pi / 4, axis: SIMD3<Float>(0, 1, 0)),
//                imageNames: ["Robot"],
//                videoName: "null"
//            ),
//            AttachmentInfo(
//                id: "tvInfo",
//                name: "Immersive Technology Project",
//                description: "A VR application for RBS70 - a man-portable air defense system designed for anti-aircraft warfare. Trade and public visitors experienced a simulation of the weapon developed by SIT students during Singapore Airshow 2018. The application features friend or foe target identification and visual cues for firing of the missile.",
//                position: SIMD3<Float>(-1.5, 1.5, -0.5),
//                rotation: simd_quatf(angle: .pi * 3 / 4, axis: SIMD3<Float>(0, 1, 0)),
//                imageNames: ["TV"],
//                videoName: "Hummingbirds"
//            )
//        ]
//    default:
//        return []
//    }
//}
//
//@ViewBuilder
//func getViewForEnvironment(_ environment: String) -> some View {
//    switch environment {
//    case "HiveScene":
//        StudyCornerView() // Custom SwiftUI view for this space
//        LearnMoreView(name: "test", description: "test desc")
//    case "FypLabScene":
//        EquipmentDetailsView() // Custom SwiftUI view for this space
//        LearnMoreView(name: "Bicycle", description: "Tis a bike.")
//    default:
//        DefaultInfoView() // A fallback view
//    }
//}
//
//@MainActor
//struct DefaultInfoView: View {
//    var body: some View {
//        VStack {
//            Text("Default Info")
//                .font(.title)
//                .bold()
//            Text("This is default view.")
//                .padding()
//        }
//        .frame(width: 300, height: 200)
//        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//}
//
//
//@MainActor
//struct StudyCornerView: View {
//    var body: some View {
//        VStack {
//            Text("Study Corner")
//                .font(.title)
//                .bold()
//            Text("This is a quiet space for studying with comfortable seating and ample lighting.")
//                .padding()
//        }
//        .frame(width: 300, height: 200)
//        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//}
//
//@MainActor
//struct EquipmentDetailsView: View {
//    var body: some View {
//        VStack {
//            Text("FYP Lab")
//                .font(.title)
//                .bold()
//            Text("This lab contains various pieces of equipment for final-year projects, including a 3D printer and robotic kits.")
//                .padding()
//        }
//        .frame(width: 300, height: 200)
//        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
//    }
//}
//
// //Creates buttons specific to the environment and positions them.
//@MainActor
//func createEnvironmentButtons(for environment: String, on parent: Entity) {
//    // Example configuration for environments
//    let buttonConfigurations: [String: [(position: SIMD3<Float>, label: String, rotation: simd_quatf)]] = [
//        "HiveScene": [
//            (position: SIMD3<Float>(-4.0, 1.5, 0.0), label: "Study Corner", rotation: simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0, 1, 0))),
//            (position: SIMD3<Float>(0.5, 1.5, 0.0), label: "Hive", rotation: simd_quatf(angle: -.pi / 12, axis: SIMD3<Float>(0, 1, 0)))
//                ],
//                "FypLabScene": [
//                    // TV facing forward
//                    (position: SIMD3<Float>(-1.0, 1.5, -1.0), label: "TV", rotation: simd_quatf(angle: .pi / 4, axis: SIMD3<Float>(0, 1, 0))),
//                    // Bicycle facing sideways
//                    (position: SIMD3<Float>(-1.0, 0.5, 0.0), label: "Bicycle", rotation: simd_quatf(angle: .pi / 4, axis: SIMD3<Float>(0, 1, 0))),
//                    // Robot facing diagonally
//                    (position: SIMD3<Float>(2.0, 0.5, -0.8), label: "Robot", rotation: simd_quatf(angle: -.pi / 4, axis: SIMD3<Float>(0, 1, 0)))
//                ]
//    ]
//
//    guard let buttons = buttonConfigurations[environment] else { return }
//
//        for buttonConfig in buttons {
//            let buttonEntity = createButton(label: buttonConfig.label)
//            buttonEntity.position = buttonConfig.position
//            buttonEntity.orientation = buttonConfig.rotation // Apply fixed rotation
//            parent.addChild(buttonEntity)
//        }
//}
//
//
//
//Creates a forward-facing big red button with a dark metallic holder and a label.
//@MainActor
//func createButton(label: String) -> Entity {
//    let buttonEntity = Entity()
//
//    // Create the cylinder (button base)
//    let buttonMesh = ModelEntity(
//        mesh: .generateCylinder(height: 0.03, radius: 0.05), // Correct parameter order
//        materials: [SimpleMaterial(color: .red, roughness: 0.2, isMetallic: true)] // Glossy, metallic red
//    )
//    // Rotate the cylinder to face forward
//    buttonMesh.orientation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
//    buttonEntity.addChild(buttonMesh)
//
//    // Create the cuboid holder
//    let holderMesh = ModelEntity(
//        mesh: .generateCylinder(height: 0.03, radius: 0.07),
//        materials: [SimpleMaterial(color: .lightGray, roughness: 0.7, isMetallic: true)] // Metallic dark gray
//    )
//    // Position the holder behind the cylinder
//    holderMesh.position = SIMD3<Float>(0, 0, -0.03)
//    holderMesh.orientation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(1, 0, 0))
//    buttonEntity.addChild(holderMesh)
//
//    // Add the label in front of the button
//    let text = ModelEntity(mesh: .generateText(
//        label,
//        extrusionDepth: 0.01,
//        font: .systemFont(ofSize: 0.1),
//        containerFrame: .zero,
//        alignment: .center,
//        lineBreakMode: .byWordWrapping
//    ))
//    text.position = SIMD3<Float>(0, 0, 0.15) // Place text in front of the button
//    text.model?.materials = [SimpleMaterial(color: .white, isMetallic: false)] // White label
//    buttonEntity.addChild(text)
//
//    return buttonEntity
//}
