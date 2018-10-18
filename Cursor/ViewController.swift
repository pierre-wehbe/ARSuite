import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var cameraTransform: UILabel!
    
    @IBOutlet weak var cursorTransformLabel: UILabel!
    var cursorNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraTransform.isHidden = true
        cursorTransformLabel.isHidden = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()

        cursorNode = createCursor()
        scene.rootNode.addChildNode(cursorNode)

        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func conv(_ n: Float) -> String {
        return String(format: "%.02f", n)
    }

    var lastTimerInterval = TimeInterval()
    func session(_ session: ARSession, didFailWithError error: Error) {

    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

//Cursor Specific
extension ViewController {
    
    func getUserVector() -> (SCNQuaternion, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNQuaternion(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33, 1 * mat.m34) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNQuaternion(0, 0, -1, 1), SCNVector3(0, 0, -0.2))
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
            let cameraTrans = frame.camera.transform
            var toModify = SCNMatrix4(cameraTrans)
        let distance: Float = 1.0
            toModify.m41 -= toModify.m31*distance
            toModify.m42 -= toModify.m32*distance
            toModify.m43 -= toModify.m33*distance
            
            cursorNode.setWorldTransform(toModify)
        
//        let (pos, rotation, scale, euler) = cursorNode.worldTransform
//        var result = ""
//        result += "Pos: x: \(conv(pos.x))\ny: \(conv(pos.y))\nz: \(conv(pos.z))\n\n"
//
//        result += "Rotation: x: \(conv(rotation.x))\ny: \(conv(rotation.y))\nz: \(conv(rotation.z))\n\n"
//
//        result += "Direction: x: \(conv(scale.x))\ny: \(conv(scale.y))\nz: \(conv(scale.z))\n\n"
//
//        result += "Position: x: \(conv(euler.x))\ny: \(conv(euler.y))\nz: \(conv(euler.z))"
    }

    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        let deltaTime = time - lastTimerInterval
        if deltaTime > 0.25 {
            
        }
        
        let currentFrame = sceneView.session.currentFrame;
        if let cameraTrans = currentFrame?.camera.transform {
            var result = ""
            let (pos, rotation, scale, euler) = cameraTrans.columns
            //cursorNode.position = SCNVector3(x: euler.x, y: euler.y, z: euler.z + 1)
                        result += "Pos: x: \(conv(pos.x))\ny: \(conv(pos.y))\nz: \(conv(pos.z))\n\n"
            
                        result += "Rotation: x: \(conv(rotation.x))\ny: \(conv(rotation.y))\nz: \(conv(rotation.z))\n\n"
            
                        result += "Direction: x: \(conv(scale.x))\ny: \(conv(scale.y))\nz: \(conv(scale.z))\n\n"
            
            result += "Position: x: \(conv(euler.x))\ny: \(conv(euler.y))\nz: \(conv(euler.z))"
            
            DispatchQueue.main.async {
                self.cameraTransform.text = result
            }
        } else {
            DispatchQueue.main.async {
                self.cameraTransform.text = ""
            }
        }
    }
    
    func createCursor() -> SCNNode {
        var cursorNode = SCNNode()
        cursorNode.name = "cursor"
//        let cursor = SCNTube(innerRadius: 0.01, outerRadius: 0.05, height: 0.5)
        let cursor = SCNBox(width: 0.01, height: 0.01, length: 1, chamferRadius: 0.01)
        
        let greenMaterial = SCNMaterial()
        greenMaterial.diffuse.contents = UIColor.red
        greenMaterial.locksAmbientWithDiffuse = true;
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.green
        redMaterial.locksAmbientWithDiffuse = true;
        
        
        let blueMaterial  = SCNMaterial()
        blueMaterial.diffuse.contents = UIColor.blue
        blueMaterial.locksAmbientWithDiffuse = true;
        
        
        let yellowMaterial = SCNMaterial()
        yellowMaterial.diffuse.contents = UIColor.black
        yellowMaterial.locksAmbientWithDiffuse = true;
        
        
        let purpleMaterial = SCNMaterial()
        purpleMaterial.diffuse.contents = UIColor.purple
        purpleMaterial.locksAmbientWithDiffuse = true;
        
        
        let WhiteMaterial = SCNMaterial()
        WhiteMaterial.diffuse.contents = UIColor.yellow
        WhiteMaterial.locksAmbientWithDiffuse   = true;
        
        
        cursor.materials =  [greenMaterial,  redMaterial,    blueMaterial,
                                  yellowMaterial, purpleMaterial, WhiteMaterial];
        
        cursorNode.geometry = cursor
        return cursorNode
    }
}
