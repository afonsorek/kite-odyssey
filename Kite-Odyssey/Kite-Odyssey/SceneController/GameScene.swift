//
//  GameScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 20/03/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    private var count = 0
    private var bestScore = 0
    private let thresholdAngle: CGFloat = 45.0
    
    private var trail = [CGPoint]()
    private var finger = [CGPoint]()
    
    private var background: SKSpriteNode?
    private var background2: SKSpriteNode?
    
    private var playerScore: SKLabelNode?
    private var bestLabel: SKLabelNode?

    private var right: SKNode?
    private var left: SKNode?
    private var bottom: SKNode?
    
    private var kite: Kite?
    
    private var startLocation: CGPoint?
    
    private var lastUpdateTime: TimeInterval = 0
    private var score = 0
    private var scoreBase = 1
    private var translation: CGPoint = CGPoint(x: 0, y: 0)
    
    private var velocity = 0.5
    private var enemyFreq = 4.0
    
    override func sceneDidLoad() {
        //Set Best Score
        checkRecord()
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 20), SKAction.run {
            self.spawnPowerUp()
            if self.enemyFreq > 0.0{
                self.enemyFreq -= self.enemyFreq-0.5
            }
        }])))
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spawnEnemy()
        }, SKAction.wait(forDuration: self.enemyFreq)])))
        
        //Apply force and create kite
        kite = Kite(child: self.childNode(withName: "kite")!)
        kite?.setBody()
        
        self.background = self.childNode(withName: "long-bg") as? SKSpriteNode
        self.background?.zPosition = -10
        self.background?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.background?.position.y-=self.velocity
        }, SKAction.wait(forDuration: 0.01)])))
        
        self.background2 = self.childNode(withName: "long-bg-2") as? SKSpriteNode
        self.background2?.zPosition = -10
        self.background2?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.background2?.position.y-=self.velocity
        }, SKAction.wait(forDuration: 0.01)])))
        
        self.bestLabel = self.childNode(withName: "bestScore") as? SKLabelNode
        self.bestLabel?.fontName = "Montserrat-Regular"
        self.bestLabel?.text = "Best: \(bestScore) m"
        
        self.playerScore = self.childNode(withName: "playerScore") as? SKLabelNode
        self.playerScore?.fontName = "Montserrat-Regular"
        self.playerScore?.text = "\(score) m"
        
        self.playerScore?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.score += self.scoreBase
            self.playerScore?.text = "\(self.score) m"
        }, SKAction.wait(forDuration: 0.5)])))
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panRecognizer)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.startLocation = sender.location(in: view)
        case .changed:
            break
        case .ended:
            guard let startLocation = startLocation else { return }
            
            let endLocation = sender.location(in: view)
            
            translation.x = endLocation.x - startLocation.x
            translation.y = endLocation.y - startLocation.y

            let velocity = CGVector(dx: translation.x*7.5, dy: -translation.y*6.5)
            
            kite!.applyForce(velocity: velocity, translation: translation)
            
            self.startLocation = nil
        default:
            break
        }
    }
    
    func spawnPowerUp(){
        DispatchQueue.main.async{
            let powerUp = PowerUp()
            powerUp.setBody()
            powerUp.node.name = "powerUp"
            self.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run {
                    self.addChild(powerUp.node)
                }
            ]))
        }
    }
    
    func spawnEnemy(){
        DispatchQueue.main.async{
            let enemyList: [String] = ["enemy-bike", "enemy-antenna", "enemy-shoe", "enemy-ball", "enemy-rock1", "enemy-rock2", "enemy-wing", "enemy-umbrella"]
            let randomName = enemyList.randomElement()!
            
            let enemy = Object(image: SKSpriteNode(imageNamed: randomName), name: randomName)
            self.addChild(enemy)
            enemy.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.run {
                enemy.removeFromParent()
            }]))
        }
     }
    
    func checkRecord(){
        if let record = UserDefaults.standard.object(forKey: "bestScore") as? Int {
            bestScore = record
        }
        
        let record = UserDefaults.standard.object(forKey: "bestScore") as? Int
        if score > record ?? 0 {
            UserDefaults.standard.set(score, forKey: "bestScore")
        }
    }
    
    func playerDeath(){
        checkRecord()
        
        self.kite?.child!.removeFromParent()
        self.playerScore?.removeFromParent()
        self.bestLabel?.removeFromParent()
        
        self.scene?.view?.isPaused = true
        
        addChild(DeathScene(father: self, score: score))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "kite" ||  contact.bodyB.node?.name == "kite"{
            if contact.bodyA.node?.name == "powerUp" || contact.bodyB.node?.name == "powerUp"{
                self.run(SKAction.sequence([
                    SKAction.run {
                        self.view!.isUserInteractionEnabled = false
                        self.kite?.powerUp(screen: self.frame)
                        self.scoreBase = 10
                        let emitter = SKEmitterNode(fileNamed: "MyParticle")
                        emitter?.name = "wind"
                        self.addChild(emitter!)
                        self.childNode(withName: "powerUp")?.removeFromParent()
                        self.velocity = 3.0
                },
                    SKAction.wait(forDuration: 4),
                    SKAction.run {
                        self.view!.isUserInteractionEnabled = true
                        self.velocity = 0.5
                        self.scoreBase = 1
                        self.childNode(withName: "wind")?.removeFromParent()
                }
                ]))
            }else{
                playerDeath()
            }
        }else if contact.bodyA.node?.name == "ABUBLE"{
            contact.bodyB.node?.removeFromParent()
        } else if contact.bodyB.node?.name == "ABUBLE"{
            contact.bodyA.node?.removeFromParent()
        }
    }
    
    private func createTrail() {
        let trailNode = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: self.kite!.child!.position)
        trailNode.path = path
        trailNode.strokeColor = .red
        trailNode.lineWidth = 2
        trailNode.zPosition = -1
        addChild(trailNode)
        
        let waitAction = SKAction.wait(forDuration: 1)
        let updateTrailAction = SKAction.run {
            self.trail.append(self.kite!.child!.position)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
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
    
    override func update(_ currentTime: TimeInterval) {
        createTrail()
        if !intersects(kite!.child!){
            playerDeath()
        }
    }
}
