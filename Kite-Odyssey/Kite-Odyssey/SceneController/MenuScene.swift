//
//  MenuScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 21/03/24.
//


import SpriteKit
import GameplayKit
import SwiftUI

class MenuScene: SKScene, SKPhysicsContactDelegate{
    private var button: SKSpriteNode?
    private var bestScore: SKLabelNode?
    private var transition:SKTransition = SKTransition.fade(withDuration: 0.5)
    
    private let positions:[CGFloat] = [-400, -330, -260]
    private let opacity = [0.25, 0.55, 1.0]
    private var count = 0
    
    private var cooldown = 0.7
    
    override func didMove(to view: SKView) {
        self.button = self.childNode(withName: "button") as? SKSpriteNode
        self.bestScore = self.childNode(withName: "bestScore") as? SKLabelNode
        self.bestScore?.fontName = "Montserrat-Regular"
        
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
        
        let swipeUp : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(MenuScene.swipeUp))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
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
    
    @objc func swipeUp(sender: UISwipeGestureRecognizer){
        if let scene = SKScene(fileNamed: "GameScene") {
            scene.scaleMode = .aspectFill
            
            self.view?.presentScene(scene, transition: .crossFade(withDuration: 0.3))
        }
        
        self.view?.ignoresSiblingOrder = true
        
        self.view?.showsFPS = true
        self.view?.showsNodeCount = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         for touch in touches {
              let location = touch.location(in: self)
              let touchedNode = atPoint(location)
              
              if touchedNode.name == "button" {
                  
              }
         }
    }
    
}

