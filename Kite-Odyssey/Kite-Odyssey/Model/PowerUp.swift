//
//  PowerUp.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 26/03/24.
//

import Foundation
import SpriteKit

class PowerUp{
    var node = SKSpriteNode(imageNamed: "powerUp")
    
    func setBody(){
        let randomNumber = arc4random_uniform(2)
        let x: CGFloat = randomNumber == 0 ? 1 : -1
        
        node.setScale(0.2)
        
        node.position = CGPoint(x: (CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width/2))) * x), y: UIScreen.main.bounds.maxY - 112)
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.frame.width * 0.2, height: node.frame.height * 0.2))
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.contactTestBitMask = (node.physicsBody!.collisionBitMask)
    }
}
