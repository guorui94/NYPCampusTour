import RealityKit
import NYPCampus


@MainActor
func createEnvironment(on root: Entity, modelName: String) async throws -> Entity {
    let assetRoot = try await Entity(named: modelName, in: nYPCampusBundle)
    root.addChild(assetRoot)
    
    // Debug print for hierarchy
    print("ModelName: \(modelName), Root: \(root)")

    return assetRoot
}




