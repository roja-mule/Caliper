//
//  ARSCNView.swift
//  Caliper
//
//  Created by Bhanuprasad Gollapudi on 27/08/18.
//  Copyright © 2018 GGK. All rights reserved.
//

import SceneKit
import ARKit

extension ARSCNView {
    
    func realWorldVector(screenPosition: CGPoint) -> SCNVector3? {
        let results = self.hitTest(screenPosition, types: [.featurePoint])
        guard let result = results.first else { return nil }
        return SCNVector3.positionFromTransform(result.worldTransform)
    }
}

