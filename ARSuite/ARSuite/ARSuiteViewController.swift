import ARKit
import UIKit
import Foundation
import SceneKit

open class ARSuiteViewController: UIViewController {

    public var sceneView: ARSCNView!
    public var arCursor: ARCursorView!

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
        arCursor = ARCursorView(parentView: sceneView)
        cursorNode = createCursor()
        sceneView.scene.rootNode.addChildNode(cursorNode)
        arCursor.show()
    }
}

// Member functions
extension ARSuiteViewController {

    private func createCursor() -> SCNNode {
        let cursorNode = SCNNode()
        cursorNode.name = "cursor"
        let cursor = SCNBox(width: 0.001,
                            height: 0.001,
                            length: 5,
                            chamferRadius: 0)
        cursor.firstMaterial?.diffuse.contents = UIColor.clear
        cursorNode.geometry = cursor

        // Physics Body for collision
        cursorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        cursorNode.physicsBody?.isAffectedByGravity = false
        cursorNode.physicsBody?.categoryBitMask = CollisionCategory.cursor.key
        cursorNode.physicsBody?.collisionBitMask = CollisionCategory.virtualNode.key
        return cursorNode
    }

    public func convertNodeToTarget(node: SCNNode) {
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = CollisionCategory.virtualNode.key
        node.physicsBody?.contactTestBitMask = CollisionCategory.cursor.key
    }
}

extension ARSuiteViewController: ARSessionDelegate {

    open func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let cameraTrans = frame.camera.transform
        cursorNode.setWorldTransform(SCNMatrix4(cameraTrans))
    }
}

extension ARSuiteViewController: SCNPhysicsContactDelegate {

    open func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        shouldUpdate = !isOnTarget ? true : false
        isOnTarget = true
        updateCursor()
    }

    open func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        shouldUpdate = !isOnTarget ? true : false
        isOnTarget = true
        updateCursor()
    }

    open func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        shouldUpdate = isOnTarget ? true : false
        isOnTarget = false
        updateCursor()
    }

    private func updateCursor() {
        if shouldUpdate {
            if isOnTarget {
                DispatchQueue.main.async {
                    self.arCursor.swap()
                }
            } else {
                DispatchQueue.main.async {
                    self.arCursor.swap()
                }
            }
        }
    }
}
