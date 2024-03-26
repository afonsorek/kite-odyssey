//
//  Kite.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 25/03/24.
//

import Foundation
import SpriteKit

class Kite{
    var child: SKNode?
    
    init(child: SKNode){
        self.child = child
    }
    
    func setBody(){
        child!.physicsBody = SKPhysicsBody(rectangleOf: child!.frame.size)
        child!.physicsBody?.velocity = CGVector(dx: 0, dy: 600)
        child!.physicsBody?.allowsRotation = true
        child!.physicsBody?.contactTestBitMask = (child!.physicsBody!.collisionBitMask)
    }
    
    func applyForce(velocity: CGVector, translation: CGPoint){
        child!.run(SKAction.rotate(toAngle: 0, duration: 0.07))
        child!.physicsBody?.linearDamping = 1.0
        child!.physicsBody?.applyAngularImpulse(-(translation.x/500))
        child!.physicsBody?.velocity = velocity
    }
}
