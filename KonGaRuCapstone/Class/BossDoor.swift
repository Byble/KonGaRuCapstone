//
//  BossDoor.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 23/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

class BossDoor: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.setup()
        }
    }
    
    func setup(){
        self.color = SKColor.clear
        physicsBody = SKPhysicsBody(rectangleOf: self.size)
        physicsBody?.categoryBitMask = PhysicsCategory.BossDoor
        physicsBody?.contactTestBitMask = PhysicsCategory.Player
        physicsBody?.restitution = 0.0
        physicsBody?.friction = 0
        physicsBody?.isDynamic = false
    }
}
