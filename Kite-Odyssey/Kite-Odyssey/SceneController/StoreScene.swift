//
//  storeScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 05/04/24.
//

import SpriteKit
import GameplayKit
import GameKit
import CoreHaptics

class StoreScene: SKScene{
    var button: SKSpriteNode?
    var layer: SKSpriteNode?
    let top = UIScreen.main.bounds.height/2-UIScreen.main.bounds.height*0.15
    let spacing = UIScreen.main.bounds.height*0.1
    let generator = UINotificationFeedbackGenerator()
    
    override func didMove(to view: SKView) {
        self.size = UIScreen.main.bounds.size
        self.button = self.childNode(withName: "home") as? SKSpriteNode
        button?.setScale(0.8)
        self.layer = self.childNode(withName: "layer") as? SKSpriteNode
        
        self.button?.texture = SKTexture(imageNamed: "button-selected")
        
        self.layer?.size.width = UIScreen.main.bounds.width*0.85
        self.layer?.size.height = UIScreen.main.bounds.height*0.75
        self.layer?.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        self.layer?.position = CGPoint(x: 0, y: Int(top+spacing/2*1.2))
        
        self.buildCards()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else {
            return
        }
        
        for touch in touches{
            generator.notificationOccurred(.success)
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            
            if touchedNode.name == "button"{
                touchedNode.run(SKAction.scale(to: 1.0, duration: 0.3))
            }
            
            if touchedNode.name != nil{
                if touchedNode.name != UserDefaults.standard.object(forKey: "kiteSkin") as? String{
                    if touchedNode.name! != "home" && touchedNode.name! != "layer" {
                        //if currentAdsWatched //CRIAR MÉTODO NO SKINS MODEL PARA RETORNAR O ID DE ADS DA PIPA
                        UserDefaults.standard.set(touchedNode.name, forKey: "kiteSkin")
                        self.buildCards()
                    }
                }
            }
            
            if touchedNode.name == "layer"{
                if let scene = SKScene(fileNamed: "MenuScene") {
                    self.removeAllActions()
                    self.removeAllChildren()
                    scene.scaleMode = .aspectFill
                    self.view?.presentScene(scene)
                }
                
                self.view?.ignoresSiblingOrder = true
            }
            
            if touchedNode.name == "home"{
                self.button?.run(SKAction.sequence([
                    SKAction.scale(to: 0.7, duration: 0.2),
                  SKAction.wait(forDuration: 0.2),
                  SKAction.scale(to: 0.6, duration: 0.2),
                  SKAction.run {
                      if let scene = SKScene(fileNamed: "MenuScene") {
                          self.removeAllActions()
                          self.removeAllChildren()
                          scene.scaleMode = .aspectFill
                          self.view?.presentScene(scene)
                      }
                      
                      self.view?.ignoresSiblingOrder = true
                  }
                ]))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else {
            return
        }
        
        for touch in touches{
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "button"{
                touchedNode.run(SKAction.scale(to: 0.8, duration: 0.3))
            }
        }
    }
    
    func buildCards(){
        let minX = Int(self.layer!.frame.minX) + Int(UIScreen.main.bounds.width*0.043)
        let midX = Int(self.layer!.frame.midX) - Int(UIScreen.main.bounds.width*0.228)/2
        let maxX = Int(self.layer!.frame.maxX) - Int(UIScreen.main.bounds.width*0.271)
        
        let maxY = Int(self.layer!.frame.maxY) - Int(UIScreen.main.bounds.height*0.237)
        let midY = Int(self.layer!.frame.midY) - Int(UIScreen.main.bounds.height*0.178)/2
        let minY = Int(self.layer!.frame.minY) + Int(UIScreen.main.bounds.height*0.055)
        
        let positionsX:[Int] = [minX, midX, maxX]
        let positionsY:[Int] = [maxY, midY, minY]
        
        for kite in SkinsModel.shared.skins{
            self.childNode(withName: kite.name)?.removeFromParent()
        }
        
        for kite in SkinsModel.shared.skins{
            let card = SKShapeNode(rect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width*0.228, height: UIScreen.main.bounds.height*0.178), cornerRadius: 6)
            
            card.position = CGPoint(x: positionsX[kite.index-1], y: positionsY[kite.row-1])
            card.zPosition = 100
            card.strokeColor = .clear
            
            let kiteSkin = SKSpriteNode(imageNamed: kite.name)
            kiteSkin.setScale(0.25)
            kiteSkin.position.x = card.frame.width/2
            kiteSkin.position.y = card.frame.height/2
            kiteSkin.zPosition = 200
            kiteSkin.name = kite.name
            
            kiteSkin.isUserInteractionEnabled = false
            
            let equip = SKSpriteNode()
            equip.texture = SKTexture(imageNamed: "equip")
            equip.size = equip.texture?.size() ?? CGSize(width: 100, height: 100)
            equip.setScale(0.25)
            equip.position.x = card.frame.width/2
            equip.position.y = card.frame.height*0.15
            equip.name = kite.name
            
            let shadow = SKShapeNode(rect: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width*0.228, height: UIScreen.main.bounds.height*0.178), cornerRadius: 6)
            shadow.fillColor = .black
            shadow.alpha = 0.25
            shadow.name = "shadow"
            shadow.position = CGPoint(x: 0, y: -3)
            shadow.zPosition = -1
            
            let blurNode = SKEffectNode()
            let blurFilter = CIFilter(name: "CIGaussianBlur")!
            blurFilter.setValue(4.0, forKey: "inputRadius")
            blurNode.filter = blurFilter
            blurNode.addChild(shadow)
            blurNode.position = shadow.position
            blurNode.zPosition = shadow.zPosition
            
            let name = SKLabelNode(text: kite.display)
            name.fontName = "Montserrat-Regular"
            name.fontColor = UIColor(named: "deep-blue") ?? .white
            name.position.x = card.frame.width/2
            name.position.y = card.frame.height*0.8
            name.fontSize = 12
            
            card.addChild(kiteSkin)
            card.addChild(name)
            card.addChild(equip)
            
            card.name = kite.name
            
            if card.name == UserDefaults.standard.object(forKey: "kiteSkin") as? String{
                card.fillColor = UIColor(named: "baby-blue") ?? .white
                card.addChild(blurNode)
                equip.texture = SKTexture(imageNamed: "equiped")
            }else{
                card.fillColor = UIColor(named: "card-color") ?? .white
                card.childNode(withName: "shadow")?.removeFromParent()
            }
            self.addChild(card)
        }
        
    }
}
