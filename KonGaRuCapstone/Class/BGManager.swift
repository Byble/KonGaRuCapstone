//
//  BGManager.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 24/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

struct BGList {
    static let MainBG = ""
    static let TownBG = "Town.mp3"
    static let DungeonBG = "Dungeon.mp3"
    static let BossBG = "Boss.mp3"
    static let DeadBG = ""
    static let EndingBG = ""
}

class BGManager {
    static let shared = BGManager()
    var backgroundSound: SKAudioNode!
    
    func SetBG(bgName: String, loop: Bool, scene: SKScene){
        if backgroundSound != nil{
            backgroundSound.removeFromParent()
            backgroundSound = nil
        }
        let bg = SKAudioNode(fileNamed: bgName)
        
        if loop{
            bg.autoplayLooped = true
        }else{
            bg.autoplayLooped = false
        }
        backgroundSound = bg
        scene.addChild(bg)
    }
    func CurrentBG() -> SKAudioNode{
        return backgroundSound
    }
}
