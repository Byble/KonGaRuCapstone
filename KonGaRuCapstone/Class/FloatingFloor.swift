//
//  FloatingFloor.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 23/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

class FloatingFloor: SKSpriteNode {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.setup()
        }
    }
    
    func setup(){
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width*0.9, height: self.size.height*0.05), center: CGPoint(x: 0, y: 15))
        
        physicsBody?.categoryBitMask = PhysicsCategory.Ground
        physicsBody?.collisionBitMask = PhysicsCategory.Player | PhysicsCategory.Enemy
        physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Enemy
        physicsBody?.restitution = 0.0
        physicsBody?.friction = 0.8
        physicsBody?.isDynamic = false
    }
}
