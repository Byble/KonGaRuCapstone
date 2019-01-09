//
//  SniperShot.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 19/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

class SniperShot: SKSpriteNode {
    var zSizeA: CGSize
    
    init(zSize: CGSize) {
        zSizeA = zSize
        super.init(texture: nil, color: NSColor.clear, size: zSize)
    }
    required init?(coder aDecoder: NSCoder) {
        zSizeA = CGSize(width: 0, height: 0)
        super.init(coder: aDecoder)
    }
    func Setup(){        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint(x: 0, y: 0)
        self.physicsBody = SKPhysicsBody(rectangleOf: zSizeA)
        self.physicsBody?.categoryBitMask = PhysicsCategory.ZoomShot
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.Bat
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        self.physicsBody?.affectedByGravity = false
        
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in self?.removeFromParent()}
            ]))
    }
}
