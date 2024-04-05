//
//  GameScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 20/03/24.
//

import SpriteKit
import GameplayKit
import GameKit
import SwiftUI
import GoogleMobileAds

class GameScene: SKScene, GADFullScreenContentDelegate, SKPhysicsContactDelegate, GKGameCenterControllerDelegate{
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
#if DEBUG
let rewardAdId = "ca-app-pub-3940256099942544/5224354917"
#else
let rewardAdId = "ca-app-pub-1875006395039971~6903365759"
#endif
    
    var gameCenterLeaderboardID = "highestKite"
    
    let soundController = SoundManager()
    
    private var dead = false
    private var cancel = false
    
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
    
    private var levelCount = 0.0
    private var enemyFreq = 4.0
    
    private var isSecondChance = false
    
    private var deathScene: DeathScene?
    
    override func sceneDidLoad() {
        checkRecord()
    }
    
    
    override func didMove(to view: SKView) {
        soundController.playLoop(sound: .theme)
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.size = UIScreen.main.bounds.size
        }
        RewardedAd.shared.loadAd(withAdUnitId: rewardAdId)
        
        physicsWorld.contactDelegate = self
        GKAccessPoint.shared.isActive = false
                
        self.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run {
                if self.levelCount.truncatingRemainder(dividingBy: self.enemyFreq) == 0{
                    self.spawnEnemy()
                }
                
                if self.levelCount < 30 {
                    //
                }else if self.levelCount < 60 {
                    self.enemyFreq = 3.0
                }else if self.levelCount < 120 {
                    self.enemyFreq = 2.0
                }else if self.levelCount < 200 {
                    self.enemyFreq = 1.5
                }else if self.levelCount < 300 {
                    self.enemyFreq = 1.0
                }else{
                    self.enemyFreq = 0.5
                }
                
                self.levelCount += 0.5
            }
        ])))
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 23), SKAction.run {
            self.spawnPowerUp()
        }])))
        
        //Apply force and create kite
        kite = Kite(child: self.childNode(withName: "kite")! as! SKSpriteNode)
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
            let enemyList1: [String] = ["enemy-shoe", "enemy-ball", "enemy-rock1", "enemy-rock2"]
            let enemyList2: [String] = ["enemy-bike", "enemy-shoe", "enemy-ball", "enemy-rock2"]
            let enemyList3: [String] = ["enemy-bike", "enemy-shoe", "enemy-ball", "enemy-rock1", "enemy-antenna"]
            let enemyList4: [String] = ["enemy-bike", "enemy-shoe", "enemy-ball", "enemy-rock1", "enemy-antenna", "enemy-umbrella"]
            let enemyListFinal: [String] = ["enemy-bike", "enemy-antenna", "enemy-shoe", "enemy-ball", "enemy-rock2", "enemy-wing", "enemy-umbrella"]
            
            let everyList = [enemyList1, enemyList2, enemyList3, enemyList4, enemyListFinal]
            
            var levelList = 0
            
            if self.score < 40 {
                levelList = 0
            }else if self.score < 150{
                levelList = 1
            }else if self.score < 300{
                levelList = 2
            }else if self.score < 450{
                levelList = 3
            }else{
                levelList = 4
            }
            
            let randomName = everyList[levelList].randomElement()!
            
            let enemy = Object(image: SKSpriteNode(imageNamed: randomName), name: randomName)
            self.addChild(enemy)
            enemy.run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.run {
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
            
            if GKLocalPlayer.local.isAuthenticated{
                GKLeaderboard.submitScore(record ?? 0, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [gameCenterLeaderboardID]) { error in
                    if error != nil{
                        print(error!.localizedDescription)
                    } else{
                        print("Score Submitted")
                    }
                }
            }
        }
        
        
    }
    
    func showRewarded(){
        if let ad = RewardedAd.shared.rewardedAd{
            ad.fullScreenContentDelegate = self
            ad.present(fromRootViewController: nil) {
                print("voce foi premiado")
            }
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        self.deathScene!.child.isHidden = true
        if let bro = self.childNode(withName: "deathScene"){
            bro.removeFromParent()
        }
        self.isSecondChance = true
        self.view?.isPaused = false
        self.kite?.setBody()
    }
    
    func redscreen(){
        self.run(SKAction.sequence([
            SKAction.run {
                let red = SKSpriteNode(color: .red, size: self.size)
                red.alpha = 0.0
                self.addChild(red)
                red.run(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.2, duration: 0.2),
                    SKAction.wait(forDuration: 0.3),
                    SKAction.fadeAlpha(to: 0, duration: 0.2)
                ]))
            },

        ]))
    }
    
    func playerStuned() {
        self.run(SKAction.repeat(SKAction.sequence([
            SKAction.run {
                self.soundController.fadeOut(sound: .theme)
            },
            SKAction.wait(forDuration: 0.2)
        ]), count: 10))
        self.redscreen()
        self.view!.isUserInteractionEnabled = false // Disable user interaction
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.run {
                if self.childNode(withName: "deathScene") == nil{
                    self.deathScene = DeathScene(father: self, score: self.score, isSecondChance: self.isSecondChance)
                    self.deathScene!.child.name = "deathScene"
                    self.deathScene!.child.isHidden = true
                    self.addChild(self.deathScene!.child)
                    
                    self.deathScene!.child.isHidden = false
                }
            },
            SKAction.run {
                self.kite?.child?.position = CGPoint(x: 0, y: 0)
                self.view?.isPaused = true
                self.view!.isUserInteractionEnabled = true // Enable user interaction after scene transition
            }
        ]))
        cancel = true
    }
    
    func playerDeath() {
        checkRecord()
        soundController.fadeOut(sound: .theme)
        
        self.redscreen()
        
        self.view!.isUserInteractionEnabled = false // Disable user interaction
        
        self.run(SKAction.sequence([
            SKAction.run {
                self.kite?.die()
            },
            SKAction.wait(forDuration: 2),
            SKAction.run {
                self.kite?.child!.removeFromParent()
                self.playerScore?.removeFromParent()
                self.bestLabel?.removeFromParent()
            },
            SKAction.wait(forDuration: 0.2),
            SKAction.run {
                if self.childNode(withName: "deathScene") == nil{
                    self.deathScene = DeathScene(father: self, score: self.score,isSecondChance: self.isSecondChance)
                    self.deathScene!.child.name = "deathScene"
                    self.deathScene!.child.isHidden = true
                    self.addChild(self.deathScene!.child)
                }
                self.deathScene!.child.isHidden = false
            },
            SKAction.run {
                self.view?.isPaused = true
                self.view!.isUserInteractionEnabled = true
            }
        ]))
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
                if isSecondChance == false{
                    playerStuned()
                }else{
                    dead = true
                    playerDeath()
                }
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
                touchedNode.run(SKAction.sequence([
                  SKAction.scale(to: 1.1, duration: 0.2),
                  SKAction.wait(forDuration: 0.2),
                  SKAction.scale(to: 1.0, duration: 0.2)
                ]))
                
                self.removeAllActions()
                self.removeAllChildren()
                if let scene = SKScene(fileNamed: "GameScene") {
                    scene.scaleMode = .aspectFill
                    self.view?.presentScene(scene)
                }
                 
                self.view?.ignoresSiblingOrder = true
            }
            
            if touchedNode.name == "continue"{
                showRewarded()
            }
            
            if touchedNode.name == "home" {
                touchedNode.run(SKAction.sequence([
                  SKAction.scale(to: 1.1, duration: 0.2),
                  SKAction.wait(forDuration: 0.2),
                  SKAction.scale(to: 1.0, duration: 0.2),
                ]))
                
                self.removeAllActions()
                self.removeAllChildren()
                
                if let scene = SKScene(fileNamed: "MenuScene") {
                    scene.scaleMode = .aspectFill
                    
                    self.view?.presentScene(scene)
                }
                 
                self.view?.ignoresSiblingOrder = true
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        createTrail()
        
        if !intersects(kite!.child!) && !dead {
            playerStuned()
            dead = true
            cancel = true
        }else if !intersects(kite!.child!) && dead && !cancel{
            playerDeath()
            cancel = true
        }
    }
}
