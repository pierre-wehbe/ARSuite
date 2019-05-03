import Foundation
import SceneKit

public protocol ARCursorDelegate: class {
    
    var targets: [ARCursorTarget] { get set }
    
    func arCursor(_ cursor: ARCursor, oldTarget: ARCursorTarget, newTarget: ARCursorTarget, didTouch node: SCNNode)
    func arCursor(_ cursor: ARCursor, oldTarget: ARCursorTarget, didEndTouch node: SCNNode)
}
