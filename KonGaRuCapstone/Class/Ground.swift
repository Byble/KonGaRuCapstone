//
//  Ground.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 2018. 9. 20..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

class Ground: SKSpriteNode {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.setup()
        }
    }
    
    func setup(){
        self.color = NSColor.clear
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height))
        physicsBody?.categoryBitMask = PhysicsCategory.Ground
        physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.Player
        physicsBody?.restitution = 0.0
        physicsBody?.friction = 1
        physicsBody?.isDynamic = false
    }
}
