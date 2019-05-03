import ARKit
import UIKit
import Foundation
import SceneKit

public class ARSCNNode: SCNNode {
    
    private var _arCursorTarget: String = "none" // Could be of anytype the user whant to, but has to be hashable
    private var _isListening: Bool = false
    
    public func setTarget(_ target: ARCursorTarget) {
        self._arCursorTarget = target
        self.addTargetListener()
    }
    
    public func getTarget() -> ARCursorTarget {
        return _arCursorTarget
    }

    public func isTargetListening() -> Bool {
        return self._isListening
    }

    public func addTargetListener() {
        self._isListening = true
        self.setPhysicsBody()
        self.physicsBody?.categoryBitMask = CollisionCategory.virtualNode.key
        self.physicsBody?.contactTestBitMask = CollisionCategory.cursor.key
    }
    
    public func removeTargetListener() {
        self._isListening = false
        self.setPhysicsBody()
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
    }

    private func setPhysicsBody() {
        self.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        self.physicsBody?.isAffectedByGravity = false
    }

    internal func setCursor() {
        self._arCursorTarget = "cursor" // UselessAnyway since it won't interact with itself, maybe with other curors?
        self.setPhysicsBody()
        self.physicsBody?.categoryBitMask = CollisionCategory.cursor.key
        self.physicsBody?.collisionBitMask = CollisionCategory.virtualNode.key
    }
}
