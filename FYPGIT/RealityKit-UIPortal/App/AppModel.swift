/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The model to contain app state.
*/

import Foundation
import SwiftUI
import Observation

/// Maintains app-wide state
@MainActor
@Observable
class AppModel: ObservableObject {
    
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var selectedModelName: String = ""

    var selectedvideoName: String? = nil
}
