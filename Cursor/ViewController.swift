import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!

    var cursorNode: SCNNode!
    var lastTimerInterval = TimeInterval()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // Add Tap Gesture
        addTapGestureToSceneView()
        
        // Collision Delegate
        sceneView.scene.physicsWorld.contactDelegate = self
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// Collision Delegate
extension ViewController: SCNPhysicsContactDelegate {
    
    struct CollisionCategory {
        let key: Int
        static let cursor = CollisionCategory.init(key: 1 << 0)
        static let virtualNode = CollisionCategory.init(key: 1 << 1)
    }

    func convertNodeToTarget(node: SCNNode) {
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = CollisionCategory.virtualNode.key
        node.physicsBody?.contactTestBitMask = CollisionCategory.cursor.key
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        print("Hit between \(nodeA.name) & \(nodeB.name)")
    }
}

// Adding anchors
extension ViewController {
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didReceiveTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        guard let hitTestResult = sceneView.hitTest(location, types: [.featurePoint, .estimatedHorizontalPlane]).first
            else { return }
        let anchor = ARAnchor(transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
    }
    
    func generateSphereNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0.05)
        sphere.firstMaterial?.diffuse.contents = UIColor.yellow
        let sphereNode = SCNNode()
        sphereNode.name = "sphere"
        sphereNode.position.y += Float(sphere.radius)
        sphereNode.geometry = sphere
        return sphereNode
    }
    
    // ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        let sphereNode = generateSphereNode()
        convertNodeToTarget(node: sphereNode)
        DispatchQueue.main.async {
            node.addChildNode(sphereNode)
        }
    }
}

// Cursor Specific
extension ViewController {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let cameraTrans = frame.camera.transform
        var toModify = SCNMatrix4(cameraTrans)
        let distance: Float = 1.0
        toModify.m41 -= toModify.m31*distance
        toModify.m42 -= toModify.m32*distance
        toModify.m43 -= toModify.m33*distance
        
        cursorNode.setWorldTransform(toModify)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = time - lastTimerInterval
        if deltaTime > 0.25 {
        }
    }
    
    func createCursor() -> SCNNode {
        let cursorNode = SCNNode()
        cursorNode.name = "cursor"
        let cursor = SCNBox(width: 0.01, height: 0.01, length: 1, chamferRadius: 0.01)
        
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.red
        redMaterial.locksAmbientWithDiffuse = true;
        
        cursor.materials =  [redMaterial];
        cursorNode.geometry = cursor
        
        // Physics Body for collision
        cursorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        cursorNode.physicsBody?.isAffectedByGravity = false
        cursorNode.physicsBody?.categoryBitMask = CollisionCategory.cursor.key
        cursorNode.physicsBody?.collisionBitMask = CollisionCategory.virtualNode.key

        return cursorNode
    }
}
