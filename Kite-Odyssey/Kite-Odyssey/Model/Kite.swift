//
//  Kite.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 25/03/24.
//

import Foundation
import SpriteKit
import CoreHaptics

class Kite{
    var child: SKSpriteNode?
    var engine: CHHapticEngine?
    
    init(child: SKSpriteNode){
        self.child = child
        self.loadTexture()
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func loadTexture(){
        let skin = UserDefaults.standard.object(forKey: "kiteSkin")
        if skin != nil{
            child!.texture = SKTexture(imageNamed: skin as! String)
            child?.size = (child?.texture?.size())!
            child?.setScale(0.03)
        }else{
            child!.texture = SKTexture(imageNamed: "kite-blue")
            child?.size = (child?.texture?.size())!
            child?.setScale(0.03)
        }
    }
    
    func resetBody(){
        child!.physicsBody = SKPhysicsBody(rectangleOf: child!.frame.size)
        child!.physicsBody?.allowsRotation = true
        child?.physicsBody?.isDynamic = true
        child?.physicsBody?.affectedByGravity = true
        child!.physicsBody?.contactTestBitMask = (child!.physicsBody!.collisionBitMask)
    }
    
    func die(){
        child!.run(SKAction.scale(to: 0, duration: 2))
    }
    
    func setBody(){
        child!.physicsBody = SKPhysicsBody(rectangleOf: child!.frame.size)
        child!.physicsBody?.velocity = CGVector(dx: 0, dy: 200)
        child!.physicsBody?.allowsRotation = true
        child?.physicsBody?.isDynamic = true
        child?.physicsBody?.affectedByGravity = true
        child!.physicsBody?.contactTestBitMask = (child!.physicsBody!.collisionBitMask)
    }
    
    func applyForce(velocity: CGVector, translation: CGPoint){
        child!.run(SKAction.rotate(toAngle: 0, duration: 0.07))
        child?.physicsBody?.angularDamping = 0
        child!.physicsBody?.linearDamping = 1.0
        child!.physicsBody?.applyAngularImpulse(-(translation.x/3000))
        child!.physicsBody?.velocity = velocity
    }
    
    func powerUp(screen: CGRect){
        child?.run(SKAction.sequence([
            SKAction.run {
                self.child!.physicsBody?.isDynamic = false
                self.child!.name = "ABUBLE"
                self.child!.zPosition = 100
                self.child!.zRotation = 0
            },
            SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.7),
        ]))
        
        child?.run(SKAction.sequence([SKAction.repeat(SKAction.sequence([
            SKAction.move(by: CGVector(dx: 5, dy: 0), duration: 0.2),
            SKAction.move(by: CGVector(dx: -10, dy: 0), duration: 0.2),
            SKAction.move(by: CGVector(dx: 5, dy: 0), duration: 0.2),
        ]), count: 6), SKAction.run {
            self.child!.name = "kite"
            self.resetBody()
        }]))
        
    }
}
