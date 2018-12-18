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
    var idle = false
    var leftMove = false
    var rightMove = false
    var attack = false
    var hit = false
    var die = false
}
struct EnemyAnimCheck {
    var idle = false
    var move = false
    var attack = false
    var hit = false
    var die = false
}
enum EnemyActionState: String{
    case Idle = "Idle"
    case Die = "Die"
    case Move = "Move"
    case Attack = "Attack"
    case Hit = "Hit"
}
enum MoleState: uint32{
    case leftMove
    case rightMove
    case Idle
    private static let _count: MoleState.RawValue = {
        var maxValue: uint32 = 0
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
            self.texture = moleT
            self.zPosition = 0
            position = spawnPosition
            
            let collSize = CGSize(width: moleT.size().width, height: moleT.size().height)
            physicsBody = SKPhysicsBody(rectangleOf: collSize, center: CGPoint(x: 0, y: moleT.size().height/5))
        case .mud:
            self.texture = mudT
            self.zPosition = 0
            position = spawnPosition
            
            let collSize = CGSize(width: mudT.size().width, height: mudT.size().height)
            physicsBody = SKPhysicsBody(rectangleOf: collSize, center: CGPoint(x: 0, y: mudT.size().height/5))
        case .snale:
            self.texture = snaleT
            self.zPosition = 0
            position = spawnPosition
            
            let collSize = CGSize(width: snaleT.size().width, height: snaleT.size().height)
            physicsBody = SKPhysicsBody(rectangleOf: collSize, center: CGPoint(x: 0, y: snaleT.size().height/5))
        case .none:
            break
        }
        
        physicsBody?.friction = 1
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = true
        physicsBody?.restitution = 0.0
        
        physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        physicsBody?.collisionBitMask = PhysicsCategory.Ground
        physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Player
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
                self.xScale = abs(self.xScale)
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
                self.xScale = self.xScale * -1
            }
            self.physicsBody?.velocity = CGVector(dx: self.moveSpeed, dy: Int((self.physicsBody?.velocity.dy)!))
        }
    }
    func CheckMove(){
        if enemyAction.leftMove{
            LeftMove()
        }
        else if enemyAction.rightMove{
            RightMove()
        }else if enemyAction.idle{
            Idle()
        }
    }
    func Idle(){
        if enemyAnim.idle == false{
            self.enemyAnim.idle = true
            self.Anim(state: .Idle, isRepeat: true, completion: {})
        }
    }
    func Attack(){
        if enemyAnim.attack == false{
            stateSeconds = 6
            stateTimer.invalidate()
            ReleaseAction(forMove: false, forIdle: false, forAttack: true){
                self.enemyAnim.attack = true
                self.Anim(state: .Attack, isRepeat: true, completion: {})
            }
        }
    }
    
    func ReleaseAction(forMove: Bool, forIdle: Bool, forAttack: Bool, completion: @escaping () -> ()){
        if forMove{
            if self.actionForKeyIsRunning(key: "Idle"){
                removeAction(forKey: "Idle")
            }
            if self.actionForKeyIsRunning(key: "Attack"){
                removeAction(forKey: "Attack")
            }
            enemyAction.attack = false
            enemyAction.die = false
            enemyAction.hit = false
            enemyAction.idle = false
            
            enemyAnim.attack = false
            enemyAnim.die = false
            enemyAnim.hit = false
            enemyAnim.idle = false
            completion()
        }
        else if forIdle{
            if self.actionForKeyIsRunning(key: "Move"){
                removeAction(forKey: "Move")
            }
            if self.actionForKeyIsRunning(key: "Attack"){
                removeAction(forKey: "Attack")
            }
            enemyAction.attack = false
            enemyAction.die = false
            enemyAction.hit = false
            enemyAction.leftMove = false
            enemyAction.rightMove = false
            
            enemyAnim.attack = false
            enemyAnim.die = false
            enemyAnim.hit = false
            enemyAnim.move = false
            completion()
        }
        else if forAttack{
            if self.actionForKeyIsRunning(key: "Idle"){
                removeAction(forKey: "Idle")
            }
            if self.actionForKeyIsRunning(key: "Move"){
                removeAction(forKey: "Move")
            }
            enemyAction.die = false
            enemyAction.hit = false
            enemyAction.leftMove = false
            enemyAction.rightMove = false
            enemyAction.idle = false
            
            enemyAnim.die = false
            enemyAnim.hit = false
            enemyAnim.idle = false
            enemyAnim.move = false
            completion()
        }
    }
    func StateManager(){
        RunStateTimer()
        
        switch MoleState.randomMove() {
        case .leftMove:
            ReleaseAction(forMove: true, forIdle: false, forAttack: false) {
                self.enemyAction.leftMove = true
            }
        case .rightMove:
            ReleaseAction(forMove: true, forIdle: false, forAttack: false) {
                self.enemyAction.rightMove = true
            }
        case .Idle:
            ReleaseAction(forMove: false, forIdle: true, forAttack: false){
                self.enemyAction.idle = true
            }
        }
    }
    func RunStateTimer(){
        stateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
    }
    @objc func UpdateTimer(){
        if (stateSeconds > 0){
            if enemyAction.idle{
                stateSeconds -= 2
            }else{
                stateSeconds -= 1
            }
        }else{
            stateTimer.invalidate()
            stateSeconds = 6
            if !enemyAction.attack && !enemyAction.die && !enemyAction.hit{
                enemyAction.attack = false
                enemyAction.die = false
                enemyAction.hit = false
                enemyAction.idle = false
                enemyAction.leftMove = false
                enemyAction.rightMove = false
                enemyAnim.attack = false
                enemyAnim.die = false
                enemyAnim.hit = false
                enemyAnim.idle = false
                enemyAnim.move = false
                StateManager()
            }
        }
    }
    private func Anim(state: EnemyActionState, isRepeat: Bool, completion: @escaping () -> ()){
        animArray.removeAll()
        
        if enemyAction.die == false{
            
            animAtlas = SKTextureAtlas(named: "\(enemyType.rawValue)\(state)")
            for i in 1...animAtlas.textureNames.count{
                let FName = "\(enemyType.rawValue)\(state)_\(i).png"
                animArray.append(SKTexture(imageNamed: FName))
            }
            if isRepeat == true{
                switch state{
                case .Idle:
                    let seq = SKAction.sequence([SKAction.animate(with: animArray, timePerFrame: 0.1),
                                                 SKAction.wait(forDuration: 0.2)])
                    self.run(SKAction.repeatForever(seq), withKey: "Idle")
                    completion()
                case .Move:
                    enemyAction.idle = false
                    self.run(action: SKAction.repeatForever(SKAction.animate(with: animArray, timePerFrame: 0.1)), withKey: "Move") {
                        completion()
                    }
                case .Attack:
                    self.run(action: SKAction.repeatForever(SKAction.animate(with: animArray, timePerFrame: 0.2)), withKey: "Attack") {
                        completion()
                    }
                default:
                    completion()
                }
            }else{
                switch state{
                
                case .Die:
                    completion()
                case .Hit:
                    completion()
                default:
                    completion()
                }
            }
        }
    }
}
