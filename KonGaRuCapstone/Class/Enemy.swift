//
//  Mole.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 18/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Foundation
import Cocoa
import SpriteKit

struct EnemyAction {
//    var idle = false
    var leftMove = false
    var rightMove = false
    var attack = false
    var hit = false
    var die = false
}
struct EnemyAnimCheck {
//    var idle = false
    var move = false
    var attack = false
    var hit = false
    var die = false
}
enum EnemyActionState: String{
//    case Idle = "Idle"
    case Die = "Die"
    case Move = "Move"
    case Attack = "Attack"
    case Hit = "Hit"
}
enum MoleState: UInt32{
    case leftMove
    case rightMove
//    case Idle
    private static let _count: MoleState.RawValue = {
        var maxValue: UInt32 = 0
        while let _ = MoleState(rawValue: maxValue){
            maxValue += 1
        }
        return maxValue
    }()
    static func randomMove() -> MoleState{
        let rand = arc4random_uniform(_count)
        return MoleState(rawValue: rand)!
    }
}

class Enemy: SKSpriteNode {
    private let moleT = SKTexture(imageNamed: "mole.png")
    private let snaleT = SKTexture(imageNamed: "snale.png")
    private let mudT = SKTexture(imageNamed: "mud.png")
    
    private var bodySize = CGSize()
    
    private var animAtlas = SKTextureAtlas()
    private var animArray = [SKTexture]()
    
    var enemyAction : EnemyAction
    var enemyAnim : EnemyAnimCheck
    
    var stateTimer = Timer()
    var stateSeconds = 6
    
    var moveSpeed = 100
    var limitMoveSpeed = 100
    
    var enemyType = EnemyType.none
    var spawnPosition: CGPoint = CGPoint(x: 0, y: 0)
    
    var hitTimer = Timer()
    var hitEffectTimer = Timer()
    var enemyHP: Int = 100
    
    var num = 0;
    
    init(type: EnemyType, position: CGPoint) {
        enemyType = type
        spawnPosition = position
        switch enemyType {
        case .mole:
            bodySize = CGSize(width: moleT.size().width, height: moleT.size().height)
        case .mud:
            bodySize = CGSize(width: mudT.size().width*1.5, height: mudT.size().height)
        case .snale:
            bodySize = CGSize(width: snaleT.size().width, height: snaleT.size().height)
        case .none:
            break
        }
        
        enemyAction = EnemyAction()
        enemyAnim = EnemyAnimCheck()
        switch enemyType {
        case .mole:
            super.init(texture: moleT, color: NSColor.clear, size: bodySize)
        case .mud:
            super.init(texture: mudT, color: NSColor.clear, size: bodySize)
        case .snale:
            super.init(texture: snaleT, color: NSColor.clear, size: bodySize)
        case .none:
            super.init()
        }
        
        Setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        enemyAction = EnemyAction()
        enemyAnim = EnemyAnimCheck()
        
        super.init(coder: aDecoder)
    }
    
    func Setup(){
        switch enemyType {
        case .mole:
            self.name = "mole"
            self.texture = moleT
            self.zPosition = 0
            position = spawnPosition
            
            let collSize = CGSize(width: moleT.size().width, height: moleT.size().height)
            physicsBody = SKPhysicsBody(rectangleOf: collSize, center: CGPoint(x: 0, y: moleT.size().height/5))
        case .mud:
            self.name = "mud"
            self.texture = mudT
            self.zPosition = 0
            position = spawnPosition
            
            let collSize = CGSize(width: mudT.size().width*2, height: mudT.size().height)
            physicsBody = SKPhysicsBody(rectangleOf: collSize, center: CGPoint(x: 0, y: mudT.size().height/5))
        case .snale:
            self.name = "snale"
            self.texture = snaleT
            self.zPosition = 0
            position = spawnPosition
            
            let collSize = CGSize(width: snaleT.size().width, height: snaleT.size().height)
            physicsBody = SKPhysicsBody(rectangleOf: collSize, center: CGPoint(x: 0, y: snaleT.size().height/5))
        case .none:
            break
        }
        self.name = "enemy"
        physicsBody?.friction = 1
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = true
        physicsBody?.restitution = 0.0
        
        physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.EdgeWall | PhysicsCategory.Wall
        physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerAttack | PhysicsCategory.GhostShot | PhysicsCategory.ZoomShot
        physicsBody?.usesPreciseCollisionDetection = true
        StateManager()
    }
    
    func LeftMove(){
        let nowMoveSpeed: CGFloat = abs((self.physicsBody?.velocity.dx)!)
        if Int(nowMoveSpeed) < limitMoveSpeed{
            if enemyAnim.move == false{
                self.enemyAnim.move = true
                self.Anim(state: .Move, isRepeat: true, completion: {})
            }
            if self.xScale < 0{
                self.xScale = 1
            }
            self.physicsBody?.velocity = CGVector(dx: -self.moveSpeed, dy: Int((self.physicsBody?.velocity.dy)!))
        }
    }
    func RightMove(){
        let nowMoveSpeed: CGFloat = abs((self.physicsBody?.velocity.dx)!)
        if Int(nowMoveSpeed) < limitMoveSpeed{
            if enemyAnim.move == false{
                self.enemyAnim.move = true
                self.Anim(state: .Move, isRepeat: true, completion: {})
            }
            if self.xScale > 0{
                self.xScale = -1
            }
            self.physicsBody?.velocity = CGVector(dx: self.moveSpeed, dy: Int((self.physicsBody?.velocity.dy)!))
        }
    }
    func CheckMove(){
        if !enemyAction.die{
            if enemyAction.leftMove{
                LeftMove()
            }
            else if enemyAction.rightMove{
                RightMove()
            }
        }
//        else if enemyAction.idle{
//            Idle()
//        }
    }
//    func Idle(){
//        if enemyAnim.idle == false{
//            self.enemyAnim.idle = true
//            self.Anim(state: .Idle, isRepeat: true, completion: {})
//        }
//    }
    func Attack(player: Player,completion: @escaping () -> ()){
        if player.position.x > self.position.x{
            if self.xScale > 0{
                self.xScale = self.xScale * -1
            }
        }else{
            if self.xScale < 0{
                self.xScale = abs(self.xScale)
            }
        }
        if enemyAnim.attack == false{
            stateSeconds = 6
            stateTimer.invalidate()
            ReleaseAction(forMove: false, forIdle: false, forAttack: true, forDie: false){
                self.enemyAnim.attack = true
                self.Anim(state: .Attack, isRepeat: false, completion: {})
                completion()
            }
        }
    }
    
    func ReleaseAction(forMove: Bool, forIdle: Bool, forAttack: Bool, forDie: Bool, completion: @escaping () -> ()){
        if forMove{
//            self.exitIdle()
            self.exitAttack()
            self.exitMove()
            completion()
        }
        else if forAttack{
//            self.exitIdle()
//            self.exitAttack()
            self.exitMove()
            completion()
        }
        else if forDie{
            self.exitAll()
            self.enemyAction.die = true
            self.physicsBody?.contactTestBitMask = PhysicsCategory.None
            completion()
        }
//        else if forIdle{
//            self.exitMove()
//            self.exitAttack()
//            self.exitHit()
//            completion()
//        }
    }
    func StateManager(){
        if !enemyAction.die{
            RunStateTimer()
            
            switch MoleState.randomMove() {
            case .leftMove:
                ReleaseAction(forMove: true, forIdle: false, forAttack: false, forDie: false) {
                    self.enemyAction.leftMove = true
                }
            case .rightMove:
                ReleaseAction(forMove: true, forIdle: false, forAttack: false, forDie: false) {
                    self.enemyAction.rightMove = true
                }
//            case .Idle:
//                ReleaseAction(forMove: false, forIdle: true, forAttack: false){
//                    self.enemyAction.idle = true
//                }
            }
        }
    }
    func RunStateTimer(){
        if !enemyAction.die{
            stateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
        }
    }
    @objc func UpdateTimer(){
        if (stateSeconds > 0){
//            if enemyAction.idle{
//                stateSeconds -= 2
//            }else{
//                stateSeconds -= 1
//            }
            stateSeconds -= 1
        }else{
            stateTimer.invalidate()
            stateSeconds = 6
            if !enemyAction.attack && !enemyAction.die && !enemyAction.hit{
                StateManager()
            }
        }
    }
    func Die(){
        ReleaseAction(forMove: false, forIdle: false, forAttack: false, forDie: true) {
            self.Anim(state: .Die, isRepeat: false) {
                self.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: 1),
                        SKAction.run { [weak self] in
                            self?.removeFromParent()
                        },
                        ]), withKey: "Die")
            }
        }
    }
    @objc func HitInAttack(player: Player){
        enemyAction.hit = true
        enemyHP -= 25
        
        if(enemyHP <= 0){
            if !enemyAction.die{
                self.Die()
            }
        }else{
            if player.xScale > 0{
                self.physicsBody?.velocity = CGVector(dx: -1000, dy: Int((self.physicsBody?.velocity.dy)!))
            }else{
                self.physicsBody?.velocity = CGVector(dx: 1000, dy: Int((self.physicsBody?.velocity.dy)!))
            }
            if enemyAction.hit{
                HitEffectIn()
            }
        }
        
    }
    func HitInSkill(player: Player){
        enemyAction.hit = true
        enemyHP -= 100
        
        if(enemyHP <= 0){
            if !enemyAction.die{
                self.Die()
            }
        }else{
            if player.xScale > 0{
                self.physicsBody?.velocity = CGVector(dx: -1000, dy: Int((self.physicsBody?.velocity.dy)!))
            }else{
                self.physicsBody?.velocity = CGVector(dx: 1000, dy: Int((self.physicsBody?.velocity.dy)!))
            }
            if enemyAction.hit{
                HitEffectIn()
            }
        }
    }
    func HitOut(){
        self.exitHit()
    }
    func HitEffectIn(){
        self.run(
            SKAction.sequence([
                SKAction.colorize(with: .orange, colorBlendFactor: 0.4, duration: 0.3),
                SKAction.wait(forDuration: 0.1),
                SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.3),
        ]), withKey: "HitEffectIn")
    }

    func RunHitTimer(){
        hitTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(HitInAttack(player:)), userInfo: nil, repeats: true)
    }
    private func Anim(state: EnemyActionState, isRepeat: Bool, completion: @escaping () -> ()){
        animArray.removeAll()
        
        animAtlas = SKTextureAtlas(named: "\(enemyType.rawValue)\(state)")
        for i in 1...animAtlas.textureNames.count{
            let FName = "\(enemyType.rawValue)\(state)_\(i).png"
            animArray.append(SKTexture(imageNamed: FName))
        }
        if isRepeat == true{
            if enemyAction.die == false{
                switch state{
//                case .Idle:
//                    let seq = SKAction.sequence([SKAction.animate(with: animArray, timePerFrame: 0.1),
//                                                 SKAction.wait(forDuration: 0.2)])
//                    self.run(SKAction.repeatForever(seq), withKey: "Idle")
//                    completion()
                case .Move:
//                    self.exitIdle()
                    self.run(action: SKAction.repeatForever(SKAction.animate(with: animArray, timePerFrame: 0.1)), withKey: "Move") {
                        completion()
                    }
                default:
                    completion()
                }
            }
        }else{
            switch state{
            case .Die:
                self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.4, resize: false, restore: false), withKey: "Die") {
                    completion()
                }
            case .Attack:
                if enemyAction.die == false{
                    self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.2), withKey: "Attack") {
                        completion()
                    }
                }
            default:
                completion()
            }
        }
        
    }
}
extension Enemy{
    func exitIdle(){
        if actionForKeyIsRunning(key: "Idle"){
            removeAction(forKey: "Idle")
        }
    }
    func exitMove(){
        if actionForKeyIsRunning(key: "Move"){
            removeAction(forKey: "Move")
        }
        enemyAction.leftMove = false
        enemyAction.rightMove = false
        enemyAnim.move = false
    }
    func exitAttack(){
        if actionForKeyIsRunning(key: "Attack"){
            removeAction(forKey: "Attack")
        }
        enemyAction.attack = false
        enemyAnim.attack = false
    }
    func exitHit(){
        enemyAnim.hit = false
        enemyAction.hit = false
    }
    func exitAll(){
        removeAllActions()
        enemyAction.attack = false
        enemyAction.hit = false
        enemyAction.leftMove = false
        enemyAction.rightMove = false
        enemyAnim.attack = false
        enemyAnim.hit = false
        enemyAnim.move = false
    }
    
}
