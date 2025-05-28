import SwiftUI
import AVKit

struct OpenedVideoView: View{
    let videoName: String?
    var dismissAction: () -> Void
    @State private var isExpanded = false
    
    @State private var player: AVPlayer? // Video playing
    
    @Environment(AppModel.self) var appModel
    @Environment(\.dismissWindow) private var closeWindow
    @State private var dragOffset: CGSize = .zero
    @GestureState private var gestureOffset: CGSize = .zero
    
    //VideoURL From bumdle retrieval
    private var videoURL: URL? {
        guard let videoFileName = videoName else {return nil}
        return Bundle.main.url(forResource: videoFileName, withExtension: ".mp4")
        
    }
    
    var body: some View{
        ZStack{
            
            Color.black.ignoresSafeArea()
            
            VStack(){
                Text("Video showcase")
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
                
                VStack{
                    if let url = videoURL {
                        GeometryReader{ geo in
                            VideoPlayer(player: player)
                                .frame(width: geo.size.width, height: geo.size.width)
                                .offset(x: dragOffset.width + gestureOffset.width,
                                        y: dragOffset.height + gestureOffset.height)
                                .onAppear{
                                    player = AVPlayer(url: url)
                                    player?.play()
                                }
                                .scaleEffect(isExpanded ? 1.4 : 1)
                                .aspectRatio(contentMode: .fit)
                                .scaledToFit()
                                .gesture(
                                            isExpanded ?
                                            DragGesture()
                                                .updating($gestureOffset) { value, state, _ in
                                                    state = value.translation
                                                }
                                                .onEnded { value in
                                                    dragOffset.width += value.translation.width
                                                    dragOffset.height += value.translation.height
                                                }
                                            : nil
                                        )
                        }
                        
                    } else {
                        Text("Video not found")
                            .foregroundColor(.red)
                    }
                }.padding(10)
                
                HStack{
                    Button(
                        action:{
                            withAnimation{
                                isExpanded.toggle()
                                if !isExpanded {dragOffset = .zero}
                            }
                        }
                    ){
                        Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }.padding(10)
                    
                    Button("Close Video"){
                        player?.pause()
                        closeWindow(id: "OpenedVideo")
                        dismissAction()
                    }
                    .padding()
                }
                
            }
            .padding()
            .cornerRadius(12)
            .background(Color.black)
            .frame(maxWidth: 820, maxHeight: .infinity)
            .ignoresSafeArea()
        }
        }
        
    
}
