//
//  Line.swift
//  Caliper
//
//  Created by Bhanuprasad Gollapudi on 27/08/18.
//  Copyright © 2018 GGK. All rights reserved.
//

import Foundation
import ARKit

final class Line {
    fileprivate var color: UIColor = .white
    
    fileprivate var startNode: SCNNode!
    fileprivate var endNode: SCNNode!
    fileprivate var text: SCNText!
    fileprivate var textNode: SCNNode!
    fileprivate var lineNode: SCNNode?
    
    fileprivate let sceneView: ARSCNView!
    fileprivate let startVector: SCNVector3!
    
    //MARK: - Initialization -
    
    init(sceneView: ARSCNView, startVector: SCNVector3,  color: (start: UIColor, end: UIColor) = (UIColor.green, UIColor.red)) {
        self.sceneView = sceneView
        self.startVector = startVector
        
        func buildSCNSphere(color: UIColor) -> SCNSphere {
            let dot = SCNSphere(radius: 0.8)
            dot.firstMaterial?.diffuse.contents = color
            dot.firstMaterial?.lightingModel = .constant
            dot.firstMaterial?.isDoubleSided = true
            return dot
        }
        
        startNode = SCNNode(geometry: buildSCNSphere(color: color.start))
        startNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        startNode.position = startVector
        sceneView.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: buildSCNSphere(color: color.end))
        endNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = .systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = UIColor.brown
        text.alignmentMode  = kCAAlignmentCenter
        text.truncationMode = kCATruncationMiddle
        text.firstMaterial?.isDoubleSided = true
        
        
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}

//MARK: - CustomMethods -

extension Line {
    
    func distance(to vector: SCNVector3) -> String {
        let cm = startVector.distance(receiver: vector) * 100.0
        let inch = cm * 0.3937007874
        
        return String(format: "%.2f cm / %.2f\"", cm, inch)
    }
    
    func removeFromParentNode() {
        startNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
    }
    
    func update(to vector: SCNVector3) {
        lineNode?.removeFromParentNode()
        lineNode = lineBetweenstartVector(to: vector)
        sceneView.scene.rootNode.addChildNode(lineNode!)
        
        text.string = distance(to: vector)
        textNode.position = SCNVector3((startVector.x+vector.x)/2.0, (startVector.y+vector.y)/2.0, (startVector.z+vector.z)/2.0)
        
        endNode.position = vector
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
        }
    }
    
    private func lineBetweenstartVector(to currentVector: SCNVector3) -> SCNNode {
        
        return CylinderLine(parent: sceneView!.scene.rootNode,
                            v1: startVector,
                            v2: currentVector,
                            radius: 0.001,
                            radSegmentCount: 10,
                            color: UIColor.white)
        
    }
}
