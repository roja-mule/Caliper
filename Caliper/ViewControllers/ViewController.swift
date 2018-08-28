import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var aimLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    fileprivate let sessionConfig = ARWorldTrackingConfiguration()
    fileprivate var location: CGPoint? = nil
    
    fileprivate let session = ARSession()
    fileprivate let vectorZero = SCNVector3()
    fileprivate var isMeasuring = false
    fileprivate var startValue = SCNVector3()
    fileprivate var endValue = SCNVector3()
    fileprivate var currentLine: Line?
    
    //MARK: - ViewLifeCycle -
    
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
        isMeasuring = true
        
      //  currentLine?.removeFromParentNode()
        
        if let startPos = sceneView.realWorldVector(screenPosition: view.center) {
            currentLine = Line(sceneView: sceneView, startVector: startPos)
        }
    }
    
    @IBAction func endTapped(_ sender: UIButton){
        isMeasuring = false
    }
    
    @IBAction func clearTapped(_ sender : UIButton){
        isMeasuring = false
        currentLine?.removeFromParentNode()
        currentLine  = nil
    }
}
extension ViewController {
    
    //MARK: - Custom Methods
    
    private func setupScene() {
        sceneView.delegate = self
        indicator.startAnimating()
        sceneView.session = session
        session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
        
        resetValues()
    }
    
    func resetValues() {
        isMeasuring = false
        startValue = SCNVector3()
        endValue =  SCNVector3()
        updateResultLabel(0.0)
    }
    
    func updateResultLabel(_ value: Float) {
        let cm = value * 100.0
        let inch = cm*0.3937007874
        statusLabel.text = String(format: "%.2f cm / %.2f\"", cm, inch)
    }
    
    fileprivate func detectObjects() {
        guard let worldPosition = sceneView.realWorldVector(screenPosition: view.center) else { return }
        
        indicator.stopAnimating()
        
        if isMeasuring {
            if startValue == vectorZero {
                startValue = worldPosition
            }
            endValue = worldPosition
            currentLine?.update(to: endValue)
            statusLabel.text = currentLine?.distance(to: endValue) ?? "Calculating…"
        }
    }
}

//MARK:- ARSCNViewDelegate Methods -

extension ViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.detectObjects()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        statusLabel.text = "Error occurred"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        statusLabel.text = "Interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        statusLabel.text = "Interruption ended"
    }
}
