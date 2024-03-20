//
//  GameScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 20/03/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var backgroundNodes: [SKShapeNode] = []
    private var playerScore: SKLabelNode?
    private var kite: SKShapeNode?
    
    private var lastUpdateTime: TimeInterval = 0
    private var backgroundSpeed: Double = 100.0
    private var score = 0
    
    override func sceneDidLoad() {
        lastUpdateTime = 0
        setUpBackground()
    }
    
    override func didMove(to view: SKView) {
        self.playerScore = self.childNode(withName: "//playerScore") as? SKLabelNode
        self.playerScore?.text = "\(score) m"
        
        self.playerScore?.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.score += 1
            self.playerScore?.text = "\(self.score) m"
        }, SKAction.wait(forDuration: 1)])))
        
        self.kite = SKShapeNode(rect: CGRect(x: 0, y: -200, width: 50, height: 50))
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    private func setUpBackground() {
        
        let yellowBackgroundTop = SKShapeNode(rectOf: CGSize(width: self.size.width, height: self.size.height/2))
        yellowBackgroundTop.position = CGPoint(x: self.frame.midX, y: 0.75*self.size.height)
        yellowBackgroundTop.zPosition = -15
        yellowBackgroundTop.strokeColor = .systemGray6
        yellowBackgroundTop.fillColor = .systemGray6
        
        let yellowBackgroundBottom = SKShapeNode(rectOf: CGSize(width: self.size.width, height: self.size.height/2))
        yellowBackgroundBottom.position = CGPoint(x: self.frame.midX, y: -0.25*self.size.height)
        yellowBackgroundBottom.zPosition = -15
        yellowBackgroundBottom.strokeColor = .systemGray6
        yellowBackgroundBottom.fillColor = .systemGray6
  
        
        let redBackgroundTop = SKShapeNode(rectOf: CGSize(width: self.size.width, height: self.size.height/2))
        redBackgroundTop.position = CGPoint(x: self.frame.midX, y:  0.25*self.size.height)
        redBackgroundTop.zPosition = -15
        redBackgroundTop.strokeColor = .systemGray3
        redBackgroundTop.fillColor = .systemGray3
        
        let redBackgroundBottom = SKShapeNode(rectOf: CGSize(width: self.size.width, height: self.size.height/2))
        redBackgroundBottom.position = CGPoint(x: self.frame.midX, y: -0.75*self.size.height)
        redBackgroundBottom.zPosition = -15
        redBackgroundBottom.strokeColor = .systemGray3
        redBackgroundBottom.fillColor = .systemGray3

        self.addChild(yellowBackgroundTop)
        self.addChild(yellowBackgroundBottom)
        self.addChild(redBackgroundTop)
        self.addChild(redBackgroundBottom)
        
        backgroundNodes.append(contentsOf: [yellowBackgroundTop, yellowBackgroundBottom, redBackgroundTop, redBackgroundBottom])
        
        //        let planoTop = SKSpriteNode(imageNamed: "planoTop")
        //        planoTop.size.width = self.size.width
        //        planoTop.size.height = self.size.height/2
        //        planoTop.position = CGPoint(x: self.frame.midX, y: 0.75*self.size.height)
        //        planoTop.zPosition = -15
        //
        //        let planoMid2 = SKSpriteNode(imageNamed: "planoMid2")
        //        planoMid2.size.width = self.size.width
        //        planoMid2.size.height = self.size.height/2
        //        planoMid2.position = CGPoint(x: self.frame.midX, y: -0.25*self.size.height)
        //        planoMid2.zPosition = -15
        //
        //
        //        let planoMid1 = SKSpriteNode(imageNamed: "planoMid1")
        //        planoMid1.size.width = self.size.width
        //        planoMid1.size.height = self.size.height/2
        //        planoMid1.position = CGPoint(x: self.frame.midX, y:  0.25*self.size.height)
        //        planoMid1.zPosition = -15
        //
        //        let planoBot = SKSpriteNode(imageNamed: "planoBot")
        //        planoBot.size.width = self.size.width
        //        planoBot.size.height = self.size.height/2
        //        planoBot.position = CGPoint(x: self.frame.midX, y: -0.75*self.size.height)
        //        planoBot.zPosition = -15
        //
        //
        //        self.addChild(planoTop)
        //        self.addChild(planoBot)
        //        self.addChild(planoMid1)
        //        self.addChild(planoMid2)
        //
        //        backgroundNodes.append(contentsOf: [planoTop, planoBot, planoMid1, planoMid2])
                
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
