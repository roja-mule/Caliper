//
//  ViewController.swift
//  GGKPlanDetection
//
//  Created by Bhanuprasad Gollapudi on 21/08/18.
//  Copyright © 2018 Bhanuprasad Gollapudi. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var startCameraButton: UIButton!
    @IBOutlet weak var aimLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    let sessionConfig = ARWorldTrackingConfiguration()
    var location: CGPoint? = nil
    
    let session = ARSession()
    let vectorZero = SCNVector3()
    var measuring = false
    var startValue = SCNVector3()
    var endValue = SCNVector3()
    private var line: LineNode?
    
    
    struct Image {
        struct Indicator {
            static let enable = #imageLiteral(resourceName: "img_indicator_enable")
            static let disable = #imageLiteral(resourceName: "img_indicator_disable")
        }
    }
    
    //MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
    
    
    //MARK: -  ViewActionMethods
    
    @IBAction func startButtonAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    
    func setupScene() {
        sceneView.delegate = self
        sceneView.session = session
        
        session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
        
        resetValues()
    }
    
    func resetValues() {
        measuring = false
        startValue = SCNVector3()
        endValue =  SCNVector3()
        
        updateResultLabel(0.0)
    }
    
    func updateResultLabel(_ value: Float) {
        let cm = value * 100.0
        let inch = cm*0.3937007874
        statusLabel.text = String(format: "%.2f cm / %.2f\"", cm, inch)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.detectObjects()
        }
    }
    
    func detectObjects() {
        if let location_ = location {
            if let worldPos = sceneView.realWorldVector(screenPos: location_) {
                if measuring {
                    if startValue == vectorZero {
                        startValue = worldPos
                    }
                    endValue = worldPos
                    updateResultLabel(startValue.distance(from: endValue))
                    debugPrint(line)
                    //   let length = line?.updatePosition(pos: worldPos, camera: self.sceneView.session.currentFrame?.camera)
                    // debugPrint(length)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetValues()
        measuring = true
        let touch: UITouch = touches.first!
        location = touch.location(in: self.view)
        
        if let startPos = sceneView.realWorldVector(screenPos: location!) {
            line = LineNode(startPos: startPos, sceneV: sceneView)
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        measuring = false
        line  = nil
    }
}
