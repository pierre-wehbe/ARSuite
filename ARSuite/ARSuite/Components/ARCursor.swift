import ARKit
import UIKit
import Foundation
import SceneKit


public class ARSCNNode: SCNNode {
    
    private var _arCursorTarget: String = "none" // Could be of anytype the user whant to, but has to be hashable
    
    public func setTarget(_ target: ARCursorTarget) {
        self._arCursorTarget = target
    }

    public func getTarget() -> ARCursorTarget {
        return _arCursorTarget
    }

    public func addTargetListener() {
        self.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionCategory.virtualNode.key
        self.physicsBody?.contactTestBitMask = CollisionCategory.cursor.key
    }

    public func removeTargetListener() {
        self.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
    }
}

struct CollisionCategory {
    let key: Int
    static let cursor = CollisionCategory.init(key: 1 << 0)
    static let virtualNode = CollisionCategory.init(key: 1 << 1)
}

public enum ARCursorState {
    case on
    case off
}

typealias ARCursorTargetView = UIView
public typealias ARCursorTarget = String

protocol ARCursorTargetProtocol: Hashable {
    var uid: String { get set }
}

protocol ARCursorProtocol {
    var parentView: UIView { get set }
    
    var onTargetView: ARCursorTargetView! { get set }
    var offTargetView: ARCursorTargetView! { get set }
    
    var onTargetColor: UIColor { get }
    var offTargetColor: UIColor { get }
    
    var state: ARCursorState { get }
    var targets: Set<ARCursorTarget> { get set }
    
    // Functions
    func get() -> ARCursorTargetView

    mutating func register(target: ARCursorTarget) -> Bool
    mutating func register(targets: [ARCursorTarget]) -> Bool

    mutating func unregister(target: ARCursorTarget) -> Bool
    mutating func unregister(targets: [ARCursorTarget]) -> Bool
}

// Providing default values
extension ARCursorProtocol {
    var onTargetColor: UIColor {
        return .red
    }
    
    var offTargetColor: UIColor {
        return .red
    }
    
    var state: ARCursorState {
        return .off
    }

    mutating func register(target: ARCursorTarget) -> Bool {
        return register(targets: [target])
    }

    mutating func unregister(target: ARCursorTarget) -> Bool {
        return unregister(targets: [target])
    }
}

public protocol ARCursorDelegate: class {

    func arCursor(_ cursor: ARCursor, oldTarget: ARCursorTarget, newTarget: ARCursorTarget, didTouch node: SCNNode)
    func arCursor(_ cursor: ARCursor, oldTarget: ARCursorTarget, newTarget: ARCursorTarget, didEndTouch node: SCNNode)
}

public class ARCursor: ARCursorProtocol {

    private let ON_TARGET_SIZE = CGSize(width: CGFloat(2).toPoint(unit: .mm),
                                        height: CGFloat(2).toPoint(unit: .mm))
    private let OFF_TARGET_SIZE = CGSize(width: CGFloat(1).toPoint(unit: .mm),
                                         height: CGFloat(1).toPoint(unit: .mm))
    
    var parentView: UIView
    
    var onTargetView: ARCursorTargetView! = nil
    var offTargetView: ARCursorTargetView! = nil
    
    var state: ARCursorState = .off
    
    var node = ARSCNNode()

    private var _currentTarget: ARCursorTarget = "none"
    var target: ARCursorTarget {
        return _currentTarget
    }
    var targets: Set<ARCursorTarget> = []

    public weak var delegate: ARCursorDelegate? = nil

    init(parentView: UIView,
         onTargetView: UIView? = nil,
         offTargetView: UIView? = nil,
         targets: [ARCursorTarget]? = nil,
         delegate: ARCursorDelegate? = nil) {
        self.parentView = parentView

        _ = register(targets: targets ?? [])
        setTargetView(.on, withView: onTargetView)
        setTargetView(.off, withView: offTargetView)

        createCursor()
    }

    func get() -> ARCursorTargetView {
        return state == .on ? onTargetView : offTargetView
    }

    func register(targets: [ARCursorTarget]) -> Bool {
        var inserted = true
        targets.forEach { (target) in
            inserted = inserted && self.targets.insert(target).inserted
        }
        return inserted
    }

     func unregister(targets: [ARCursorTarget]) -> Bool {
        var removed = true
        targets.forEach { (target) in
            removed = removed && (self.targets.remove(target) != nil)
        }
        return removed
    }

    public func getSize() -> CGSize {
        guard let view = state == .on ? onTargetView : offTargetView else {
            return state == .on ? ON_TARGET_SIZE : OFF_TARGET_SIZE
        }
        return view.frame.size
    }

    public func show() {
        let target = get()
        if target.superview == nil {
            self.parentView.addSubview(target)
        }
    }

    public func hide() -> Bool { // returns (true if was shown, false if was hidden)
        let target = get()
        if target.superview != nil {
            target.removeFromSuperview()
            return true
        }
        return false
    }

    public func swap(_ newNode: ARSCNNode) {
        let wasDisplayed = hide() // current view
        let oldTarget = _currentTarget
        _currentTarget = state == .on ? "none" : newNode.getTarget()
        if state == .on {
            wasDisplayed ? self.delegate?.arCursor(self, oldTarget: oldTarget, newTarget: _currentTarget, didEndTouch: newNode) : ()
            state = .off
        } else {
            wasDisplayed ? self.delegate?.arCursor(self, oldTarget: oldTarget, newTarget: _currentTarget, didTouch: newNode) : ()
            state = .on
        }
        wasDisplayed ? show() : ()
    }

    public func setTargetView(_ type: ARCursorState, withView: UIView?) {
        switch type {
        case .on:
            self.onTargetView = withView ?? getDefaultTargetView(.on)
        case .off:
            self.offTargetView = withView ?? getDefaultTargetView(.off)
        }
    }

    private func getDefaultTargetView(_ type: ARCursorState) -> ARCursorTargetView {
        let frame = CGRect(origin: CGPoint.zero,
                           size: type == .on ? ON_TARGET_SIZE : OFF_TARGET_SIZE)
        let view = UIView(frame: frame)
        view.center = parentView.center
        view.layer.masksToBounds = true
        view.layer.cornerRadius = (type == .on ? ON_TARGET_SIZE : OFF_TARGET_SIZE).width / 2.0
        view.backgroundColor = type == .on ? .clear : offTargetColor
        
        if type == .on {
            view.layer.borderColor = onTargetColor.cgColor
            view.layer.borderWidth = CGFloat(0.5).toPoint(unit: .mm)
        }
        
        return view
    }

    private func createCursor() {
        node.setTarget("cursor")
        let cursor = SCNBox(width: 0.001,
                            height: 0.001,
                            length: 5,
                            chamferRadius: 0)
        cursor.firstMaterial?.diffuse.contents = UIColor.clear
        node.geometry = cursor
        
        // Physics Body for collision
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = CollisionCategory.cursor.key
        node.physicsBody?.collisionBitMask = CollisionCategory.virtualNode.key
    }
}
