//
//  PowerUp.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 26/03/24.
//

import Foundation
import SpriteKit

class PowerUp {
  var node = SKSpriteNode(imageNamed: "powerUp")

    func setBody() {
        let glowNode = SKShapeNode(circleOfRadius: node.size.width * 0.6)
        let effectNode = SKEffectNode()
        
        let randomNumber = arc4random_uniform(2)
        let x: CGFloat = randomNumber == 0 ? 1 : -1
        
        node.setScale(0.2)
        node.position = CGPoint(x: (CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width/2))) * x), y: UIScreen.main.bounds.maxY - 112)
        
        glowNode.fillColor = UIColor.yellow.withAlphaComponent(0.5)
        glowNode.zPosition = -1
        
        let blur = CIFilter(name: "CIGaussianBlur")!
        blur.setValue(50.0, forKey: kCIInputRadiusKey)

        // Create SKEffectNode and set filter
        effectNode.filter = blur
        effectNode.addChild(glowNode)
        
        // Add physics body to power-up node (adjust size)
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.frame.width * 0.2, height: node.frame.height * 0.2))
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.contactTestBitMask = (node.physicsBody!.collisionBitMask)
        
        node.addChild(effectNode)
        
        node.run(SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.run {
            self.node.removeFromParent()
        }]))
        
        node.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 0.15, duration: 0.3),
            SKAction.scale(to: 0.25, duration: 0.3)
        ])))
    }
}

