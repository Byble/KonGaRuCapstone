//
//  Teleport.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 23/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

class Teleport: SKSpriteNode {
    
    let portalT = SKTexture(imageNamed: "portal.png")
    
    init(pos: CGPoint) {        
        super.init(texture: portalT, color: NSColor.clear, size: portalT.size())
        self.setup(pos: pos)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(pos: CGPoint){
        self.position = pos
        physicsBody = SKPhysicsBody(rectangleOf: self.size)
        physicsBody?.categoryBitMask = PhysicsCategory.Teleport
        physicsBody?.contactTestBitMask = PhysicsCategory.Player
        physicsBody?.restitution = 0.0
        physicsBody?.friction = 1
        physicsBody?.isDynamic = false
    }
}
