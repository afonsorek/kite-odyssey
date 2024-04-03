//
//  DeathScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 25/03/24.
//

import Foundation
import SpriteKit
import SwiftUI

class DeathScene: SKNode{
    init(father: SKScene, score: Int){
        super.init()

        let filter = SKSpriteNode(color: UIColor(ciColor: CIColor(red: 0, green: 0, blue: 0, alpha: 0.2)), size: father.size)
        filter.zPosition = 20
        self.addChild(filter)
        
        let banner = SKSpriteNode(imageNamed: "banner")
        banner.name = "banner"
        banner.zPosition = 21
        banner.setScale(1.5)
        
        let score = SKLabelNode(text: "\(score)")
        score.fontSize = 80
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
        continueButton.name = "continue"
        continueButton.setScale(0.6)
        continueButton.zPosition = 21
        continueButton.position = CGPoint(x: 0, y: -360)
        
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
        father.addChild(banner)
        banner.addChild(score)
        banner.addChild(text)
        father.addChild(restart)
        father.addChild(home)
        banner.addChild(continueButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
