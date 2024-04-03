//
//  GameViewController.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 20/03/24.
//

import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController, GameCenterHelperDelegate {
    func didChangeAuthStatus(isAuthenticated: Bool) {
        
    }
    
    func presentGameCenterAuth(viewController: UIViewController?) {
        
    }
    

    var gameKitHelper: GameKitHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameKitHelper = GameKitHelper()
        gameKitHelper.delegate = self
        gameKitHelper.authenticatePlayer()
                
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }

    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
