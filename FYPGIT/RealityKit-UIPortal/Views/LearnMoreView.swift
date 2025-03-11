import SwiftUI
import RealityKit

public struct LearnMoreView: View {
    let name: String
    let description: String
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let imageNames: [String]

    @State private var showingMoreInfo = false
    @Namespace private var animation
    
    private var imagesFrame: Double {
        showingMoreInfo ? 326 : 50
    }

    private var titleFont: Font {
        .system(size: 48, weight: .semibold)
    }

    private var descriptionFont: Font {
        .system(size: 36, weight: .regular)
    }

    public var body: some View {
        VStack {
            ZStack(alignment: .center) {
                if !showingMoreInfo {
                    Text(name)
                        .matchedGeometryEffect(id: "Name", in: animation)
                        .font(titleFont)
                        .padding()
                }

                if showingMoreInfo {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(name)
                            .matchedGeometryEffect(id: "Name", in: animation)
                            .font(titleFont)

                        Text(description)
                            .font(descriptionFont)
                            .fixedSize(horizontal: false, vertical: true) // Prevents text from forcing view to expand

                        
                        if !imageNames.isEmpty {
                            Spacer()
                                .frame(height: 10)
                            
                            ImagesView(imageNames: imageNames)
                                .padding(.bottom, 10)
                        }
                    }
                    .padding()
                }
            }
            .frame(width: 700)
            .padding(24)
            .background(Color.red)
            .glassBackgroundEffect()
            .onTapGesture {
                withAnimation(.spring) {
                    showingMoreInfo.toggle()
                }
            }
        }
    }
}

struct ImagesView: View {
    let imageNames: [String]

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(imageNames, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center) // centers the hstack
        }
        .frame(maxWidth: .infinity) // Ensures ScrollView expands to available width
    }
}

#Preview {
    RealityView { content, attachments in
        if let entity = attachments.entity(for: "tvInfo") {
            entity.position = SIMD3<Float>(1.0, 1.5, 0.0)  // Example position
            entity.orientation = simd_quatf(angle: .pi / 4, axis: SIMD3<Float>(0, 1, 0)) // Example rotation
            content.add(entity)
        }
    } attachments: {
        Attachment(id: "tvInfo") {
            LearnMoreView(
                name: "TV",
                description: "It's a TV",
                position: SIMD3<Float>(1.0, 1.5, 0.0),
                rotation: simd_quatf(angle: .pi / 4, axis: SIMD3<Float>(0, 1, 0)),
                imageNames: ["Bicycle"]
            )
        }
    }
}
