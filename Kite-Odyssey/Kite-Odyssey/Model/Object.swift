//
//  Object.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 21/03/24.
//

import Foundation
import SpriteKit

class Object: SKNode {
    
    init(image: SKSpriteNode, name: String){
        super.init()
        //        determine which side of the axis rain fall will spawn
        let randomNumber = arc4random_uniform(2)
        let x: CGFloat = randomNumber == 0 ? 1 : -1
        
        //        set the starting position of the node
        self.position = CGPoint(x: (CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width/2))) * x), y: UIScreen.main.bounds.maxY - 112)
        //    set the size of the node
        
        //        apply a physixs body to the node
        self.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: name), size: CGSize(width: image.size.width, height: image.size.height))

        self.physicsBody?.contactTestBitMask = (self.physicsBody!.collisionBitMask)

        self.physicsBody?.usesPreciseCollisionDetection = true

        self.physicsBody?.allowsRotation = true
        self.physicsBody?.isDynamic = true
        self.physicsBody?.angularVelocity = 5.0
        
        //    add image to the object
        self.addChild(image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
