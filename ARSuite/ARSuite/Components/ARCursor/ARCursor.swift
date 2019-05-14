import ARKit
import Foundation
import SceneKit
import UIKit

//TODO (Pierre): For now we only support 1 cursor, extend to 2 cursors in the same scene
struct CollisionCategory {
    let key: Int
    static let cursor = CollisionCategory.init(key: 1 << 0)
    static let virtualNode = CollisionCategory.init(key: 1 << 1)
}

public enum ARCursorState {
    case on
    case off
}

public typealias ARCursorTargetView = UIView
public typealias ARCursorTarget = String // Want it to be generic

public class ARCursor: ARCursorProtocol {

    private let ON_TARGET_SIZE = CGSize(width: CGFloat(2).toPoint(unit: .mm),
                                        height: CGFloat(2).toPoint(unit: .mm))
    private let OFF_TARGET_SIZE = CGSize(width: CGFloat(1).toPoint(unit: .mm),
                                         height: CGFloat(1).toPoint(unit: .mm))
    
    private var _currentTarget: ARCursorTarget = "none"
    
    internal var parentView: UIView
    
    internal var onTargetView: ARCursorTargetView! = nil
    internal var offTargetView: ARCursorTargetView! = nil

    private var target: ARCursorTarget {
        return _currentTarget
    }
    internal var targets: Set<ARCursorTarget> = []

    internal var state: ARCursorState = .off

    public var node = ARSCNNode()
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

    private func createCursor() {
        node.setCursor()
        let cursor = SCNBox(width: 0.001,
                            height: 0.001,
                            length: 5,
                            chamferRadius: 0)
        cursor.firstMaterial?.diffuse.contents = UIColor.clear
        node.geometry = cursor
    }

    internal func get() -> ARCursorTargetView {
        return state == .on ? onTargetView : offTargetView
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

    public func getSize() -> CGSize {
        guard let view = state == .on ? onTargetView : offTargetView else {
            return state == .on ? ON_TARGET_SIZE : OFF_TARGET_SIZE
        }
        return view.frame.size
    }

    //TODO: Test hide, show and check that no events are being fired
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
            wasDisplayed ? self.delegate?.arCursor(self, oldTarget: oldTarget, didEndTouch: newNode) : ()
            state = .off
        } else {
            wasDisplayed ? self.delegate?.arCursor(self, oldTarget: oldTarget, newTarget: _currentTarget, didTouch: newNode) : ()
            state = .on
        }
        wasDisplayed ? show() : ()
    }
    
    public func register(targets: [ARCursorTarget]) -> Bool {
        var inserted = true
        targets.forEach { (target) in
            inserted = inserted && self.targets.insert(target).inserted
        }
        return inserted
    }
    
    public func unregister(targets: [ARCursorTarget]) -> Bool {
        var removed = true
        targets.forEach { (target) in
            removed = removed && (self.targets.remove(target) != nil)
        }
        return removed
    }

    public func setTargetView(_ type: ARCursorState, withView: UIView?) {
        switch type {
        case .on:
            self.onTargetView = withView ?? getDefaultTargetView(.on)
        case .off:
            self.offTargetView = withView ?? getDefaultTargetView(.off)
        }
    }
}
