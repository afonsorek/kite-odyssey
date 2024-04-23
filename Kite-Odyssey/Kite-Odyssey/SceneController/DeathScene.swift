//
//  DeathScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 25/03/24.
//

import Foundation
import SpriteKit
import SwiftUI

class DeathScene: ObservableObject{
    var child = SKSpriteNode()
    var isSecondChance: Bool
    @Published var score = 0
    init(father: SKScene, score: Int, isSecondChance: Bool){
        
        self.score = score
        self.isSecondChance = isSecondChance

        let filter = SKSpriteNode(color: UIColor(ciColor: CIColor(red: 0, green: 0, blue: 0, alpha: 0.35)), size: father.size)
        filter.zPosition = 20
        
        let banner = SKSpriteNode(imageNamed: "banner")
        banner.name = "banner"
        banner.zPosition = 21
        banner.setScale(1.5)
        
        let score = SKLabelNode(text: "\(self.score)")
        score.fontSize = 80
        score.name = "score"
        score.fontName = "BricolageGrotesque-Medium"
        score.position.y = -15
        score.zPosition = 22
        score.fontColor = UIColor(.orangeScore)
        
        let text = SKLabelNode(text: "meters")
        text.fontSize = 18
        text.fontName = "Montserrat-Regular"
        text.position.y = -40
        text.zPosition = 22
        text.fontColor = UIColor(.orangeScore)
        
        let continueButton:SKSpriteNode = SKSpriteNode(imageNamed: "continue")
        continueButton.name = isSecondChance ? "rip" : "continue"
        continueButton.alpha = isSecondChance ? 0.5 : 1.0
        continueButton.setScale(0.6)
        continueButton.zPosition = 21
        continueButton.position = CGPoint(x: 0, y: -360)
        
        let instagram:SKSpriteNode = SKSpriteNode(imageNamed: "instagram")
        instagram.setScale(0.7)
        instagram.name = "instagram"
        instagram.zPosition = 21
        instagram.position = CGPoint(x: 0, y: -420)
        
        let restart:SKSpriteNode = SKSpriteNode(imageNamed: "restart")
        restart.name = "restart"
        restart.setScale(0.85)
        restart.zPosition = 21
        restart.position = CGPoint(x: -120, y: -300)
        
        let home:SKSpriteNode = SKSpriteNode(imageNamed: "home")
        home.name = "home"
        home.setScale(0.85)
        home.zPosition = 21
        home.position = CGPoint(x: 120, y: -300)
        
        banner.position.y = (father.size.height/2)-300
        
        self.child.addChild(filter)
        self.child.addChild(banner)
        banner.addChild(score)
        banner.addChild(text)
        self.child.addChild(restart)
        self.child.addChild(home)
        banner.addChild(continueButton)
        self.child.addChild(instagram)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
