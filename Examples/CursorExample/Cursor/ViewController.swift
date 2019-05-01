import UIKit
import SceneKit
import ARKit
import ARSuite

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

    func generateSphereNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0.05)
        sphere.firstMaterial?.diffuse.contents = UIColor.yellow
        let sphereNode = SCNNode()
        sphereNode.name = "sphere"
        sphereNode.position.y += Float(sphere.radius)
        sphereNode.geometry = sphere
        return sphereNode
    }
}

// MARK - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        let sphereNode = generateSphereNode()
        convertNodeToTarget(node: sphereNode)
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
