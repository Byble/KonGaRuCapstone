//
//  MapEdge.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 21/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit
class MapEdge: SKSpriteNode {
    
    init(size: CGSize) {
        super.init(texture: nil, color: SKColor.clear, size: size)
        Setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Setup()
    }
    
    func Setup(){
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)        
//        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
//        self.physicsBody?.categoryBitMask = PhysicsCategory.MapEdge
//        self.physicsBody?.collisionBitMask = PhysicsCategory.CameraEdge
        self.position = CGPoint(x: 2790, y: 100)
    }
    func GetMinX() -> CGFloat{
        return self.frame.minX
    }
    func GetMaxX() -> CGFloat{
        return self.frame.maxX
    }
    func GetMinY() -> CGFloat{
        return self.frame.minY
    }
    func GetMaxY() -> CGFloat{
        return self.frame.maxY
    }
    func GetCenterX() -> CGFloat{
        return self.frame.midX
    }
    func GetCenterY() -> CGFloat{
        return self.frame.midY
    }
    func GetPosition() -> CGPoint{
        return self.position
    }
}
