import Foundation
import SceneKit

public protocol ARCursorDelegate: class {

    func arCursor(_ cursor: ARCursor, oldTarget: ARCursorTarget, newTarget: ARCursorTarget, didTouch node: SCNNode)
    func arCursor(_ cursor: ARCursor, oldTarget: ARCursorTarget, didEndTouch node: SCNNode)
    func arCursor(_ cursor: ARCursor) -> [ARCursorTarget] // TODO: Implement, or have a target variables that I would access via the delegate?
}
