import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var startAndEndButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var aimView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    fileprivate let sessionConfig = ARWorldTrackingConfiguration()
    fileprivate var location: CGPoint? = nil
    
    fileprivate let session = ARSession()
    fileprivate let vectorZero = SCNVector3()
    fileprivate var startValue = SCNVector3()
    fileprivate var endValue = SCNVector3()
    fileprivate var currentLine: Line?
    fileprivate var isMeasuring = false{
        didSet{
            startAndEndButton.isSelected = isMeasuring
        }
    }
    
    //MARK: - ViewLifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        _ = DataManager.shared.getData()
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
    
    @IBAction func startAndStopTapped(_ sender : UIButton){
        if isMeasuring{
            currentLine?.lineNode?.name = currentLine?.distance(to: endValue)
            isMeasuring = false
        }else{
            resetValues()
            isMeasuring = true
            //  currentLine?.removeFromParentNode()
            if let startPos = sceneView.realWorldVector(screenPosition: view.center) {
                currentLine = Line(sceneView: sceneView, startVector: startPos)
            }
        }
    }
    
    @IBAction func clearTapped(_ sender : UIButton){
        //To clear only one node
        isMeasuring = false
        currentLine?.removeFromParentNode()
        currentLine  = nil
        
        //To clear all Nodes
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode() }
        
    }
    
    func addPanGestureToStartAndStopButton(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView))
        startAndEndButton.isUserInteractionEnabled = true
        startAndEndButton.addGestureRecognizer(panGesture)
    }
    
    func addTapGestureToScene(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sceneViewTapped))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func sceneViewTapped(_ sender : UITapGestureRecognizer){
        let location: CGPoint = sender.location(in: self.view)
        let hits = sceneView.hitTest(location, options: nil)
        if let textNode = hits.first?.node.geometry as? SCNText,let text = textNode.string as? String {
            showSaveAlert(with: text)
        }
    }
    
    func showSaveAlert(with measurement : String){
        let alertController = UIAlertController(title: "Save Measurement", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Name"
        }
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
            guard let textField = alertController.textFields?[0] else{return}
            DataManager.shared.insert(name: textField.text ?? "", valueIncm: measurement)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (action : UIAlertAction!) -> Void in })
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubview(toFront: startAndEndButton)
        let translation = sender.translation(in: self.view)
        startAndEndButton.center = CGPoint(x: startAndEndButton.center.x + translation.x, y: startAndEndButton.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
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
        addPanGestureToStartAndStopButton()
        
        addTapGestureToScene()
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
