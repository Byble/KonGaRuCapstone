//
//  BossCrystal.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 21/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

class BatCrystal: SKSpriteNode {
    
    let crystalT = SKTexture(imageNamed: "bat_effect_crystal.png")
    
    var bodySize = CGSize(width: 0, height: 0)
    init(pos: CGPoint) {
        let tmpRandSize = CGFloat.random(in: 0.5...1)
        bodySize = CGSize(width: crystalT.size().width*tmpRandSize, height: crystalT.size().height*tmpRandSize)
        
        super.init(texture: crystalT, color: SKColor.clear, size: bodySize)
        self.position.y = pos.y + 500
        self.position.x = CGFloat.random(in: pos.x-800...pos.x+800)
        self.name = "crystal"
        Setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func Setup(){
        
        self.run(SKAction.rotate(toAngle: RandomRadian(), duration: 0))
        let randomN = CGFloat.random(in: 0.5...0.8)
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: bodySize.width*0.4, height: bodySize.height*(randomN)/1.5), center: CGPoint(x: 0, y: bodySize.height*(randomN-0.2)-bodySize.height/2.5))
        
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.BatCrystal
        self.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.colorize(with: SKColor.clear, colorBlendFactor: 0.4, duration: 2),
            SKAction.wait(forDuration: 2),
            SKAction.run {
                self.removeFromParent()
            }
            ]))
    }
    func RandomRadian() -> CGFloat {
        let angle = CGFloat.random(in: -55...55)
        return angle * CGFloat.pi/180.0
    }
}
