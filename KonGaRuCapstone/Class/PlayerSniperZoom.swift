//
//  PlayerSniperZoom.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 19/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit
class PlayerSniperZoom: SKSpriteNode {

    let sizeT = CGSize(width: 300, height: 300)
    let aimT = SKTexture(imageNamed: "humanAim.png")
    
    init() {
        super.init(texture: aimT, color: SKColor.clear, size: aimT.size())
        Setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func Setup(){
        self.color = .clear
        self.colorBlendFactor = 0
        self.name = "zoom"
        self.zPosition = 0
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.position = CGPoint(x: 0, y: 0)
        self.physicsBody = SKPhysicsBody(rectangleOf: aimT.size())
        self.physicsBody?.categoryBitMask = PhysicsCategory.Zoom
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.Bat
        self.physicsBody?.affectedByGravity = false
    }
    func Reset(){
        self.color = .clear
        self.colorBlendFactor = 0
    }
    func getXPos() -> CGFloat{
        return self.position.x
    }
    func getYPos() -> CGFloat{
        return self.position.y
    }
    func getWidth() -> CGFloat{
        return self.frame.width
    }
    func getHeight() -> CGFloat{
        return self.frame.height
    }
    func Shot(){
        let shotBall = SniperShot(zSize: self.size)        
        shotBall.Setup()
        self.addChild(shotBall)
    }
    func OnEnemy(){
        self.run(SKAction.colorize(with: .red, colorBlendFactor: 0.6, duration: 0))
    }
    func OutEnemy(){
        self.run(SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0))
    }
    func ShotFinish(){
        OutEnemy()
    }
}
