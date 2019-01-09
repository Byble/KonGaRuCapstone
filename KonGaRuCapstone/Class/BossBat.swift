//
//  BossBat.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 20/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

struct BatAction{
    var idle = false
    var leftMMove = false
    var rightMMove = false
    var attack = false
    var hit = false
    var die = false
    var howl = false
    var crystal = false
}
struct BatAnimCheck {
    var idle = false
    var Move = false
    var attack = false
    var hit = false
    var die = false
    var howl = false
    var crystal = false
}
enum BatActionState: String {
    case Idle = "Idle"
    case Move = "Move"
    case Attack = "Attack"
    case Hit = "Hit"
    case Die = "Die"
    case Howl = "Howl"
    case Crystal = "Crystal"
}
enum BatMoveState: UInt32{
    case none
    case leftMMove
    case rightMMove
}
enum BatAttackState: UInt32 {
    case howl
    case srystal
    case attack
}
struct BatPosition {
    static let leftEdgeX: CGFloat = -800
    static let rightEdgeX: CGFloat = 800
    static let EdgeTopY: CGFloat = 300
}
enum BatMoveY: UInt32{
    case none
    case middle
    case top
    private static let _count: BatMoveY.RawValue = {
        var maxValue: UInt32 = 0
        while let _ = BatMoveY(rawValue: maxValue){
            maxValue += 1
        }
        return maxValue
    }()
    static func randomMove() -> BatMoveY{
        let rand = UInt32.random(in: 1...2)
        return BatMoveY(rawValue: rand)!
    }
}
class BossBat: SKSpriteNode {
    let batT = SKTexture(imageNamed: "bat.png")
    
    private var animAtlas = SKTextureAtlas()
    private var animArray = [SKTexture]()
    
    private var bodySize = CGSize()
    
    var batAction : BatAction
    var batAnim : BatAnimCheck
    
    var spawnPosition: CGPoint = CGPoint(x: 0, y: 0)
    var batHP: Int = 100
    let skillStartHP: Int = 50
    
    var moveStateTimer = Timer()
    var moveStateSeconds = 6
    
    var currentMoveState: BatMoveState
    
    var targetPlayer: SKNode
    
    init(position: CGPoint, player: SKNode) {
        spawnPosition = position
        bodySize = CGSize(width: batT.size().width*1.5, height: batT.size().height*1.5)
        batAction = BatAction()
        batAnim = BatAnimCheck()
        currentMoveState = BatMoveState.none
        self.targetPlayer = player
        
        super.init(texture: batT, color: .clear, size: bodySize)
        
        Setup()
    }
    required init?(coder aDecoder: NSCoder) {
        batAction = BatAction()
        batAnim = BatAnimCheck()
        currentMoveState = BatMoveState(rawValue: 0)!
        self.targetPlayer = SKNode()
        
        super.init(coder: aDecoder)
    }
    
    func Setup(){
        self.name = "bat"
        self.texture = batT
        self.zPosition = 0
        position = spawnPosition
        self.xScale = -1
        
        let collSize = CGSize(width: batT.size().width, height: batT.size().height*0.8)
        physicsBody = SKPhysicsBody(rectangleOf: collSize, center: CGPoint(x: 0, y: 0))
        physicsBody?.friction = 1
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = false
        physicsBody?.restitution = 0.0
        
        physicsBody?.categoryBitMask = PhysicsCategory.Bat
        physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerAttack | PhysicsCategory.ZoomShot | PhysicsCategory.GhostShot
        physicsBody?.collisionBitMask = PhysicsCategory.Wall | PhysicsCategory.Ground | PhysicsCategory.EdgeWall
        
        Idle()
        run(SKAction.sequence([
            SKAction.wait(forDuration: 2),
            SKAction.run {
                self.StateMoveManager(MoveState: .rightMMove)
            }
            ]))
    }
    
    func CheckMove(){
        if !batAction.die{
            switch currentMoveState{
            case .leftMMove:
                if batAnim.Move == false{
                    batAnim.Move = true
                    LeftMove(where: .leftMMove, yPos: BatMoveY.randomMove())
                }
            case .rightMMove:
                if batAnim.Move == false{
                    batAnim.Move = true
                    RightMove(where: .rightMMove, yPos: BatMoveY.randomMove())
                }
            case .none:
                break
            }
        }
    }
    
    func LeftMove(where: BatMoveState, yPos: BatMoveY){
        Anim(state: .Move, isRepeat: true, completion: {})
        
        let path = NSBezierPath()
        path.move(to: CGPoint(x:self.position.x, y:self.position.y))
        
        path.addQuadCurve(to: CGPoint(x: 3300, y: -460), controlPoint: CGPoint(x: targetPlayer.position.x+CGFloat.random(in: -200...200), y: self.position.y - 800))
        let parabolaAction = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, speed: 1000)
        
        self.run(parabolaAction) {
            self.xScale = -1
            if self.actionForKeyIsRunning(key: "Move"){
                self.removeAction(forKey: "Move")
            }
            if yPos == .top{
                self.run(SKAction.moveBy(x: 0, y: BatPosition.EdgeTopY, duration: 2))
            }
            self.Howl(MoveState: .leftMMove)
        }
    }
    func RightMove(where: BatMoveState, yPos: BatMoveY){
        Anim(state: .Move, isRepeat: true, completion: {})
        
        let path = NSBezierPath()
        path.move(to: CGPoint(x:self.position.x, y:self.position.y))
        path.addQuadCurve(to: CGPoint(x: 5000, y: -460), controlPoint: CGPoint(x: targetPlayer.position.x+CGFloat.random(in: -200...200), y: self.position.y - 1000))
        let parabolaAction = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, speed: 1000)
        self.run(parabolaAction) {
            self.xScale = 1
            if self.actionForKeyIsRunning(key: "Move"){
                self.removeAction(forKey: "Move")
            }
            if yPos == .top{
                self.run(SKAction.moveBy(x: 0, y: BatPosition.EdgeTopY, duration: 2))
            }
            self.Howl(MoveState: .rightMMove)
        }
    }
    func StateMoveManager(MoveState: BatMoveState){
        if !batAction.die{
            RunMoveStateTimer()
            
            switch MoveState{
            case .leftMMove:
                ReleaseAction(forMove: true, forIdle: false, forAttack: false, forHowl: false, forCrystal: false, forDie: false){
                    self.batAction.leftMMove = true
                    self.currentMoveState = BatMoveState.leftMMove
                }
            case .rightMMove:
                ReleaseAction(forMove: true, forIdle: false, forAttack: false, forHowl: false, forCrystal: false, forDie: false){
                    self.batAction.rightMMove = true
                    self.currentMoveState = BatMoveState.rightMMove
                }
            case .none:
                break
            }
        }
    }
    func RunMoveStateTimer(){
        if !batAction.die{
            moveStateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UpdateMoveTimer), userInfo: nil, repeats: true)
        }
    }
    @objc func UpdateMoveTimer(){
        if (moveStateSeconds > 0){
            moveStateSeconds -= 1
        }else{
            moveStateTimer.invalidate()
            moveStateSeconds = 8
            if !batAction.attack && !batAction.die && !batAction.hit{
                if currentMoveState == .leftMMove{
                    StateMoveManager(MoveState: .rightMMove)
                }else{                    
                    StateMoveManager(MoveState: .leftMMove)
                }
            }
        }
    }
    func Idle(){
        if batAnim.idle == false{
            self.batAnim.idle = true
            self.Anim(state: .Idle, isRepeat: true, completion: {})
        }
    }
    func Attack(player: Player, completion: @escaping ()->()){
        if batAnim.attack == false{
            ReleaseAction(forMove: false, forIdle: false, forAttack: true, forHowl: false, forCrystal: false, forDie: false, completion: {
                self.batAnim.attack = true
                self.Anim(state: .Attack, isRepeat: false) {
                }
                completion()
            })
        }        
    }
    func Howl(MoveState: BatMoveState){
        
        ReleaseAction(forMove: false, forIdle: false, forAttack: false, forHowl: true, forCrystal: false, forDie: false) {
            self.run(SKAction.sequence([
                SKAction.wait(forDuration: 2),
                SKAction.run {
                    self.Anim(state: .Howl, isRepeat: false, completion: {})
                },
                SKAction.run {
                    self.scene?.camera?.shakeCamera(layer: (self.scene?.camera)!, duration: 4)
                },
                SKAction.repeat(SKAction.sequence([
                    SKAction.run {
                        var spawnPos = CGPoint(x: 0, y: 0)
                        if MoveState == .leftMMove{
                            spawnPos = CGPoint(x: self.position.x+100, y: self.position.y+45)
                        }else{
                            spawnPos = CGPoint(x: self.position.x-100, y: self.position.y+45)
                        }
                        let howl = BatHowl(pos: spawnPos)
                        self.parent?.addChild(howl)
                    },
                    SKAction.wait(forDuration: 0.4)
                    ]), count: 4),
                SKAction.run {
                    if self.batHP < self.skillStartHP{
                        self.run(SKAction.sequence([
                            SKAction.wait(forDuration: 0.5),
                            SKAction.repeat(SKAction.sequence([
                                SKAction.run {
                                    let crystal = BatCrystal(pos: self.position)
                                    self.parent?.addChild(crystal)
                                },
                                SKAction.wait(forDuration: 0.5)
                                ]), count: Int.random(in: 2...4))
                            ]))
                    }
                }
                ]))
        }
    }
    
    func Crystal(){
        
    }
    func HitInAttack(){
        batAction.hit = true
        batHP -= 5
        
        if (batHP <= 0){
            if !batAction.die{
                self.Die()
            }
        }else{
            if batAction.hit{
                HitEffectIn()
            }
        }
    }
    func HitInSkill(){
        batAction.hit = true
        batHP -= 15 //추후 15로 변경
        
        if (batHP <= 0){
            if !batAction.die{
                self.Die()
            }
        }else{
            if batAction.hit{
                HitEffectIn()
            }
        }
    }
    func HitOut(){
        self.exitHit()
    }
    func HitEffectIn(){
        self.run(action: SKAction.sequence([
            SKAction.colorize(with: .orange, colorBlendFactor: 0.4, duration: 0.3),
            SKAction.wait(forDuration: 0.1),
            SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.3),
            ]), withKey: "HitEffectIn") {
                self.HitOut()
        }
    }
    func Die(){
        ReleaseAction(forMove: false, forIdle: false, forAttack: false, forHowl: false, forCrystal: false, forDie: true) {
            self.physicsBody?.collisionBitMask = PhysicsCategory.Ground
            self.physicsBody?.contactTestBitMask = PhysicsCategory.None
            self.physicsBody?.affectedByGravity = true
            self.Anim(state: .Die, isRepeat: false){
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
    
    func ReleaseAction(forMove: Bool, forIdle: Bool, forAttack: Bool, forHowl: Bool, forCrystal: Bool, forDie: Bool, completion: @escaping () -> ()){
        
        if forMove{
            self.exitMove()
            self.exitAttack()
            self.exitHowl()
            self.exitCrystal()
            completion()
        }
        else if forIdle{
            self.exitMove()
            self.exitAttack()
            self.exitCrystal()
            self.exitHowl()
            self.exitIdle()
            completion()
        }
        else if forAttack{
            self.exitCrystal()
            self.exitHowl()
            self.exitAttack()
            completion()
        }
        else if forHowl{
            self.exitCrystal()
            self.exitAttack()
            completion()
        }
        else if forCrystal{
            self.exitHowl()
            self.exitAttack()
            self.exitCrystal()
            completion()
        }
        else if forDie{
            self.exitAll()
            self.batAction.die = true
            self.physicsBody?.contactTestBitMask = PhysicsCategory.None
            completion()
        }
    }
    
    private func Anim(state: BatActionState, isRepeat: Bool, completion: @escaping () -> ()){
        animArray.removeAll()
        
        animAtlas = SKTextureAtlas(named: "bat\(state)")
        for i in 1...animAtlas.textureNames.count{
            let FName = "bat\(state)_\(i).png"
            animArray.append(SKTexture(imageNamed: FName))
        }
        
        if isRepeat == true{
            switch state{
            case .Idle:
                self.run(action: SKAction.repeatForever(SKAction.sequence([
                    SKAction.animate(with: animArray, timePerFrame: 0.1),
                    SKAction.wait(forDuration: 0.05)
                    ])), withKey: "Idle"){
                        completion()
                }
            case .Move:
                self.run(action: SKAction.repeatForever(SKAction.animate(with: animArray, timePerFrame: 0.1)), withKey: "Move"){
                    completion()
                }
            default:
                break
            }
        }else{
            switch state{
            case .Attack:
                self.run(action: SKAction.repeat(SKAction.animate(with: animArray, timePerFrame: 0.13), count: 2), withKey: "Attack") {
                    completion()
                }
            case .Hit:
                completion()
            case .Die:
                self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.1), withKey: "Die") {
                    completion()
                }
            case .Howl:
                self.run(action: SKAction.repeat(SKAction.animate(with: animArray, timePerFrame: 0.13), count: 7), withKey: "Howl") {
                    completion()
                }
            case .Crystal:
                completion()
            default:
                completion()
            }
        }
    }
}

extension BossBat{
    func exitIdle(){
        if self.actionForKeyIsRunning(key: "Idle"){
            removeAction(forKey: "Idle")
        }
        batAction.idle = false
        batAnim.idle = false
    }
    func exitMove(){
        if self.actionForKeyIsRunning(key: "Move"){
            removeAction(forKey: "Move")
        }
        batAction.rightMMove = false
        batAction.leftMMove = false
        batAnim.Move = false
    }
    func exitAttack(){
        if self.actionForKeyIsRunning(key: "Attack"){
            removeAction(forKey: "Attack")
        }
        batAction.attack = false
        batAnim.attack = false
    }
    func exitHowl(){
        if self.actionForKeyIsRunning(key: "Howl"){
            removeAction(forKey: "Howl")
        }
        batAction.howl = false
        batAnim.howl = false
    }
    func exitCrystal(){
        if self.actionForKeyIsRunning(key: "Crystal"){
            removeAction(forKey: "Crystal")
        }
        batAction.crystal = false
        batAnim.crystal = false
    }
    func exitHit(){
        batAction.hit = false
        batAnim.hit = false
    }
    func exitAll(){
        removeAllActions()
        batAction.attack = false
        batAction.crystal = false
        batAction.hit = false
        batAction.howl = false
        batAction.idle = false

        batAction.leftMMove = false
        batAction.rightMMove = false

        batAnim.attack = false
        batAnim.crystal = false
        batAnim.hit = false
        batAnim.howl = false
        batAnim.idle = false
        batAnim.Move = false
    }
}
