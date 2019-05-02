import ARKit
import UIKit
import Foundation
import SceneKit

open class ARSuiteViewController: UIViewController {

    public var sceneView: ARSCNView!
    public var arCursor: ARCursor!

    internal var isOnTarget = false
    internal var shouldUpdate = true

    internal var cursorNode: SCNNode!

    override open func viewDidLoad() {
        super.viewDidLoad()
        sceneView = ARSCNView(frame: UIScreen.main.bounds)

        let scene = SCNScene()
    
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session.delegate = self

        // Collision Delegate
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.physicsWorld.timeStep = 1/300

        self.view.addSubview(sceneView)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Cursor View
        arCursor = ARCursor(parentView: sceneView)
        sceneView.scene.rootNode.addChildNode(arCursor.node)
        arCursor.show()
    }
}

extension ARSuiteViewController: ARSessionDelegate {

    open func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let cameraTrans = frame.camera.transform
        arCursor.node.setWorldTransform(SCNMatrix4(cameraTrans))
    }
}

extension ARSuiteViewController: SCNPhysicsContactDelegate {

    open func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        shouldUpdate = !isOnTarget ? true : false
        isOnTarget = true
        updateCursorHelper(contact.nodeB)
    }

    open func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        shouldUpdate = !isOnTarget ? true : false
        isOnTarget = true
        updateCursorHelper(contact.nodeB)
    }

    open func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        shouldUpdate = isOnTarget ? true : false
        isOnTarget = false
        updateCursorHelper(contact.nodeB)
    }

    private func updateCursorHelper(_ node: SCNNode) {
        guard let node = node as? ARSCNNode else {
            return
        }
        updateCursor(node)
    }

    private func updateCursor(_ node: ARSCNNode) {
        if shouldUpdate {
            if isOnTarget {
                DispatchQueue.main.async {
                    self.arCursor.swap(node)
                }
            } else {
                DispatchQueue.main.async {
                    self.arCursor.swap(node)
                }
            }
        }
    }
}
