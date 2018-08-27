//
//  SCNVector+Extension.swift
//  Caliper
//
//  Created by Bhanuprasad Gollapudi on 27/08/18.
//  Copyright © 2018 GGK. All rights reserved.
//

import Foundation
import ARKit

extension SCNVector3 {
    func distance(receiver:SCNVector3) -> Float{
        let xDistance = receiver.x - self.x
        let yDistance = receiver.y - self.y
        let zDistance = receiver.z - self.z
        let distance = sqrtf(xDistance * xDistance + yDistance * yDistance + zDistance * zDistance)
        
        return distance
    }
    
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}

extension SCNVector3: Equatable {
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}
