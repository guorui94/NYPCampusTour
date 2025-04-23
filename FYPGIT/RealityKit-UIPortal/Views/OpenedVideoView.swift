import SwiftUI
import AVKit

struct OpenedVideoView: View{
    let videoName: String?
    var dismissAction: () -> Void
    @State private var isExpanded = false
    
    @State private var player: AVPlayer? // Video playing
    
    //VideoURL From bumdle retrieval
    private var videoURL: URL? {
        guard let videoFileName = videoName else {return nil}
        let url = Bundle.main.url(forResource: videoFileName, withExtension: "mp4")
        print("Video URL att 2: \(url?.absoluteString ?? "Video not Found!")")
        return Bundle.main.url(forResource: videoFileName, withExtension: ".mp4")
        
    }
    
    var body: some View{
        ZStack{
            Color.black.ignoresSafeArea()
            
            VStack(){
                Text("Expanded video")
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
                
                VStack{
                    if let url = videoURL {
                        GeometryReader{ geo in
                            VideoPlayer(player: player)
                                .frame(width: geo.size.width, height: geo.size.width)
                                .onAppear{
                                    player = AVPlayer(url: url)
                                    player?.play()
                                }
                                .scaleEffect(isExpanded ? 1.2 : 1)
                                .aspectRatio(contentMode: .fit)
                                .scaledToFit()
                        }
                        
                    } else {
                        Text("Video not found")
                            .foregroundColor(.red)
                    }
                }.padding(10)
                
                HStack{
                    Button(
                        action:{
                            withAnimation{isExpanded.toggle()}
                        }
                    ){
                        Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }.padding(10)
                    
                    Button("Close Video"){
                        player?.pause()
                        dismissAction()
                    }
                    .padding()
                }
                
            }
            .padding()
            .cornerRadius(12)
            .background(Color.black)
            .frame(width: 800, height: 800)
            .ignoresSafeArea()
        }
        
        }
        
    
}
