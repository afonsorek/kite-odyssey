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
import UIKit
import CoreHaptics

class GameScene: SKScene, GADFullScreenContentDelegate, SKPhysicsContactDelegate, GKGameCenterControllerDelegate{
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
#if DEBUG
let rewardAdId = "ca-app-pub-3940256099942544/5224354917"
#else
let rewardAdId = "ca-app-pub-1875006395039971/4026437896"
#endif
    
    let gameCenterLeaderboardID = "highestKite"
    
    let soundController = SoundManager()
    
    var isBGinverted = false
    var isLoaded = false
    
    private var dead = false
    private var cancel = false
    
    private var count = 0
    private var bestScore = 0
    private let thresholdAngle: CGFloat = 45.0
    
    private var trail = [CGPoint]()
    private var finger = [CGPoint]()
    
    private var bg: SKSpriteNode?
    private var bg2: SKSpriteNode?
    
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
    
    private var velocity = 0.8
    private var originalPositionBG1: CGPoint?
    private var originalPositionBG2: CGPoint?
    
    private var levelCount = 0.0
    private var enemyFreq = 4.0
    
    private var isSecondChance = false
    
    private var deathScene: DeathScene?
    
    let generator = UINotificationFeedbackGenerator()
    var engine: CHHapticEngine?
    
    override func didMove(to view: SKView) {
        kite = Kite(child: self.childNode(withName: "kite")! as! SKSpriteNode)
        kite?.setBody()
        
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
        
        
        self.soundController.stop(sound: .theme)
        self.soundController.playLoop(sound: .theme)
        
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
        
        
        self.buildBG()
        
        self.bestLabel = self.childNode(withName: "bestScore") as? SKLabelNode
        self.bestLabel?.fontName = "Montserrat-Regular"
        self.bestLabel?.text = "\(bestScore) m"
        
        self.loadRecord()
        
        self.playerScore = self.childNode(withName: "playerScore") as? SKLabelNode
        
        let shadow = SKLabelNode(text: "\(score) m")
        shadow.fontColor = .black
        shadow.fontSize = playerScore!.fontSize
        shadow.alpha = 0.5
        shadow.fontSize = playerScore!.fontSize
        shadow.fontName = playerScore!.fontName
        shadow.name = "shadow"
        shadow.position = CGPoint(x: 0, y: -12)
        shadow.zPosition = -1
        
        let blurNode = SKEffectNode()
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(6.0, forKey: "inputRadius") // Adjust radius for blur strength
        blurNode.filter = blurFilter
        blurNode.addChild(shadow)
        blurNode.position = shadow.position
        blurNode.zPosition = shadow.zPosition
        
        self.playerScore?.fontName = "Montserrat-Regular"
        self.playerScore?.text = "\(score) m"
        self.playerScore?.addChild(blurNode)
        
        self.playerScore?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.score += self.scoreBase
            self.playerScore?.text = "\(self.score) m"
            shadow.text = "\(self.score) m"
        }, SKAction.wait(forDuration: 0.5)])))
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panRecognizer)
    }
    
    func removeBG(){
        if let bg = self.childNode(withName: "long-bg"){
            bg.removeFromParent()
        }
        if let bg2 = self.childNode(withName: "long-bg-2"){
            bg2.removeFromParent()
        }
    }
    
    func buildBG(){
        self.bg = self.childNode(withName: "long-bg-1") as? SKSpriteNode
        self.bg?.zPosition = -10
        
        self.bg?.anchorPoint.y = 0
        self.bg?.anchorPoint.x = 0.5
        
        self.bg?.position = CGPoint(x: 0, y: -self.size.height/2)
        
        self.originalPositionBG1 = self.bg?.position
        
        self.bg?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.bg?.position.y-=self.velocity
        }, SKAction.wait(forDuration: 0.01)])))
        
        self.bg2 = self.childNode(withName: "long-bg-2") as? SKSpriteNode
        self.bg2?.zPosition = -10
        
        self.bg2?.anchorPoint.y = 0
        self.bg2?.anchorPoint.x = 0.5
        
        self.bg2?.position = CGPoint(x: 0, y: self.bg?.frame.maxY ?? 0)
        
        self.originalPositionBG2 = self.bg2?.position
        
        self.bg2?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.bg2?.position.y-=self.velocity
        }, SKAction.wait(forDuration: 0.01)])))
        
        self.isLoaded = true
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.startLocation = sender.location(in: view)
        case .changed:
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

            var events = [CHHapticEvent]()

            for i in stride(from: 0, to: 0.4, by: 0.1) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(0.35 - i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.25 - i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i, duration: 2)
                events.append(event)
            }
            
            do {
                let pattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
            } catch {
                print("Failed to play pattern: \(error.localizedDescription).")
            }
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
            enemy.name = "enemy"
            self.addChild(enemy)
            enemy.run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.run {
                enemy.removeFromParent()
            }]))
        }
     }
    
    func loadRecord(){
        let record = UserDefaults.standard.object(forKey: "bestScore") as? Int
        
        if record != nil{
            self.bestScore = record!
            self.bestLabel?.text = "\(self.bestScore) m"
        }else{
            
        }
        
        if GKLocalPlayer.local.isAuthenticated{
            GKLeaderboard.loadLeaderboards( IDs: [gameCenterLeaderboardID]) { leaderboards, _ in
                leaderboards?[0].loadEntries( for: [GKLocalPlayer.local], timeScope: .allTime) { player, _, _ in
                    if player?.score ?? 0 > record ?? 0{
                        self.bestScore = player?.score ?? 0
                        self.bestLabel?.text = "\(self.bestScore) m"
                    }
                }
            }
        }
    }
    
    func setRecord(){
        let record = UserDefaults.standard.object(forKey: "bestScore") as? Int

        if self.score > record ?? 0 || record ?? 0 > bestScore {
            UserDefaults.standard.set(self.score, forKey: "bestScore")
            
            if GKLocalPlayer.local.isAuthenticated{
                GKLeaderboard.submitScore(self.score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [gameCenterLeaderboardID]) { error in
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
        self.soundController.play(sound: .theme)
        self.kite?.setBody()
        self.cancel = false
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
        generator.notificationOccurred(.error)
        self.run(SKAction.repeat(SKAction.sequence([
            SKAction.run {
                self.soundController.fadeOut(sound: .theme)
            },
            SKAction.wait(forDuration: 0.2),
        ]), count: 11))
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
                    self.soundController.stop(sound: .theme)
                    self.deathScene!.child.isHidden = false
                }
            },
            SKAction.run {
                self.enumerateChildNodes(withName: "enemy", using: { childEnemy, _ in
                    childEnemy.removeFromParent()
                })
                self.kite?.child?.position = CGPoint(x: 0, y: 0)
                self.view?.isPaused = true
                self.view!.isUserInteractionEnabled = true // Enable user interaction after scene transition
            }
        ]))
        cancel = true
        setRecord()
    }
    
    func playerDeath() {
        generator.notificationOccurred(.error)
        
        self.run(SKAction.repeat(SKAction.sequence([
            SKAction.run {
                self.soundController.fadeOut(sound: .theme)
            },
            SKAction.wait(forDuration: 0.2),
        ]), count: 11))
        setRecord()
        
        self.redscreen()
        
        self.view!.isUserInteractionEnabled = false // Disable user interaction
        
        self.run(SKAction.sequence([
            SKAction.run {
                self.kite?.die()
            },
            SKAction.wait(forDuration: 2),
            SKAction.run {
                self.soundController.stop(sound: .theme)
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
                guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0, duration: 4)
                
                do {
                    let pattern = try CHHapticPattern(events: [event], parameters: [])
                    let player = try engine?.makePlayer(with: pattern)
                    try player?.start(atTime: 0)
                } catch {
                    print("Failed to play pattern: \(error.localizedDescription).")
                }
                
                self.run(SKAction.sequence([
                    SKAction.run {
                        self.view!.isUserInteractionEnabled = false
                        self.kite?.powerUp(screen: self.frame)
                        self.scoreBase = 10
                        let emitter = SKEmitterNode(fileNamed: "MyParticle")
                        emitter?.name = "wind"
                        self.addChild(emitter!)
                        self.childNode(withName: "powerUp")?.removeFromParent()
                        self.velocity = 4.0
                },
                    SKAction.wait(forDuration: 4),
                    SKAction.run {
                        self.view!.isUserInteractionEnabled = true
                        self.velocity = 0.8
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
            
            if touchedNode.name == "instagram"{
                //instagramStoriesShare()
                self.shareCapturedImage(captureSceneAsUIImage()!)
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
    
//    func instagramStoriesShare(){
//        guard let capturedImage = captureSceneAsUIImage() else {
//            print("Failed to capture scene")
//            return
//        }
//        
//        let instagramUrl = URL(string: "instagram-stories://share")
//        if UIApplication.shared.canOpenURL(instagramUrl!) {
//            guard let imageData = capturedImage.pngData() else {
//                print("Failed to convert image to data")
//                return
//            }
//            
//            let pasteboardItems: [String: Any] = [
//                "com.instagram.sharedSticker.stickerImage": imageData,
//                "com.instagram.sharedSticker.backgroundTopColor": "#275FA5",
//                "com.instagram.sharedSticker.backgroundBottomColor": "#D9C26B"
//            ]
//            
//            let pasteboardOptions = [
//                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
//            ]
//            
//            UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
//            UIApplication.shared.open(instagramUrl!, options: [:]) { (success) in
//                if !success {
//                    print("Deep link failed, fallback to sharing sheet")
//                    self.shareCapturedImage(capturedImage)
//                }
//            }
//        } else {
//            print("Instagram app not installed, fallback to sharing sheet")
//            self.shareCapturedImage(capturedImage)
//        }
//    }
    
    func shareCapturedImage(_ image: UIImage) {
        let newWidth: CGFloat = 1000
        let newHeight: CGFloat = 1800

        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))

        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        if let overlayImage = UIImage(named: "canyou") {
            // Draw the overlay image
            overlayImage.draw(in: CGRect(x: 55, y: 700, width: overlayImage.size.width-100, height: overlayImage.size.height-30))
        }

        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

        if let resizedImage = resizedImage {
            let activityViewController = UIActivityViewController(activityItems: [resizedImage], applicationActivities: nil)

            activityViewController.excludedActivityTypes = [.mail]

            if let topViewController = self.view?.window?.rootViewController {
                topViewController.present(activityViewController, animated: true, completion: nil)
            }
        }

        self.view?.isPaused = true
    }


    
    func captureSceneAsUIImage() -> UIImage? {
      guard let view = scene?.view else { return nil }
      
      let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
      let image = renderer.image { context in
          view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
      }
      return image
    }

    
    override func update(_ currentTime: TimeInterval) {
        createTrail()
        
        if isLoaded{
            if bg2!.position.y < originalPositionBG1!.y && isBGinverted == false{
                bg?.position = originalPositionBG2!
                let i = Int.random(in: 2...5)
                bg?.texture = SKTexture(imageNamed: "long-bg-\(i)")
                isBGinverted = true
            }else if bg!.position.y < originalPositionBG1!.y && isBGinverted == true{
                bg2?.position = originalPositionBG2!
                
                let i = Int.random(in: 2...5)
                bg2?.texture = SKTexture(imageNamed: "long-bg-\(i)")
                
                isBGinverted = false
            }
        }
        
        engine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }

        // If something goes wrong, attempt to restart the engine immediately
        engine?.resetHandler = { [weak self] in
            print("The engine reset")

            do {
                try self?.engine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
        
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
