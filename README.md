# ARSuite
[![Travis](https://img.shields.io/travis/Ramotion/folding-cell.svg)](https://travis-ci.org/Ramotion/folding-cell)
[![Swift 4.0](https://img.shields.io/badge/Swift-4.2-green.svg?style=flat)](https://developer.apple.com/swift/)

![intro image](https://github.com/pierre-wehbe/ARSuite/blob/master/Logo.png)

An ARViewController with embedded features. I am will be integrating further components along the way.
#### Current components:
- ARCursor

#### TODOs:
- ARMenu
- ARNodes
- ARScreenRecording
- ARScreenSharing


## Requirements
- iOS 12.0+
- Xcode 10.0+

## Installation

### CocoaPods
Add the following to your Podfile:
```swift
use_frameworks!
pod 'ARSuite', :git => 'https://github.com/pierre-wehbe/ImageZoomViewPW.git', :tag => '1.0.0'
```

### Build the framwork yourself
1. Open ARSuite.xcproject
2. Build
3. You will get "ARSuite.framework" under product
4. Go to your project and drag the the framework of **3** anywhere in the project
5. Go to Project -> General -> Linked Frameworks and Binaries, the framework should be present there
6. Select it and click on the "-" sign to remove it
7. Select "+" in the "Embedded Binaries" section and select the framework, it should now be present in both "Embedded Binarie" and "Linked Frameworks and Binaries"
8. You're done :)

## Quick Start

### 1. Setup

```swift
import ARSuite
```

#### Step 1 - Inherit from ARSuiteViewController
```swift
class ViewController: ARSuiteViewController {
  ...
}
```
This view controller has already an ARSCNView ```sceneView``` embedded that is by default clipped to the view's bounds.
Its frame can be modified using:
```swift
sceneView.frame = CGRect(...)
```

#### Step 2 - Initialize Delegate
```swift
override func viewDidLoad() {
  super.viewDidLoad()
  
    // Initialize Delegates
    sceneView.session.delegate = self
    sceneView.delegate = self
    sceneView.scene.physicsWorld.contactDelegate = self
}
```

#### Step 3 - Add Delegate Functions
```swift
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
```
These need to be declared ti call its ```super``` delegate methods necessary for proper functionning of the framework.

### 2. Components
| Table of Contents  |  Description       |
| ------------------ |:------------------:|
| ARCursor |  Cursor that enables you to interract with AR Objects present in the scene |

#### ARCursor
Currently ARCursor can interract with ```SCNNode``` objects
In order to make a node a target to the cursor, use the function ```convertNodeToTarget(node: SCNNode)```

Example:
```swift
// MARK - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        let sphereNode: SCNNode = generateSphereNode()
        convertNodeToTarget(node: sphereNode)
        DispatchQueue.main.async {
            node.addChildNode(sphereNode)
        }
    }
}
```

![Demo](https://thumbs.gfycat.com/MealyArtisticAltiplanochinchillamouse-size_restricted.gif)

### 3. Example Projects
To try out the different components, example projects have been created.
You can clone this repository and open the ```Examples``` subfolder.

* [ARCursor](https://github.com/pierre-wehbe/ios_swift_ar_cursor/tree/master/Examples/CursorExample)

## Contribute
Contributions are highly appreciated! To submit one:
1. Fork
2. Commit changes to a branch in your fork
3. Push your code and make a pull request

## Created By:
Pierre WEHBE

## License
[MIT](https://github.com/pierre-wehbe/ImageZoomViewPW/blob/master/LICENSE)
