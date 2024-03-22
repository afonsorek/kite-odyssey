//
//  GameScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 20/03/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    var bestScore = 0
    
    let thresholdAngle: CGFloat = 45.0
    
    //private var backgroundNodes: [SKShapeNode] = []
    
    private var background: SKSpriteNode?
    private var playerScore: SKLabelNode?
    private var bestLabel: SKLabelNode?
    private var kite: SKNode?
    private var right: SKNode?
    private var left: SKNode?
    private var bottom: SKNode?
    private var startLocation: CGPoint?
    
    private var lastUpdateTime: TimeInterval = 0
    private var backgroundSpeed: Double = 300.0
    private var score = 0
    
    override func sceneDidLoad() {
        //setUpBackground()
        lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        
        if let record = UserDefaults.standard.object(forKey: "bestScore") as? Int {
            print(record)
            
            bestScore = record
        }
        
        self.background = self.childNode(withName: "long-bg") as? SKSpriteNode
        
        self.background?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.background?.position.y-=1
        }, SKAction.wait(forDuration: 0.01)])))
        
        self.bestLabel = self.childNode(withName: "bestScore") as? SKLabelNode
        self.bestLabel?.text = "Best: \(bestScore) m"
        
        self.playerScore = self.childNode(withName: "playerScore") as? SKLabelNode
        self.playerScore?.text = "\(score) m"
        
        self.playerScore?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.score += 1
            self.playerScore?.text = "\(self.score) m"

        }, SKAction.wait(forDuration: 1)])))
        
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spawnEnemy()
        }, SKAction.wait(forDuration: Double(score == 0 ? 2 : score))])))
        self.kite = self.childNode(withName: "kite")
        self.kite?.physicsBody?.velocity = CGVector(dx: 0, dy: 600)
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
        
        
//        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeRight))
//        swipeRight.direction = .right
//        view.addGestureRecognizer(swipeRight)
//        
//        let swipeLeft : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeLeft))
//        swipeLeft.direction = .left
//        view.addGestureRecognizer(swipeLeft)
//        
//        let swipeDown : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeDown))
//        swipeDown.direction = .down
//        view.addGestureRecognizer(swipeDown)
//        
//        let swipeUp : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.swipeUp))
//        swipeUp.direction = .up
//        view.addGestureRecognizer(swipeUp)
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panRecognizer)
        
        
       // effect.run(SKAction.moveTo(x: 700, duration: 3))
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.startLocation = sender.location(in: view)
        case .changed:
            break // Don't apply force during the swipe
        case .ended:
            guard let startLocation = startLocation else { return }
            let endLocation = sender.location(in: view)
            var translation: CGPoint = CGPoint(x: 0, y: 0)
            translation.x = endLocation.x - startLocation.x
            translation.y = endLocation.y - startLocation.y

            // Calculate proportional velocity based on node size and screen width
            let velocity = CGVector(dx: translation.x*3, dy: -translation.y*4)
//            let scaledVelocity = velocity * (self.kite?.frame.size.width / view!.bounds.width)

            kite!.physicsBody?.velocity = velocity
            self.startLocation = nil // Reset start location for next swipe
        default:
            break
        }
    }
    
    
    func spawnEnemy(){
         let enemy = Object(image: SKSpriteNode(imageNamed: "enemy"))
         enemy.name = "enemy"
         self.addChild(enemy)
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
    
    @objc func swipeDown(sender: UISwipeGestureRecognizer){
        self.kite?.physicsBody?.velocity = CGVector(dx: 0, dy: -300)
        print("swiped down")
    }
    
    @objc func swipeUp(sender: UISwipeGestureRecognizer){
        self.kite?.physicsBody?.velocity = CGVector(dx: 0, dy: 450)
        print("swiped up")
    }
    
    @objc func swipeRight(sender: UISwipeGestureRecognizer){
        self.kite?.physicsBody?.velocity = CGVector(dx: 230, dy: 100)
        print("swiped rig")
    }
    
    @objc func swipeLeft(sender: UISwipeGestureRecognizer){
        self.kite?.physicsBody?.velocity = CGVector(dx: -230, dy: 10)
        print("swiped lef")
    }
    
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
             let location = touch.location(in: self)
             let touchedNode = atPoint(location)
             
             if touchedNode.name == "restart" {
                 if let scene = SKScene(fileNamed: "GameScene") {
                     scene.scaleMode = .aspectFill
                     
                     self.view?.presentScene(scene)
                 }
                 
                 self.view?.ignoresSiblingOrder = true
                 
                 self.view?.showsFPS = true
                 self.view?.showsNodeCount = true
             }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "kite" {
            print("node \(String(describing: contact.bodyA.node?.name)) colidiu com o node \(String(describing: contact.bodyB.node?.name))")
            collisionBetween(kite: contact.bodyA.node!, object: contact.bodyB.node!)
            
            let record = UserDefaults.standard.object(forKey: "bestScore") as? Int
            print(record ?? 0)
            if score > record ?? 0 {
                UserDefaults.standard.set(score, forKey: "bestScore")
            }
            
            self.scene?.view?.isPaused = true
            
            //DEATH SCREEN
            let filter = SKSpriteNode(color: UIColor(ciColor: CIColor(red: 0, green: 0, blue: 0, alpha: 0.4)), size: self.size)
            filter.zPosition = 20
            self.addChild(filter)
            
            let restart = SKSpriteNode(color: .gray, size: CGSize(width: 300, height: 200))
            restart.name = "restart"
            restart.zPosition = 21
            let text = SKLabelNode(text: "Restart")
            text.fontSize = 30
            text.zPosition = 22
            
            self.addChild(restart)
            self.addChild(text)
            
        } else if contact.bodyB.node?.name == "kite" {
            print("node \(String(describing: contact.bodyB.node?.name)) colidiu com o node \(String(describing: contact.bodyA.node?.name))")
            collisionBetween(kite: contact.bodyB.node!, object: contact.bodyA.node!)
            
            if let record = UserDefaults.standard.object(forKey: "bestScore") as? Int {
                print(record)
                if score > record {
                    UserDefaults.standard.set(score, forKey: "bestScore")
                }
            }
            
            self.scene?.view?.isPaused = true
            
            //DEATH SCREEN
            let filter = SKSpriteNode(color: UIColor(ciColor: CIColor(red: 0, green: 0, blue: 0, alpha: 0.4)), size: self.size)
            filter.zPosition = 20
            self.addChild(filter)
            
            let restart = SKSpriteNode(color: .gray, size: CGSize(width: 300, height: 200))
            restart.name = "restart"
            restart.zPosition = 21
            let text = SKLabelNode(text: "Restart")
            text.fontSize = 30
            text.zPosition = 22
            
            self.addChild(restart)
            self.addChild(text)
        }
        
        if contact.bodyA.node?.name == "enemy" {
            print("node \(String(describing: contact.bodyA.node?.name)) colidiu com o node \(String(describing: contact.bodyB.node?.name))")
            if contact.bodyB.node?.name != "kite"{
                contact.bodyA.node?.removeFromParent()
            }
        } else if contact.bodyB.node?.name == "enemy" {
            print("node \(String(describing: contact.bodyB.node?.name)) colidiu com o node \(String(describing: contact.bodyA.node?.name))")
            if contact.bodyA.node?.name != "kite"{
                contact.bodyB.node?.removeFromParent()
            }
        }
    }
    
    private func collisionBetween(kite: SKNode, object: SKNode) {
        self.kite?.removeFromParent()
    }
    
//    private func setUpBackground() {
//        
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
//    }
    
    override func update(_ currentTime: TimeInterval) {
        //
    }
}
