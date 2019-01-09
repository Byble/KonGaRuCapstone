//
//  EdgeWall.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 23/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

class EdgeWall: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.setup()
        }
    }
    
    func setup(){
        self.color = NSColor.clear
        physicsBody = SKPhysicsBody(rectangleOf: self.size)
        physicsBody?.categoryBitMask = PhysicsCategory.EdgeWall
        physicsBody?.collisionBitMask = PhysicsCategory.CameraEdge
        physicsBody?.contactTestBitMask = PhysicsCategory.CameraEdge
        physicsBody?.restitution = 0.0
        physicsBody?.friction = 1
        physicsBody?.isDynamic = false
    }
}
