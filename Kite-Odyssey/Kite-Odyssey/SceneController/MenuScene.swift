//
//  MenuScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 21/03/24.
//


import SpriteKit
import GameplayKit
import GameKit

class MenuScene: SKScene, SKPhysicsContactDelegate{
    var gameKitHelper = GameKitHelper()
    
    private var button: SKSpriteNode?
    private var bg: SKSpriteNode?
    private var bestScore: SKLabelNode?
    private var logo: SKSpriteNode?
    
    
    private let positions:[CGFloat] = [-400, -330, -260]
    private let opacity = [0.25, 0.55, 1.0]
    private var count = 0
    
    let device = UIDevice.current.userInterfaceIdiom
    
    private var cooldown = 0.7
    
    let minSwipeSpeed = 200.0
    var lastTouchPosition = CGPoint()
    var lastTouchTime = TimeInterval()
    var screenTouch = false
    var swipingUp = false
    
    override func didMove(to view: SKView) {
        if device == .pad{
            self.size = UIScreen.main.bounds.size
        }
        
        
        UserDefaults.standard.set("kite-standart", forKey: "kiteSkin")
        
        GKAccessPoint.shared.location = .bottomLeading
        GKAccessPoint.shared.isActive = true
        
        _ = Kite(child: self.childNode(withName: "kite-menu")! as! SKSpriteNode)
        
        self.button = self.childNode(withName: "button") as? SKSpriteNode
        self.bestScore = self.childNode(withName: "bestScore") as? SKLabelNode
        self.bestScore?.fontName = "Montserrat-Regular"
        
        if device == .pad{
            self.logo?.anchorPoint.y = 1.0
            self.logo?.size.width = self.frame.size.width*0.6
            self.logo?.size.height = self.frame.size.height*0.25
            self.logo?.position.x = 0
        }
        
        self.logo = self.childNode(withName: "logo-menu") as? SKSpriteNode
        self.logo?.position.y = (self.frame.size.height/2)-100
        
        self.bg = self.childNode(withName: "long-bg") as? SKSpriteNode
        
        if device == .pad{
            bg?.position.y = -(self.size.height/2)
            bg?.size.width = self.frame.size.width
            bg?.texture = SKTexture(imageNamed: "long-bg-ipad")
        }
        
        self.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run {
            if self.count == 3{
                self.remove()
                self.count = 0
            }else if self.count == 2{
                self.cooldown = 4.0
            }
            
            let swipeLabel = SKLabelNode(text: "swipe up to start")
            swipeLabel.fontName = "Montserrat-Regular"
            swipeLabel.name = "swipeLabel"
            swipeLabel.fontSize = 48
            swipeLabel.alpha = 0.0
            self.addChild(swipeLabel)
            
            swipeLabel.run(SKAction.fadeAlpha(to: self.opacity[self.count], duration: 0.5))
            swipeLabel.position.y = self.positions[self.count]
            self.count += 1
            
            }, SKAction.wait(forDuration: self.cooldown)])))
        
        if let record = UserDefaults.standard.object(forKey: "bestScore") as? Int {
            self.bestScore?.text = "\(record)"
            self.bestScore?.fontSize = 28
        }
        self.button?.name = "button"
        

    }

    func remove(){
        for i in self.children{
            if i.name == "swipeLabel"{
                i.run(SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.0, duration: 0.5),
                    SKAction.wait(forDuration: 3.0),
                    SKAction.run {
                        i.removeFromParent()
                    }
                ]))
                
            }
        }
        self.cooldown = 0.5
    }
    
    private func checkSwipeUp(newPosition : CGPoint, newTime: TimeInterval) -> Bool {
        let dy = newPosition.y - lastTouchPosition.y
        let dt = CGFloat(newTime-lastTouchTime)
        let speed = dy/dt
        
        let newSwipe = (speed > minSwipeSpeed) && !swipingUp
        if (newSwipe) {
            swipingUp = true
        }
        
        return newSwipe
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else {
            return
        }
        
        screenTouch = false
        swipingUp = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else {
            return
        }
        
        let newTouchPosition = (touches.first?.location(in: self))!
        let newTouchTime = event!.timestamp
        if (checkSwipeUp(newPosition: newTouchPosition, newTime: newTouchTime)) {
            if let scene = SKScene(fileNamed: "GameScene") {
                self.removeAllActions()
                self.removeAllChildren()
                scene.scaleMode = .aspectFill
                self.view?.presentScene(scene)
            }
            
            self.view?.ignoresSiblingOrder = true
        }
        lastTouchPosition = newTouchPosition
        lastTouchTime = newTouchTime
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else {
            return
        }
        
        screenTouch = true
        lastTouchPosition = (touches.first?.location(in: self))!
        lastTouchTime = event!.timestamp
        
         for touch in touches {
              let location = touch.location(in: self)
              let touchedNode = atPoint(location)
              
              if touchedNode.name == "button" {
                  self.button?.run(SKAction.sequence([
                    SKAction.scale(to: 1.1, duration: 0.2),
                    SKAction.wait(forDuration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.2)
                  ]))
                  let alert = UIAlertController(title: "Kite skins", message: "Coming soon", preferredStyle: UIAlertController.Style.alert)
                  alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: .none))
                  self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
              }
         }
    }
    
}

