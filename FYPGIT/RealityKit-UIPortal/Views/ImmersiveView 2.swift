/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The app's immersive view.
*/

import SwiftUI
import RealityKit
import AVFoundation

/// An immersive view that contains the box environment.
struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    
    @State private var player: AVAudioPlayer?
    //@State private var audioController: AudioPlaybackController?
    
    /// The average human height in meters.
    let avgHeight: Float = 0

    var body: some View {
        RealityView { content, attachments in
            // Create the box environment on the root entity.
            let root = Entity()
            let rotation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0, 1, 0))
            root.transform.rotation = rotation

            // Set the y-axis position to the average human height.
            root.position.y += avgHeight

            // Load the environment using the selected model name.
            do {
                try await createEnvironment(on: root, modelName: appModel.selectedModelName)
            } catch {
                print("Failed to load environment: \(error.localizedDescription)")
            }

            content.add(root)

            // Load attachment entities dynamically
            for attachmentID in getAttachmentIDs(for: appModel.selectedModelName) {
                if let entity = attachments.entity(for: attachmentID.id) {
                    entity.position = attachmentID.position
                    entity.orientation = attachmentID.rotation
                    content.add(entity)
                }
            }

            // Reposition the root so it has a similar placement
            // as when someone views it from the portal.
            root.position.z -= 1.0
            

            //            let ambientAudioEntity = entity.findEntity(named: "ChannelAudio")
            //
            //            guard let resource = try? await AudioFileResource(named: "Forest_Sounds.wav") else {
            //                fatalError("Unable to find audio file Forest_Sounds.wav")
            //            }
            //
            //            audioController = ambientAudioEntity?.prepareAudio(resource)
            //            audioController?.play()
            //
            playSound(for: appModel.selectedModelName)
            
        } attachments: {
            ForEach(getAttachmentIDs(for: appModel.selectedModelName), id: \.id) { attachment in
                Attachment(id: attachment.id) {
                    LearnMoreView(
                        name: attachment.name,
                        description: attachment.description,
                        position: attachment.position,
                        rotation: attachment.rotation,
                        imageNames: attachment.imageNames,
                        videoName: attachment.videoName
                    )
                }
            }
        }
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

/// A struct to hold attachment details.
struct AttachmentInfo {
    let id: String
    let name: String
    let description: String
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let imageNames: [String]
    
    let videoName: String?
}

/// Retrieves the attachment configurations for each environment.
func getAttachmentIDs(for environment: String) -> [AttachmentInfo] {
    switch environment {
    case "HiveScene":
        return [
            AttachmentInfo(
                id: "studyCornerInfo",
                name: "Study Corner",
                description: "A serene space designed for focused learning and deep work.",
                position: SIMD3<Float>(0.0, 1.5, 2.5),
                rotation: simd_quatf(angle: .pi / 1, axis: SIMD3<Float>(0, 1, 0)),
                imageNames: ["Hivestudy"],
                videoName: "null"
            ),
            AttachmentInfo(
                id: "hiveInfo",
                name: "Hive",
                description: "A dynamic co-working space fostering collaboration and creativity.",
                position: SIMD3<Float>(1.0, 1.5, -1.0),
                rotation: simd_quatf(angle: .pi / 180, axis: SIMD3<Float>(0, 1, 0)),
                imageNames: ["Hive"],
                videoName: "null"
            )
        ]
    case "FypLabScene":
        return [
            AttachmentInfo(
                id: "bicycleInfo",
                name: "Safe Riding Bike",
                description: "A virtual reality project for safe riding. This project leverages VR to teach road safety to cyclists, in a bid to counter the rise in accidents involving cyclists. The VR experience allows cyclists to practise safe riding behaviour in an immersive, yet safe and controlled environment.",
                position: SIMD3<Float>(-0.1, 1.0, 0.2), //height adjusted
                rotation: simd_quatf(angle: .pi * 3 / 4, axis: SIMD3<Float>(0, 1, 0)),
                imageNames: ["Bicycle"],
                videoName: "null"
            ),
            AttachmentInfo(
                id: "robotInfo",
                name: "Intelligent Guided Tour Robot",
                description: "Let out intelligent tour robot, Passion, bring you through a technological journey co-created with our industry partners. The tour is organised into 8 technology sectors, each featuring a collection of interactive projects developed by our students and staff.",
                position: SIMD3<Float>(-0.8, 1, -2.5),
                rotation: simd_quatf(angle: .pi / 4, axis: SIMD3<Float>(0, 1, 0)),
                imageNames: ["Robot"],
                videoName: "null"
            ),
            AttachmentInfo(
                id: "tvInfo",
                name: "Immersive Technology Project",
                description: "A VR application for RBS70 - a man-portable air defense system designed for anti-aircraft warfare. Trade and public visitors experienced a simulation of the weapon developed by SIT students during Singapore Airshow 2018. The application features friend or foe target identification and visual cues for firing of the missile.",
                position: SIMD3<Float>(-1.5, 1.5, -0.5),
                rotation: simd_quatf(angle: .pi * 3 / 4, axis: SIMD3<Float>(0, 1, 0)),
                imageNames: ["TV"],
                videoName: "Hummingbirds"
            )
        ]
    default:
        return []
    }
}


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


/// Updated createEnvironment function to accept a modelName
@MainActor
func createEnvironment(on root: Entity, modelName: String) async throws {
    // Load the environment root entity asynchronously.
    let assetRoot = try await Entity(named: modelName)

    // Add the environment to the root entity.
    root.addChild(assetRoot)
}

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


///// Creates buttons specific to the environment and positions them.
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
///// Creates a forward-facing big red button with a dark metallic holder and a label.
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

