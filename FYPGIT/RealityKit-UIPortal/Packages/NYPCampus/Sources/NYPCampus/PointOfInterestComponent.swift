import RealityKit

public enum Location: String, Codable, CaseIterable {
    case Hive
    case FypLabScene
}

// Ensure you register this component in your app’s delegate using:
// PointOfInterestComponent.registerComponent()
public struct PointOfInterestComponent: Component, Codable {
    // This is an example of adding a variable to the component.
    public var location: Location = .FypLabScene
    
    public var id: String = "id"
    public var name: String = "Default POI"
    public var description: String = "Description"
    public var imageNames: String? = nil
    public var videoName: String? = nil
    
    // Computed property to parse the CSV into an array
    public var imageNameArray: [String] {
        imageNames?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? []
    }


        public init(name: String, description: String, imageNames: String, videoName: String) {
            self.name = name
            self.description = description
            self.imageNames = imageNames
            self.videoName = videoName
        }

}



