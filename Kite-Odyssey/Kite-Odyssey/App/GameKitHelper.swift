//
//  GameKitHelper.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 02/04/24.
//

import Foundation
import GameKit

let singleton = GameKitHelper()

protocol GameCenterHelperDelegate: AnyObject{
    func didChangeAuthStatus(isAuthenticated: Bool)
    func presentGameCenterAuth(viewController: UIViewController?)
}

final class GameKitHelper: NSObject, GKGameCenterControllerDelegate, GKLocalPlayerListener{
    weak var delegate: (GameCenterHelperDelegate)?
    
    var isAuthenticated: Bool{
        return GKLocalPlayer.local.isAuthenticated
    }
    
    var authenticationViewController: UIViewController?
    var lastError: Error?
    var gameCenterEnabled: Bool
    
    override init() {
        gameCenterEnabled = true
        super.init()
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func authenticatePlayer(){
        GKLocalPlayer.local.authenticateHandler = {(gcAuthVC, error) in
            self.delegate?.didChangeAuthStatus(isAuthenticated: self.isAuthenticated)
            
            guard GKLocalPlayer.local.isAuthenticated else{
                self.delegate?.presentGameCenterAuth(viewController: gcAuthVC)
                return
            }
            
            GKLocalPlayer.local.register(self)
        }
    }
    
    func showLeader(view: UIViewController){
        if GKLocalPlayer.local.isAuthenticated{
            let localPlayer = GKLocalPlayer.local
            
            if localPlayer.isAuthenticated{
                let vc = view
                let gc = GKGameCenterViewController()
                gc.gameCenterDelegate = self
                vc.present(gc, animated: true, completion: nil)
            }
        }
    }
    
    class var sharedInstance: GameKitHelper{return singleton}
}
