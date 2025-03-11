//
//  Areas.swift
//  RealityKit-UIPortal
//
//  Created by Amanda on 30/12/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation

struct Area: Identifiable {
    var name: String
    var modelName: String
    var id = UUID()
}
struct Block: Identifiable {
    let id = UUID()
    let name: String
    let areas: [Area]
}
