//
//  BatHowl.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 21/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

class BatHowl: SKSpriteNode {
    
    let howlT = SKTexture(imageNamed: "bat_effect_howl.png")
    
    init(pos: CGPoint) {
        super.init(texture: howlT, color: SKColor.clear, size: howlT.size())
        self.position = pos
        Setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func Setup(){
        self.name = "howl"
        self.zPosition = 1
        Surround()
    }
    func Surround(){
        let scal = SKAction.scale(by: 100, duration: 1)
        scal.timingMode = .easeIn
        run(scal) {
            self.removeFromParent()
        }
    }
}
