import UIKit
import SceneKit
import ARKit
import ARSuite

//TODO: add target highlight on crossing
//TODO: implement selection
//didhighlight
//did select ...
class ViewController: ARSuiteViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize Delegates
        sceneView.session.delegate = self
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self

        // Add Tap Gesture To Add Nodes
        addTapGestureToSceneView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Initialize Cursor Delegate
        arCursor.delegate = self

        //TODO I want to call this
        arCursor.register(targets: <#T##[ARCursorTarget]#>) //duplicates with set target, register and addlisteners, need to edfined
    }

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

    func generateSphereNode() -> ARSCNNode { // Need to be registered, what if I want multiple cursors to register to it
        let sphere = SCNSphere(radius: 0.05)
        sphere.firstMaterial?.diffuse.contents = UIColor.yellow
        let sphereNode = ARSCNNode()
        sphereNode.setTarget("sphere")
        sphereNode.addTarget(" )
        
        let b = UIButton()
        b.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        arCursor.register(targets: [sphereNode])
        

        sphereNode.position.y += Float(sphere.radius)
        sphereNode.geometry = sphere
        return sphereNode
    }
}

// MARK - ARCursorDelegate
extension ViewController: ARCursorDelegate {
    func arCursor(_ cursor: ARCursor, oldTarget: ARCursorTarget, newTarget: ARCursorTarget, didTouch node: SCNNode) {
        print("Did Touch: \(oldTarget) - \(newTarget)")
    }
    
    func arCursor(_ cursor: ARCursor, oldTarget: ARCursorTarget, newTarget: ARCursorTarget, didEndTouch node: SCNNode) {
        print("Did End Touch: \(oldTarget) - \(newTarget)")
    }
}

// MARK - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }

        let sphereNode = generateSphereNode()
        arCursor.register(targets: <#T##[ARCursorTarget]#>)
        // Wnat to register the node, if I register the node, then I only want this node supposedy, so its target will be neglibible?
        // or register the target name
        sphereNode.addTargetListener()
        DispatchQueue.main.async {
            node.addChildNode(sphereNode)
        }
    }
}

// MARK - ARSessionDelegate
extension ViewController {
    override func session(_ session: ARSession, didUpdate frame: ARFrame) {
        super.session(session, didUpdate: frame)
    }
}

// MARK - SCNPhysicsContactDelegate
extension ViewController {
    override func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        super.physicsWorld(world, didBegin: contact)
    }

    override func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        super.physicsWorld(world, didUpdate: contact)
    }

    override func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        super.physicsWorld(world, didEnd: contact)
    }
}
