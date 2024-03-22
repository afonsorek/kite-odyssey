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
    
    override func didMove(to view: SKView) {
        self.button = self.childNode(withName: "button") as? SKSpriteNode
        
        self.bestScore = self.childNode(withName: "bestScore") as? SKLabelNode
        self.bestScore?.fontName = "Livvic-Regular"
        
        
        if let record = UserDefaults.standard.object(forKey: "bestScore") as? Int {
            print(record)
            self.bestScore?.text = "SCORE \(record)"
            self.bestScore?.fontSize = 36
        }
        self.button?.name = "button"
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         for touch in touches {
              let location = touch.location(in: self)
              let touchedNode = atPoint(location)
              
              if touchedNode.name == "button" {
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
    
}

