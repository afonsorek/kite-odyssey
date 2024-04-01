//
//  DeathScene.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 25/03/24.
//

import Foundation
import SpriteKit

class DeathScene: SKNode{
    init(father: SKScene, score: Int){
        super.init()

        let filter = SKSpriteNode(color: UIColor(ciColor: CIColor(red: 0, green: 0, blue: 0, alpha: 0.2)), size: father.size)
        filter.zPosition = 20
        self.addChild(filter)
        
        let banner = SKSpriteNode(imageNamed: "banner")
        banner.name = "banner"
        banner.zPosition = 21
        banner.setScale(0.6)
        let text = SKLabelNode(text: "\(score) m")
        text.fontSize = 200
        text.fontName = "Livvic-Black"
        text.position.y -= 45
        text.zPosition = 22
        
        let restart:SKSpriteNode = SKSpriteNode(imageNamed: "restart")
        restart.name = "restart"
        restart.setScale(0.65)
        restart.zPosition = 21
        
        banner.position.y = (father.size.height/2)-200
        father.addChild(banner)
        banner.addChild(text)
        father.addChild(restart)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
