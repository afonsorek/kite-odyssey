//
//  GameScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 20/03/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    private var backgroundNodes: [SKSpriteNode] = []
    private var playerScore: SKLabelNode?
    private var kite: SKNode?
    private var right: SKNode?
    private var left: SKNode?
    private var bottom: SKNode?
    
    private var lastUpdateTime: TimeInterval = 0
    private var backgroundSpeed: Double = 100.0
    private var score = 0
    
    override func sceneDidLoad() {
        lastUpdateTime = 0
        setUpBackground()
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        //////////////////////////////////////////////////////////////////////////////

        let trail1 = makeTrail()
        let trail2 = makeTrail()
            // Make the second trail slightly taller and change the blend mode to `add`.
            trail2.zPosition = 1
            trail2.yScale = 1.25
            for child in trail2.children {
            if let child = child as? SKSpriteNode {
                child.blendMode = .add
            }
        }
        
        let bg = SKSpriteNode(color: .black, size: .init(width: 4000, height: 95))
        bg.zPosition = -1
        bg.isHidden = true
        // Mask with the crop node.
        let mask = SKSpriteNode(color: .red, size: .init(width: 400, height: 95))
        let crop = SKCropNode()
        crop.maskNode = mask
        crop.addChild(bg)
        crop.addChild(trail1)
        crop.addChild(trail2)
        
        let move1 = SKAction.moveTo(x: 512, duration: 0)
        let move2 = SKAction.moveTo(x: -512, duration: 2)
        trail1.run(.repeatForever(.sequence([move1, move2])))
        let move3 = SKAction.moveTo(x: 512, duration: 0)
        let move4 = SKAction.moveTo(x: -512, duration: 2.5)
        trail2.run(.repeatForever(.sequence([move3, move4])))
        
        let opacity = SKSpriteNode(imageNamed: "linear-gradient")
        opacity.blendMode = .multiplyAlpha
        opacity.zPosition = 2
        
        let effect = SKEffectNode()
        effect.addChild(crop)
        effect.addChild(opacity)
        // Create the tapered coordinates.
        let destinationPositions: [vector_float2] = [
        vector_float2(0, 5),   vector_float2(0.5, 0.9), vector_float2(1, -2.5),
        vector_float2(0, 0.5), vector_float2(0.5, 0.5), vector_float2(1, 0.5),
        vector_float2(0, -4),  vector_float2(0.5, 0.1), vector_float2(1, 3.5)
        ]
        let warpGeometryGrid = SKWarpGeometryGrid(columns: 2, rows: 2)
        // Apply the tapered effect.
        effect.warpGeometry = warpGeometryGrid.replacingByDestinationPositions(positions:destinationPositions)
        // Control the quality of the distortion effect.
        effect.subdivisionLevels = 4
        
        let bloomFilter = CIFilter(name: "CIBloom")!
        bloomFilter.setValue(5, forKey: "inputRadius")
        bloomFilter.setValue(1, forKey: "inputIntensity")
        effect.filter = bloomFilter
        
        //////////////////////////////////////////////////////////////////////////////
        
        self.playerScore = self.childNode(withName: "//playerScore") as? SKLabelNode
        self.playerScore?.text = "\(score) m"
        
        self.playerScore?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.score += 1
            self.playerScore?.text = "\(self.score) m"
        }, SKAction.wait(forDuration: 1)])))
        
        self.kite = self.childNode(withName: "//kite")
        self.kite?.physicsBody?.velocity = CGVector(dx: 0, dy: 400)
        self.kite?.physicsBody?.contactTestBitMask = (self.kite?.physicsBody!.collisionBitMask)!
        
        self.right = self.childNode(withName: "right")
        self.right?.physicsBody = SKPhysicsBody(rectangleOf: (self.right?.frame.size)!)
        self.right?.physicsBody?.affectedByGravity = false
        self.right?.physicsBody?.isDynamic = false
        
        self.left = self.childNode(withName: "left")
        self.left?.physicsBody = SKPhysicsBody(rectangleOf: (self.left?.frame.size)!)
        self.left?.physicsBody?.affectedByGravity = false
        self.left?.physicsBody?.isDynamic = false
        
        self.bottom = self.childNode(withName: "bottom")
        self.bottom?.physicsBody = SKPhysicsBody(rectangleOf: (self.bottom?.frame.size)!)
        self.bottom?.physicsBody?.affectedByGravity = false
        self.bottom?.physicsBody?.isDynamic = false
        
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        effect.run(SKAction.moveTo(x: 700, duration: 3))
    }
    
    func makeTrail() -> SKNode {
      let trailC = SKSpriteNode(imageNamed: "trail")
      let trailL = SKSpriteNode(imageNamed: "trail")
      let trailR = SKSpriteNode(imageNamed: "trail")

      trailL.position.x = -512
      trailR.position.x = 512

      let trails = SKNode()
      trails.addChild(trailC)
      trails.addChild(trailL)
      trails.addChild(trailR)

      return trails
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    @objc func swipeRight(sender: UISwipeGestureRecognizer){
        self.kite?.physicsBody?.velocity = CGVector(dx: 120, dy: 400)
        print("swiped rig")
    }
    
    @objc func swipeLeft(sender: UISwipeGestureRecognizer){
        self.kite?.physicsBody?.velocity = CGVector(dx: -120, dy: 400)
        print("swiped lef")
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "kite" {
            print("node \(contact.bodyA.node?.name) colidiu com o node \(contact.bodyB.node?.name)")
            collisionBetween(kite: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "kite" {
            print("node \(contact.bodyB.node?.name) colidiu com o node \(contact.bodyA.node?.name)")
            collisionBetween(kite: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    
    private func collisionBetween(kite: SKNode, object: SKNode) {
        self.kite?.removeFromParent()
    }
    
    private func setUpBackground() {
        
//        let yellowBackgroundTop = SKShapeNode(rectOf: CGSize(width: self.size.width, height: self.size.height/2))
//        yellowBackgroundTop.position = CGPoint(x: self.frame.midX, y: 0.75*self.size.height)
//        yellowBackgroundTop.zPosition = -15
//        yellowBackgroundTop.strokeColor = .systemGray6
//        yellowBackgroundTop.fillColor = .systemGray6
//        
//        let yellowBackgroundBottom = SKShapeNode(rectOf: CGSize(width: self.size.width, height: self.size.height/2))
//        yellowBackgroundBottom.position = CGPoint(x: self.frame.midX, y: -0.25*self.size.height)
//        yellowBackgroundBottom.zPosition = -15
//        yellowBackgroundBottom.strokeColor = .systemGray6
//        yellowBackgroundBottom.fillColor = .systemGray6
//  
//        
//        let redBackgroundTop = SKShapeNode(rectOf: CGSize(width: self.size.width, height: self.size.height/2))
//        redBackgroundTop.position = CGPoint(x: self.frame.midX, y:  0.25*self.size.height)
//        redBackgroundTop.zPosition = -15
//        redBackgroundTop.strokeColor = .systemGray3
//        redBackgroundTop.fillColor = .systemGray3
//        
//        let redBackgroundBottom = SKShapeNode(rectOf: CGSize(width: self.size.width, height: self.size.height/2))
//        redBackgroundBottom.position = CGPoint(x: self.frame.midX, y: -0.75*self.size.height)
//        redBackgroundBottom.zPosition = -15
//        redBackgroundBottom.strokeColor = .systemGray3
//        redBackgroundBottom.fillColor = .systemGray3
//
//        self.addChild(yellowBackgroundTop)
//        self.addChild(yellowBackgroundBottom)
//        self.addChild(redBackgroundTop)
//        self.addChild(redBackgroundBottom)
//        
//        backgroundNodes.append(contentsOf: [yellowBackgroundTop, yellowBackgroundBottom, redBackgroundTop, redBackgroundBottom])
        
        let planoTop = SKSpriteNode(imageNamed: "planoTop")
        planoTop.size.width = self.size.width
        planoTop.size.height = self.size.height/2
        planoTop.position = CGPoint(x: self.frame.midX, y: 0.75*self.size.height)
        planoTop.zPosition = -15

        let planoMid2 = SKSpriteNode(imageNamed: "planoMid2")
        planoMid2.size.width = self.size.width
        planoMid2.size.height = self.size.height/2
        planoMid2.position = CGPoint(x: self.frame.midX, y: -0.25*self.size.height)
        planoMid2.zPosition = -15


        let planoMid1 = SKSpriteNode(imageNamed: "planoMid1")
        planoMid1.size.width = self.size.width
        planoMid1.size.height = self.size.height/2
        planoMid1.position = CGPoint(x: self.frame.midX, y:  0.25*self.size.height)
        planoMid1.zPosition = -15

        let planoBot = SKSpriteNode(imageNamed: "planoBot")
        planoBot.size.width = self.size.width
        planoBot.size.height = self.size.height/2
        planoBot.position = CGPoint(x: self.frame.midX, y: -0.75*self.size.height)
        planoBot.zPosition = -15


        self.addChild(planoTop)
        self.addChild(planoBot)
        self.addChild(planoMid1)
        self.addChild(planoMid2)

        backgroundNodes.append(contentsOf: [planoTop, planoBot, planoMid1, planoMid2])
                
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        
        for n in backgroundNodes {
            n.position.y = n.position.y - (currentTime - lastUpdateTime) * backgroundSpeed

            if n.position.y < -0.75 * self.size.height {
                n.position.y = 1.25 * self.size.height
            }
        }

        lastUpdateTime = currentTime
    }
}
