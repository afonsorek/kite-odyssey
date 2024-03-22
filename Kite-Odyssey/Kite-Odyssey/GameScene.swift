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
    private var trail = [CGPoint]()
    private var finger = [CGPoint]()
    
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
        lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        if let record = UserDefaults.standard.object(forKey: "bestScore") as? Int {
            bestScore = record
        }
        
        self.background = self.childNode(withName: "long-bg") as? SKSpriteNode
        self.background?.zPosition = -10
        self.background?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.background?.position.y-=0.15
        }, SKAction.wait(forDuration: 0.01)])))
        
        self.bestLabel = self.childNode(withName: "bestScore") as? SKLabelNode
        self.bestLabel?.fontName = "Livvic-Regular"
        self.bestLabel?.text = "Best: \(bestScore) m"
        
        self.playerScore = self.childNode(withName: "playerScore") as? SKLabelNode
        self.playerScore?.fontName = "Livvic-Regular"
        self.playerScore?.text = "\(score) m"
        
        self.playerScore?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.score += 1
            self.playerScore?.text = "\(self.score) m"
        }, SKAction.wait(forDuration: 0.5)])))
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spawnEnemy()
        }, SKAction.wait(forDuration: 2)])))
        
        self.kite = self.childNode(withName: "kite")
        self.kite?.physicsBody?.velocity = CGVector(dx: 0, dy: 600)
        self.kite?.physicsBody?.allowsRotation = true
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
            let velocity = CGVector(dx: translation.x*5, dy: -translation.y*6)
//            let scaledVelocity = velocity * (self.kite?.frame.size.width / view!.bounds.width)
            
            kite?.run(SKAction.rotate(toAngle: 0, duration: 0.07))
            
            kite?.physicsBody?.linearDamping = 1.0
            kite?.physicsBody?.applyAngularImpulse(-(translation.x/500))
            
            kite?.physicsBody?.velocity = velocity
            self.startLocation = nil
            
        default:
            break
        }
    }
    
    
    func spawnEnemy(){
        var enemyList: [String] = []
        if self.score > 100{
            enemyList = ["enemy-bike", "enemy-car"]
        }else{
            enemyList = ["enemy-bike"]
        }
        let randomName = enemyList.randomElement()!
        let enemy = Object(image: SKSpriteNode(imageNamed: randomName), name: randomName)
        enemy.name = randomName
        enemy.physicsBody?.allowsRotation = true
        enemy.physicsBody?.angularVelocity = 5.0
        self.addChild(enemy)
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
            
            let trailNode = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: location)
            trailNode.path = path
            trailNode.strokeColor = .white
            trailNode.lineWidth = 10
            trailNode.zPosition = -1
            addChild(trailNode)
            
            let waitAction = SKAction.wait(forDuration: 1)
            let updateTrailAction = SKAction.run {
                self.finger.append(location)
                while self.finger.count > 4 {
                    self.finger.removeFirst()
                }
                let path = CGMutablePath()
                path.move(to: self.finger[0])
                for i in 1..<self.finger.count {
                    path.addLine(to: self.finger[i])
                }
                trailNode.path = path
            }
            let removeAction = SKAction.sequence([
                SKAction.fadeOut(withDuration: 1),
                SKAction.removeFromParent()
            ])
            let sequenceAction = SKAction.sequence([waitAction, updateTrailAction, removeAction])
            trailNode.run(sequenceAction)
        }
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches {
//            emitt(atPoint: t.location(in: self))
//        }
//    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "kite" ||  contact.bodyB.node?.name == "kite"{
            self.kite?.removeFromParent()
            
            let record = UserDefaults.standard.object(forKey: "bestScore") as? Int
            
            if score > record ?? 0 {
                UserDefaults.standard.set(score, forKey: "bestScore")
            }
            
            self.scene?.view?.isPaused = true
            
            //------------------------------------------------------------------------------------------------------
            //DEATH SCREEN
            
            let filter = SKSpriteNode(color: UIColor(ciColor: CIColor(red: 0, green: 0, blue: 0, alpha: 0.2)), size: self.size)
            filter.zPosition = 20
            self.addChild(filter)
            
            let banner = SKSpriteNode(imageNamed: "banner")
            banner.name = "banner"
            banner.zPosition = 21
            banner.setScale(0.6)
            let text = SKLabelNode(text: "\(score) m")
            text.fontSize = 200
            text.fontName = "Livvic-Black"
            text.position.y -= 45
            text.zPosition = 22
            let restart:SKSpriteNode = SKSpriteNode(imageNamed: "restart")
            restart.name = "restart"
            restart.setScale(0.65)
            restart.zPosition = 21
            
            banner.position.y = (self.size.height/2)-200
            self.addChild(banner)
            banner.addChild(text)
            self.addChild(restart)
            
            self.playerScore?.removeFromParent()
            self.bestLabel?.removeFromParent()
            
            //------------------------------------------------------------------------------------------------------

        }
        
        if contact.bodyA.node?.name == "enemy-bike" || contact.bodyA.node?.name == "enemy-car" {
            if contact.bodyB.node?.name != "kite" || contact.bodyB.node?.name != "enemy-car" || contact.bodyB.node?.name != "enemy-bike"{
                contact.bodyA.node?.removeFromParent()
            }
        } else if contact.bodyB.node?.name == "enemy-bike" || contact.bodyB.node?.name == "enemy-car"{
            if contact.bodyA.node?.name != "kite" || contact.bodyA.node?.name != "enemy-car" || contact.bodyA.node?.name != "enemy-bike"{
                contact.bodyB.node?.removeFromParent()
            }
        }
    }
    
    private func createTrail() {
        let trailNode = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: self.kite!.position)
        trailNode.path = path
        trailNode.strokeColor = .red
        trailNode.lineWidth = 4
        trailNode.zPosition = -1
        addChild(trailNode)
        
        let waitAction = SKAction.wait(forDuration: 1)
        let updateTrailAction = SKAction.run {
            self.trail.append(self.kite!.position)
            while self.trail.count > 4 {
                self.trail.removeFirst()
            }
            let path = CGMutablePath()
            path.move(to: self.trail[0])
            for i in 1..<self.trail.count {
                path.addLine(to: self.trail[i])
            }
            trailNode.path = path
        }
        let removeAction = SKAction.sequence([
            SKAction.fadeOut(withDuration: 1),
            SKAction.removeFromParent()
        ])
        let sequenceAction = SKAction.sequence([waitAction, updateTrailAction, removeAction])
        trailNode.run(sequenceAction)
    }
    
    private func collisionBetween(kite: SKNode, object: SKNode) {
        self.kite?.removeFromParent()
    }
    
    override func update(_ currentTime: TimeInterval) {
        createTrail()
    }
}
