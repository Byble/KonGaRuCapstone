//
//  PlayerAttack.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 18/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

enum WeaponType {
    case sword
    case gun
    case none
}
enum Turn {
    case first
    case second
    case third
    case none
}
enum PlayerType {
    case human
    case cat
}
class PlayerAttack: SKSpriteNode {
    
    private let effectT = SKTexture(imageNamed: "humanBullet.png")
    private var animAtlas = SKTextureAtlas()
    private var animArray = [SKTexture]()
    
    var type: WeaponType
    var turnN: Turn
    
    var swordSize = CGSize(width: 200, height: 130)
    
    var timer = Timer()
    
    var removeTime: TimeInterval = 0
    var pXScale: CGFloat = 0
    
    init(wType: WeaponType, turn: Turn, playerPos: CGPoint, xScale: CGFloat) {
        pXScale = xScale
        
        switch turn {
        case .first:
            turnN = Turn.first
        case .second:
            turnN = Turn.second
        case .third:
            turnN = Turn.third
        case .none:
            turnN = Turn.none
        }
        switch wType {
        case .gun:
            type = WeaponType.gun
            super.init(texture: effectT, color: SKColor.clear, size: CGSize(width: effectT.size().width*4, height: effectT.size().height*4))
            self.position = CGPoint(x: playerPos.x-40, y: playerPos.y)
            removeTime = 0.7
            Setup()
        case .sword:
            type = WeaponType.sword
            super.init(texture: nil, color: SKColor.clear, size: swordSize)
            self.position = CGPoint(x: -50, y: 0)
            removeTime = 0.6
            Setup()
        case .none:
            type = WeaponType.none
            super.init(texture: nil, color: SKColor.white, size: CGSize(width: 0, height: 0))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        type = WeaponType.none
        turnN = Turn.none
        super.init(coder: aDecoder)
    }
    
    func Setup(){
        self.name = "attack"
        if type == .sword{
            physicsBody = SKPhysicsBody(rectangleOf: swordSize)
            Anim(type: .cat, state: turnN, isRepeat: false) {
                
            }
        }else{
            physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: effectT.size().width*10, height: effectT.size().height*20))
        }
//
        physicsBody?.friction = 1
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 0.0
        physicsBody?.categoryBitMask = PhysicsCategory.PlayerAttack
        physicsBody?.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.Bat
        physicsBody?.collisionBitMask = PhysicsCategory.None
        physicsBody?.usesPreciseCollisionDetection = true

        if type == .gun{
            Shot()
        }
        RemoveSelfTimer()
    }
    
    func Shot(){
        if pXScale > 0{
            self.physicsBody?.velocity = CGVector(dx: -1500, dy: (self.physicsBody?.velocity.dy)!)
        }else{
            self.physicsBody?.velocity = CGVector(dx: 1500, dy: (self.physicsBody?.velocity.dy)!)
        }
    }
    
    func RemoveSelfTimer(){
        timer = Timer.scheduledTimer(timeInterval: removeTime, target: self, selector: #selector(RemoveSelf), userInfo: nil, repeats: false)
    }
    
    @objc func RemoveSelf(){
        self.removeFromParent()
    }
    
    private func Anim(type: PlayerType, state: Turn, isRepeat: Bool, completion: @escaping () -> ()){
        animArray.removeAll()
        
        animAtlas = SKTextureAtlas(named: "\(type)AttackEffect\(state)")
        for i in 1...animAtlas.textureNames.count{
            let FName = "\(type)AttackEffect\(state)_\(i).png"
            animArray.append(SKTexture(imageNamed: FName))
        }
        switch state {
        case .first:
            self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.15), withKey: "First") {
                completion()
            }
        case .second:
            self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.15), withKey: "Second") {
                completion()
            }
        case .third:
            self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.13), withKey: "Third") {
                completion()
            }
        case .none:
            completion()
        }
    }
}
