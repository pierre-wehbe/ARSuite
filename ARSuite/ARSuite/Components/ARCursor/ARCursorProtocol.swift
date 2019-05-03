import Foundation

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
    
    func register(target: ARCursorTarget) -> Bool
    func register(targets: [ARCursorTarget]) -> Bool
    
    func unregister(target: ARCursorTarget) -> Bool
    func unregister(targets: [ARCursorTarget]) -> Bool
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
    
    public func register(target: ARCursorTarget) -> Bool {
        return register(targets: [target])
    }
    
    public func unregister(target: ARCursorTarget) -> Bool {
        return unregister(targets: [target])
    }
}
