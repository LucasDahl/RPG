//
//  GameScene.swift
//  test
//
//  Created by Lucas Dahl on 3/8/21.
//

import SpriteKit
import GameplayKit


enum Facing:Int {
    
    case Front, Back, Left, Right, None
    
}

enum MoveStates: Int {
    case n, s, e, w
}

// Powers of 2
enum BodyTpe: UInt32 {
    case player = 1
    case building = 2
    case npc = 4
}

// MARK: D-Pad hold to move

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode()
    var playerSpeed: CGFloat = 0
    var previousTimeInterval:TimeInterval = 0
    let buttonNorth = SKSpriteNode(imageNamed: "Directional_Button")
    let buttonSouth = SKSpriteNode(imageNamed: "Directional_Button")
    let buttonEast = SKSpriteNode(imageNamed: "Directional_Button2")
    let buttonWest = SKSpriteNode(imageNamed: "Directional_Button2")
    var facingImage = ""
    var moveAtEndOfRelease:Bool = true
    var isPressing = false
    var currentState = MoveStates.n
    var cameraNode = SKCameraNode()
    

    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        physicsWorld.contactDelegate = self
        
        // Make sure you can get teh player from the scene file
        if let somePlayer = self.childNode(withName: "player") as? SKSpriteNode {
            player = somePlayer
        
            // Set physics
            player.physicsBody?.isDynamic = true
            player.physicsBody?.affectedByGravity = false
            player.physicsBody?.categoryBitMask = BodyTpe.player.rawValue
            player.physicsBody?.collisionBitMask = BodyTpe.building.rawValue | BodyTpe.npc.rawValue
            player.physicsBody?.contactTestBitMask = BodyTpe.building.rawValue | BodyTpe.npc.rawValue

        } else {
            print("No player")
        }
        
        
        // Loop through the nodes
        for possibleBuilding in self.children {
            
            if(possibleBuilding.name == "building") {
                if(possibleBuilding is SKSpriteNode) {
                    possibleBuilding.physicsBody?.categoryBitMask = BodyTpe.building.rawValue
                    print("This is a building")
                }
            } else if(possibleBuilding.name == "npc") {
                if(possibleBuilding is SKSpriteNode) {
                    possibleBuilding.physicsBody?.categoryBitMask = BodyTpe.npc.rawValue
                    print("This is a npc")
                }
            }
        }
        
        // Set up the buttons
        let widthHalf:CGFloat = self.view!.bounds.width / 2
        let heightHalf:CGFloat = self.view!.bounds.height / 2
        
        cameraNode.addChild(buttonNorth)
        buttonNorth.position = CGPoint(x: -widthHalf + 80, y: -heightHalf + 100)
        buttonNorth.zPosition = 5
        
        cameraNode.addChild(buttonSouth)
        buttonSouth.position = CGPoint(x: -widthHalf + 80, y: -heightHalf + 40)
        buttonSouth.yScale = -1
        buttonSouth.zPosition = 5
        
        cameraNode.addChild(buttonWest)
        buttonWest.position = CGPoint( x: -widthHalf + 30, y: -heightHalf + 70)
        buttonWest.zPosition = 5
        
        cameraNode.addChild(buttonEast)
        buttonEast.position = CGPoint( x: -widthHalf + 130, y: -heightHalf + 70)
        buttonEast.zPosition = 5
        
        buttonNorth.xScale = 0.4
        buttonNorth.yScale = 0.4
        
        buttonSouth.xScale = 0.4
        buttonSouth.yScale = 0.4
        buttonSouth.zRotation = CGFloat(Double.pi)
        
        buttonEast.xScale = 0.4
        buttonEast.yScale = 0.4
        buttonEast.zRotation = CGFloat(Double.pi)
        
        buttonWest.xScale = 0.4
        buttonWest.yScale = 0.4
        
        addChild(cameraNode)
        camera = cameraNode
        
    }

    override func update(_ currentTime: TimeInterval) {

        cameraNode.position = player.position
        
        
        if (isPressing) {
            moveOnRelease()
        }
        
    }
    
    func moveSide(facing: Facing, x: CGFloat) {
        let walkAnimation = SKAction(named: "walk\(facing)")!
        let moveAction = SKAction.moveBy(x: x, y: 0, duration: 1)
        let group = SKAction.group([walkAnimation, moveAction])
        
        if (player.action(forKey: "moveSide") == nil) {
            player.removeAllActions()
            player.run(group, withKey: "moveSide")
        } else {
            player.run(moveAction)
        }
    }
    
    func moveUpDown(facing: Facing, y: CGFloat) {
        
        let walkAnimation = SKAction(named: "walk\(facing)")!
        let moveAction = SKAction.moveBy(x: 0, y: y, duration: 1)
        let group = SKAction.group([walkAnimation, moveAction])
        
        if (player.action(forKey: "moveUpDown") == nil) {
            player.removeAllActions()
            player.run(group, withKey: "moveUpDown")
        } else {
            player.run(moveAction)
        }
        
    }
    
    func moveOnRelease() {
        
        switch (currentState) {
            
        case .n:
            moveUpDown(facing: .Back, y: 10)
            facingImage = "backWalking2"
        case .s:
            moveUpDown(facing: .Front, y: -10)
            facingImage = "frontWalking2"
        case .e:
            moveSide(facing: .Right, x: 10)
            facingImage = "rightWalking2"
        case .w:
            moveSide(facing: .Left, x: -10)
            facingImage = "leftWalking2"
        
        }

    }
    
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in (touches ) {
            let location = touch.location(in: self.camera!)
            
            if (buttonNorth.frame.contains(location)) {
                
                currentState = MoveStates.n
                buttonNorth.texture = SKTexture(imageNamed: "Directional_Button_Lit")
                isPressing = true
                
            } else if (buttonSouth.frame.contains(location)) {
                
                currentState = MoveStates.s
                buttonSouth.texture = SKTexture(imageNamed: "Directional_Button_Lit")
                isPressing = true
                
            }  else if (buttonEast.frame.contains(location)) {
                
                currentState = MoveStates.e
                buttonEast.texture = SKTexture(imageNamed: "Directional_Button2_Lit")
                isPressing = true
                
            }  else if (buttonWest.frame.contains(location)) {
                
                currentState = MoveStates.w
                buttonWest.texture = SKTexture(imageNamed: "Directional_Button2_Lit")
                isPressing = true
                
            }
            
        }
    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (moveAtEndOfRelease == true) {
            
            buttonNorth.texture = SKTexture(imageNamed: "Directional_Button")
            buttonSouth.texture = SKTexture(imageNamed: "Directional_Button")
            buttonEast.texture = SKTexture(imageNamed: "Directional_Button2")
            buttonWest.texture = SKTexture(imageNamed: "Directional_Button2")
            
            //moveOnRelease()
            isPressing = false
            player.removeAllActions()
            player.texture = SKTexture(imageNamed: facingImage)
            
        }
    }
    
    // MARK: Physics
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if(contact.bodyA.categoryBitMask == BodyTpe.player.rawValue && contact.bodyB.categoryBitMask == BodyTpe.building.rawValue) {
            print("touched a building")
        } else if(contact.bodyB.categoryBitMask == BodyTpe.player.rawValue && contact.bodyA.categoryBitMask == BodyTpe.building.rawValue) {
            print("touched a building")
        }
        
    }

}




// MARK: Dpad controls press to move

//class GameScene: SKScene {
//
//    var player = SKSpriteNode()
//    var playerSpeedx: CGFloat = 0
//    var playerSpeedy: CGFloat = 0
//    var previousTimeInterval:TimeInterval = 0
//    let buttonNorth = SKSpriteNode(imageNamed: "Directional_Button")
//    let buttonSouth = SKSpriteNode(imageNamed: "Directional_Button")
//    let buttonEast = SKSpriteNode(imageNamed: "Directional_Button2")
//    let buttonWest = SKSpriteNode(imageNamed: "Directional_Button2")
//    var moveAtEndOfRelease:Bool = true
//    var playerSpeedX:CGFloat = 0.0
//    var playerSpeedY:CGFloat = 0.0
//    var currentState = MoveStates.n
//
//
//
//    override func didMove(to view: SKView) {
//        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//
//        // Make sure you can get teh player from the scene file
//        if let somePlayer = self.childNode(withName: "player") as? SKSpriteNode {
//            player = somePlayer
//
//            // Set physics
//            player.physicsBody?.isDynamic = false
//
//        } else {
//            print("No player")
//        }
//
//
//        let widthHalf:CGFloat = self.view!.bounds.width / 2
//        let heightHalf:CGFloat = self.view!.bounds.height / 2
//
//
//        self.addChild(buttonNorth)
//        buttonNorth.position = CGPoint(x: -widthHalf + 80, y: -heightHalf + 100)
//
//        self.addChild(buttonSouth)
//        buttonSouth.position = CGPoint(x: -widthHalf + 80, y: -heightHalf + 40)
//        buttonSouth.yScale = -1
//
//        self.addChild(buttonWest)
//        buttonWest.position = CGPoint( x: -widthHalf + 30, y: -heightHalf + 70)
//
//        self.addChild(buttonEast)
//        buttonEast.position = CGPoint( x: -widthHalf + 130, y: -heightHalf + 70)
//
//        buttonNorth.xScale = 0.4
//        buttonNorth.yScale = 0.4
//
//        buttonSouth.xScale = 0.4
//        buttonSouth.yScale = 0.4
//        buttonSouth.zRotation = CGFloat(Double.pi)
//
//        buttonEast.xScale = 0.4
//        buttonEast.yScale = 0.4
//        buttonEast.zRotation = CGFloat(Double.pi)
//
//        buttonWest.xScale = 0.4
//        buttonWest.yScale = 0.4
//
//
//
//
//    }
//
//    override func update(_ currentTime: TimeInterval) {
//
//        player.position = CGPoint(x: player.position.x + playerSpeedx, y: player.position.y + playerSpeedy)
//
//    }
//
//
//    func move(facing: Facing, x: CGFloat, y: CGFloat) {
//        let walkAnimation = SKAction(named: "walk\(facing)")!
//        let moveAction = SKAction.moveBy(x: x, y: y, duration: 1)
//        let group = SKAction.group([walkAnimation, moveAction])
//
//        // Run the actions
//        player.run(group)
//
//    }
//
//    func moveOnRelease() {
//
////        var xMove:CGFloat = 0
////        var yMove:CGFloat = 0
//
//        switch (currentState) {
//
//        case .n:
////            yMove = 1
////            xMove = 1.22
//            move(facing: .Back, x: 0, y: 10)
//        case .s:
////            yMove = -1
////            xMove = -1.22
//            move(facing: .Front, x: 0, y: -10)
//        case .e:
////            xMove = 1
////            yMove = -0.3
//            move(facing: .Right, x: 10, y: 0)
//        case .w:
////            xMove = -1
////            yMove = 0.3
//            move(facing: .Left, x: -10, y: 0)
//
//
//        }
//
//
////        let speed:CGFloat = 40
////        let move:SKAction = SKAction.moveBy(x: xMove * speed, y: yMove * speed, duration: 0.5)
////        move.timingMode = .easeOut
////
////
////        player.run(move)
//
//
//    }
//
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        for touch in (touches ) {
//            let location = touch.location(in: self)
//
//
//
//            if (buttonNorth.frame.contains(location)) {
//
//                currentState = MoveStates.n
//                buttonNorth.texture = SKTexture(imageNamed: "Directional_Button_Lit")
//
//            } else if (buttonSouth.frame.contains(location)) {
//
//                currentState = MoveStates.s
//                buttonSouth.texture = SKTexture(imageNamed: "Directional_Button_Lit")
//
//            }  else if (buttonEast.frame.contains(location)) {
//
//                currentState = MoveStates.e
//                buttonEast.texture = SKTexture(imageNamed: "Directional_Button2_Lit")
//
//            }  else if (buttonWest.frame.contains(location)) {
//
//                currentState = MoveStates.w
//                buttonWest.texture = SKTexture(imageNamed: "Directional_Button2_Lit")
//
//            }
//
//        }
//    }
//
//
//
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        if (moveAtEndOfRelease == true) {
//
//            buttonNorth.texture = SKTexture(imageNamed: "Directional_Button")
//            buttonSouth.texture = SKTexture(imageNamed: "Directional_Button")
//            buttonEast.texture = SKTexture(imageNamed: "Directional_Button2")
//            buttonWest.texture = SKTexture(imageNamed: "Directional_Button2")
//
//            moveOnRelease()
//
//        }
//    }
//
//}

// MARK: Joystick controlls


//class GameScene: SKScene {
//
//    var player = SKSpriteNode()
//    var playerSpeedx: CGFloat = 0
//    var playerSpeedy: CGFloat = 0
//    var previousTimeInterval:TimeInterval = 0
//    let ball = SKSpriteNode(imageNamed: "ball")
//    let base = SKSpriteNode(imageNamed: "base")
//    var stickActive = false
//
//
//    override func didMove(to view: SKView) {
//
//
//        // Make sure you can get teh player from the scene file
//        if let somePlayer = self.childNode(withName: "player") as? SKSpriteNode {
//            player = somePlayer
//
//            // Set physics
//            player.physicsBody?.isDynamic = false
//            player.speed = 1
//
//
//        } else {
//            print("No player")
//        }
//
//        // Setup the joystick
//        setupJoystick()
//
//    }
//
//    override func update(_ currentTime: TimeInterval) {
//
//        player.position = CGPoint(x: player.position.x + playerSpeedx, y: player.position.y + playerSpeedy)
//
//    }
//
//    func setupJoystick() {
//
//        addChild(base)
//        addChild(ball)
//
//        // Set the scale
//        base.xScale = 0.4
//        base.yScale = base.xScale
//
//        ball.xScale = 0.4
//        ball.yScale = ball.xScale
//
//        base.position = CGPoint(x: 0, y: -200)
//        ball.position = base.position
//    }
//
//    func move(facing: Facing, x: CGFloat, y: CGFloat) {
//        let walkAnimation = SKAction(named: "walk\(facing)")!
//        let moveAction = SKAction.moveBy(x: x, y: y, duration: 1)
//        let group = SKAction.group([walkAnimation, moveAction])
//
//        // Run the actions
//        player.run(group)
//
//    }
//
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        for touch in touches {
//            let location = touch.location(in: self)
//
//            if(base.frame.contains(location)) {
//                stickActive = true
//            } else {
//                stickActive = false
//            }
//        }
//    }
//
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        for touch in touches {
//            let location = touch.location(in: self)
//
//            if (stickActive) {
//                let vector = CGVector(dx: location.x - base.position.x, dy: location.y - base.position.y)
//                let angle = atan2(vector.dy, vector.dx)
//
//                // How can you go out from the base
//                let length: CGFloat = (base.frame.size.height / 2) - 50
//
//                let xDist: CGFloat = sin(angle - 1.57079633) * length
//                let yDist: CGFloat = cos(angle - 1.57079633) * length
//
//                if(base.frame.contains(location)) {
//
//                    // Lets the ball move inside the base
//                    ball.position = location
//
//                } else {
//
//                    // Makes the ball follow user finger
//                    ball.position = CGPoint(x: base.position.x - xDist, y: base.position.y + yDist)
//
//                }
//
//
//                // Setup speed
//                playerSpeedx = vector.dx * 0.1
//                playerSpeedy = vector.dy * 0.1
//
//            }
//
//        }
//
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        if(stickActive) {
//            let move = SKAction.move(to: CGPoint(x: base.position.x, y: base.position.y), duration: 0.2)
//            move.timingMode = .easeOut
//            ball.run(move)
//
//        }
//
//        // Reset the speeds
//        playerSpeedx = 0
//        playerSpeedy = 0
//
//    }
//
//}


// movement kinda works
//                var deg = angle * CGFloat(180 / Double.pi)
//                deg += 180
                
//                if((deg >= 0) && (deg <= 89)) {
//                    move(facing: .Front, x: 0, y: -10)
//                } else if((deg >= 90) && (deg <= 179)) {
//                    move(facing: .Right, x: 10, y: 0)
//                } else if((deg >= 180) && (deg <= 269)) {
//                    move(facing: .Back, x: 0, y: 10)
//                } else if((deg >= 270) && (deg <= 360)) {
//                    move(facing: .Left, x: -10, y: 0)
//                }
