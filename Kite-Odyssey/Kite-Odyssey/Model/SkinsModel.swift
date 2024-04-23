//
//  SkinsModel.swift
//  Kite-Odyssey
//
//  Created by Afonso Rekbaim on 16/04/24.
//

import Foundation

struct Skin{
    let id = UUID()
    let name: String
    let index: Int
    let row: Int
    let display: String
    var adsToUnlock: Int
    let adsID: String
}

class SkinsModel{
    static let shared = SkinsModel()
    var skins: [Skin]
    private init(){
        self.skins = [
            Skin(name: "kite-blue", index: 1, row: 1, display: "Anchor Ocean", adsToUnlock: 0, adsID: "AnchorOcean"),
            Skin(name: "Anchor Air", index: 2, row: 1, display: "Anchor Air", adsToUnlock: 0, adsID: "AnchorAir"),
            Skin(name: "Anchor Sun", index: 3, row: 1, display: "Anchor Sun", adsToUnlock: 0, adsID: "AnchorSun"),
            
            Skin(name: "kite-standart", index: 1, row: 2, display: "Bloom Fire", adsToUnlock: 10, adsID: "BloomFire"),
            Skin(name: "Bloom Algae", index: 2, row: 2, display: "Bloom Algae", adsToUnlock: 5, adsID: "BloomAlgae"),
            Skin(name: "Blooms", index: 3, row: 2, display: "Bloom 80's ", adsToUnlock: 0, adsID: "Blooms"),
            
            Skin(name: "Raia Fresh", index: 1, row: 3, display: "Bloom Fresh", adsToUnlock: 0, adsID: "RaiaFresh"),
            Skin(name: "Raia Deco", index: 2, row: 3, display: "Bloom Deco", adsToUnlock: 0, adsID: "RaiaDeco"),
            Skin(name: "Raia Tatto", index: 3, row: 3, display: "Bloom Tatto", adsToUnlock: 0, adsID: "RaiaTatto")
        ]
    }
}
