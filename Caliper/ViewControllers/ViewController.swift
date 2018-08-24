import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var startCameraButton: UIButton!
    @IBOutlet weak var aimLabel: UILabel!
    
    fileprivate let sessionConfig = ARWorldTrackingConfiguration()
    fileprivate var location: CGPoint? = nil
    
    fileprivate let session = ARSession()
    fileprivate let vectorZero = SCNVector3()
    fileprivate var measuring = false
    fileprivate var startValue = SCNVector3()
    fileprivate var endValue = SCNVector3()
    fileprivate var line: LineNode?
    
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
    
    
    //MARK: -  Action Methods
    @IBAction func startTapped(_ sender: UIButton){
        resetValues()
        measuring = true
        if let startPos = sceneView.realWorldVector(screenPos: view.center) {
            line = LineNode(startPos: startPos, sceneV: sceneView)
        }
    }
    
    @IBAction func endTapped(_ sender: UIButton){
        measuring = false
    }
    
    @IBAction func clearTapped(_ sender : UIButton){
        measuring = false
        line  = nil
    }
    
    //MARK: - Custom Methods
    private func setupScene() {
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

}

extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.detectObjects()
        }
    }
    
    func detectObjects() {
        if let worldPos = sceneView.realWorldVector(screenPos: view.center) {
            if measuring {
                if startValue == vectorZero {
                    startValue = worldPos
                }
                endValue = worldPos
                updateResultLabel(startValue.distance(from: endValue))
                debugPrint(line ?? "")
                let length = line?.updatePosition(pos: worldPos, camera: self.sceneView.session.currentFrame?.camera)
                debugPrint(length ?? 0.0)
            }
        }
    }
}
