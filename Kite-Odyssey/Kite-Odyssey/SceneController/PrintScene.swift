//
//  PrintScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 23/04/24.
//

import Foundation
import SpriteKit
import SwiftUI

class PrintScene: ObservableObject{
    var child = SKSpriteNode()
    @Published var score = 0
    init(father: SKScene, score: Int){
        self.score = score

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
        
        let text2 = SKLabelNode(text: "Can you beat my score?")
        text2.fontSize = 40
        text2.fontName = "Montserrat-Regular"
        text2.position.y = -80
        text2.zPosition = 22
        text2.fontColor = UIColor(.orangeScore)
        
        banner.position.y = 0
        
        self.child.addChild(filter)
        self.child.addChild(banner)
        self.child.addChild(text2)
        banner.addChild(score)
        banner.addChild(text)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
