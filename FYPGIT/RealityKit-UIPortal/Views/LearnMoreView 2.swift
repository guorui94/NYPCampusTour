import SwiftUI
import RealityKit
import AVKit

public struct LearnMoreView: View {
    let name: String
    let description: String
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let imageNames: [String]
    
    let videoName: String? //For video access
    

    @State private var showingMoreInfo = false
    @Namespace private var animation
    
    @State private var isExpanded = false
    @State private var player: AVPlayer? // Video playing
    
    @State private var isShowingVideoOverlay = false
    
    @Environment(AppModel.self) private var appModel
    @Environment(\.openWindow) private var openWindow
    
    private var imagesFrame: Double {
        showingMoreInfo ? 326 : 50
    }

    private var titleFont: Font {
        .system(size: 48, weight: .semibold)
    }

    private var descriptionFont: Font {
        .system(size: 36, weight: .regular)
    }
    
    //VideoURL From bumdle retrieval
    private var videoURL: URL? {
        guard let videoFileName = videoName else {return nil}
        return Bundle.main.url(forResource: videoFileName, withExtension: ".mp4")
        
    }

    public var body: some View {
        ZStack {
            VStack {
                ZStack(alignment: .center) {
                    if !showingMoreInfo {
                        Text(name)
                            .matchedGeometryEffect(id: "Name", in: animation)
                            .font(titleFont)
                            .padding()
                    }
                    
                    if showingMoreInfo {
                        VStack(
                            //alignment: .leading,
                            spacing: 10)
                        {
                            VStack{
                                Text(name)
                                    .matchedGeometryEffect(id: "Name", in: animation)
                                    .font(titleFont)
                                    .padding()
                                
                                Text(description)
                                    .font(descriptionFont)
                                    .fixedSize(horizontal: false, vertical: true) // Prevents text from forcing view to expand
                                    .padding(10)
                            }
                            .offset(y: isExpanded ? -80: 0)
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                            
                            VStack{
                                if let url = videoURL {
                                    
                                    VideoPlayer(player: player)
                                        .frame(
                                            alignment: .center)
                                        .scaleEffect(isExpanded ? 1.2 : 1)
                                        .aspectRatio(contentMode: .fit)
                                        .onAppear{
                                            player = AVPlayer(url: url)
                                            player?.actionAtItemEnd = .none
                                        }
                                        .scaledToFit()
                                    HStack{
                                        Button("New Window"){
                                            print("Opening window for video:", videoName ?? "nil")
                                            if appModel.selectedvideoName == nil {
                                                appModel.selectedvideoName = videoName
                                                openWindow(id: "OpenedVideo")
                                            }
                                                                                    
                                            //isShowingVideoOverlay = true
                                        }.padding(10)
                                        
                                        Button(
                                            action:{
                                                withAnimation{isExpanded.toggle()}
                                            }
                                        ){
                                            Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                                .padding()
                                                .background(Color.white.opacity(0.7))
                                                .clipShape(Circle())
                                        }
                                        .padding(10)
                                    }
                                }
                                else if !imageNames.isEmpty {
                                    Spacer()
                                        .frame(height: 10)
                                    
                                    ImagesView(imageNames: imageNames, isExpanded: isExpanded )
                                        .padding(.bottom, 10)
                                    //Additional Add ons to expand
                                        .onTapGesture {
                                            withAnimation{
                                            }
                                        }
                                        .frame(
                                            alignment: .center
                                        )
                                        .clipped()
                                }
                            }
                        }
                        .padding()
                        .frame(width: 750)
                    }
                }
                .frame(
                    maxWidth: 800
                )
                .padding(24)
                .background(Color.red)
                .glassBackgroundEffect()
                .onTapGesture {
                    withAnimation(.spring) {
                        showingMoreInfo.toggle()
                    }
                }
                .hoverEffect(
                    withAnimation{.automatic}
                ) //Hovering
            }
        }
        if isShowingVideoOverlay {
           VStack{
                OpenedVideoView(
                    videoName: videoName, dismissAction:{isShowingVideoOverlay = false}
                )
                .frame(width: 800, height: 900)
                .cornerRadius(20)
                .shadow(radius: 20)
                .transition(.scale)
            }
            .ignoresSafeArea()
            .cornerRadius(20)

        }
    }
}

struct ImagesView: View {
    let imageNames: [String]
    let isExpanded: Bool

    var body: some View {
        GeometryReader{ geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(imageNames, id: \.self) { imageName in
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height, alignment: .center)
                            .clipped()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height,  alignment: .center) // centers the hstack
                .multilineTextAlignment(.center)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)

        }            .frame(maxWidth: .infinity) // Ensures ScrollView expands to available width

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
                imageNames: ["Bicycle"],
                videoName: "Hummingbirds"
            )
        }
    }
}
