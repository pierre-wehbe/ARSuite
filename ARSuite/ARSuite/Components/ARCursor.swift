import ARKit
import UIKit
import Foundation
import SceneKit


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

protocol ARCursorProtocol {
    var parentView: UIView { get set }
    
    var onTargetView: ARCursorTargetView! { get set }
    var offTargetView: ARCursorTargetView! { get set }
    
    var onTargetColor: UIColor { get }
    var offTargetColor: UIColor { get }
    
    var state: ARCursorState { get }
    
    func get() -> ARCursorTargetView
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
}

public struct ARCursorView: ARCursorProtocol {
    
    private let ON_TARGET_SIZE = CGSize(width: CGFloat(2).toPoint(unit: .mm),
                                        height: CGFloat(2).toPoint(unit: .mm))
    private let OFF_TARGET_SIZE = CGSize(width: CGFloat(1).toPoint(unit: .mm),
                                         height: CGFloat(1).toPoint(unit: .mm))
    
    var parentView: UIView
    
    var onTargetView: ARCursorTargetView! = nil
    var offTargetView: ARCursorTargetView! = nil
    
    var state: ARCursorState = .off
    
    init(parentView: UIView, onTargetView: UIView? = nil, offTargetView: UIView? = nil) {
        self.parentView = parentView
        
        setTargetView(.on, withView: onTargetView)
        setTargetView(.off, withView: offTargetView)
    }
    
    func get() -> ARCursorTargetView {
        return state == .on ? onTargetView : offTargetView
    }
    
    func getSize() -> CGSize {
        guard let view = state == .on ? onTargetView : offTargetView else {
            return state == .on ? ON_TARGET_SIZE : OFF_TARGET_SIZE
        }
        return view.frame.size
    }
    
    func show() {
        let target = get()
        if target.superview == nil {
            self.parentView.addSubview(target)
        }
    }
    
    func hide() -> Bool { // returns (true if was shown, false if was hidden)
        let target = get()
        if target.superview != nil {
            target.removeFromSuperview()
            return true
        }
        return false
    }
    
    public mutating func swap() {
        let wasDisplayed = hide() // current view
        state = state == .on ? .off : .on
        wasDisplayed ? show() : ()
    }
    
    public mutating func setTargetView(_ type: ARCursorState, withView: UIView?) {
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
}
