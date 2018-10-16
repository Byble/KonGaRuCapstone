//
//  Player.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 2018. 9. 20..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

struct PlayerMove {
    var leftMove = false
    var rightMove = false
}

struct Action {
    var idle = false
//    var jump = false
    var onGround = false
//    var dash = false
    var transform = false
    var attack1 = false
    var attack2 = false
    var attack3 = false
    var skill1 = false
    var dead = false
}
struct AnimCheck {
    var moving = false
    var attacking1 = false
    var attacking2 = false
    var attacking3 = false
    var transforming = false
    var jumping = false
    var dash = false
}

enum State: String {
    case human = "human"
    case cat = "cat"
}

class Player: SKSpriteNode {
    
    private let PlayerT = SKTexture(imageNamed: "cat.png")
    private var bodySize = CGSize()
    
    private var animAtlas = SKTextureAtlas()
    private var animArray = [SKTexture]()
    
    fileprivate var moveMent: PlayerMove
    fileprivate var action: Action
    private var animCheck : AnimCheck
    
    private var moveSpeed = 600
    private let limitMoveSpeed = 600
    
    private var jumpSpeed = 400
    private let limitJumpSpeed = 400
    
    private var dashSpeed = 700
    fileprivate var nowState: State
    
    private let normalize: ((CGFloat) -> CGFloat) = { (input) in
        return round(input * 1000) / 1000
    }
    
    init() {
        bodySize = CGSize(width: PlayerT.size().width, height: PlayerT.size().height)
        
        moveMent = PlayerMove()
        action = Action()
        animCheck = AnimCheck()
        nowState = State.cat
        
        super.init(texture: nil, color: NSColor.clear, size: bodySize)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        moveMent = PlayerMove()
        action = Action()
        animCheck = AnimCheck()
        nowState = State.cat
        
        super.init(coder: aDecoder)
    }
    private func setup(){
        self.texture = PlayerT
        
        let collSize = CGSize(width: PlayerT.size().width, height: PlayerT.size().height)
        
        physicsBody = SKPhysicsBody(rectangleOf: collSize, center: CGPoint(x: 0, y: self.centerRect.height+2))
        physicsBody?.friction = 1
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = true
        physicsBody?.restitution = 0.0
        physicsBody?.isDynamic = true
        
        physicsBody?.categoryBitMask = ColliderType.charactor.rawValue
        physicsBody?.collisionBitMask = ColliderType.floor.rawValue
        physicsBody?.contactTestBitMask = ColliderType.enemy.rawValue | ColliderType.floor.rawValue | ColliderType.item.rawValue
        physicsBody?.usesPreciseCollisionDetection = true
    }
    private func checkIdle() -> Bool{
        if !(animCheck.moving) && !(animCheck.jumping) && !(animCheck.attacking1) && !(animCheck.attacking2) && !(animCheck.attacking3) && !(animCheck.dash) && !(animCheck.transforming) && !(action.idle){
            action.idle = true
            animCheck.moving = false
            animCheck.jumping = false
            animCheck.attacking1 = false
            animCheck.attacking2 = false
            animCheck.attacking3 = false
            
            if nowState == .cat{
                anim(state: "Idle", isRepeat: true, body: .cat, completion: {})
            }else if nowState == .human{
                anim(state: "Idle", isRepeat: true, body: .human, completion: {})
            }
            return false
        }
        return true
    }
    private func checkTransAnim() -> Bool{
        if animCheck.transforming == true{
            return false
        }
        return true
    }
    private func checkAtkAnim() -> Bool{
        if actionForKeyIsRunning(key: "Attack"){
            return false
        }
        return true
    }
    open func checkMoveAnim(){
        let speedX = normalize((self.physicsBody?.velocity.dx)!)
        let speedY = normalize((self.physicsBody?.velocity.dy)!)
        if (speedX > -0.5 && speedX < 0.5){
            if (speedY > -0.5 && speedY < 0.5){
                removeAction(forKey: "Move")
                animCheck.moving = false
            }
        }
    }
    open func jump(){
        if action.onGround == true{
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpSpeed))
            action.onGround = false
            if nowState == .cat{
                anim(state: "Jump", isRepeat: false, body: .cat) {
                    
                }
            }else if nowState == .human{
                anim(state: "Jump", isRepeat: false, body: .human) {
                    
                }
            }
        }
    }
    open func dash(){
        let nowMoveSpeed: CGFloat = abs((self.physicsBody?.velocity.dx)!)
        if self.xScale > 0{
            if Int(nowMoveSpeed) < moveSpeed{
                self.physicsBody?.applyImpulse(CGVector(dx: -dashSpeed, dy: 0))
            }
        }else{
            if Int(nowMoveSpeed) < moveSpeed{
                self.physicsBody?.applyImpulse(CGVector(dx: dashSpeed, dy: 0))
            }
        }
        guard checkAtkAnim() else{
            return
        }
        if animCheck.transforming == false{
            if nowState == .cat{
                anim(state: "Run",isRepeat: false, body: .cat, completion: {})
            }else if nowState == .human{
                anim(state: "Run",isRepeat: false, body: .human, completion: {})
            }
        }
    }
    open func actionUpdate(){
        guard checkTransAnim() else{
            return
        }
        if action.attack1 == true && animCheck.attacking1 == false{
            action.onGround = true
            animCheck.attacking1 = true
            if nowState == .cat{
                anim(state: "Attack", isRepeat: false, body: .cat){
                    self.animCheck.attacking1 = false
                    self.action.attack1 = false
                    if self.moveMent.leftMove || self.moveMent.rightMove{
                        self.animCheck.moving = true
                        self.anim(state: "Move", isRepeat: true, body: .cat, completion: {})
                    }
                }
//                anim(state: "Attack", isRepeat: false, body: .cat) {
//                    if self.action.attack2 == true{
//                        self.animCheck.attacking2 = true
//                        self.anim(state: "Attack", isRepeat: false, body: .cat, completion: {
//                            if self.action.attack3 == true{
//                                self.animCheck.attacking3 = true
//                                self.anim(state: "Attack", isRepeat: false, body: .cat, completion: {})
//                            }
//                        })
//                    }
//                }
            }
            else if nowState == .human{
                anim(state: "Attack", isRepeat: false, body: .human, completion: {})
//                anim(state: "Attack1", isRepeat: false, body: .human) {
//                    if self.action.attack2 == true{
//                        self.animCheck.attacking2 = true
//                        self.anim(state: "Attack2", isRepeat: false, body: .human, completion: {
//                            if self.action.attack3 == true{
//                                self.animCheck.attacking3 = true
//                                self.anim(state: "Attack3", isRepeat: false, body: .human, completion: {})
//                            }
//                        })
//                    }
//                }
            }
        }
        if action.transform == true{ //나중에 변경 모션으로 이름 바꾸기 Dead -> ? transform
            if animCheck.transforming == false && animCheck.attacking1 == false{
                self.animCheck.transforming = true
                if nowState == .cat{
                    anim(state: "Dead", isRepeat: false, body: .human) {
                        self.nowState = State.human
                        self.animCheck.transforming = false
                        self.action.transform = false
                        if self.moveMent.leftMove || self.moveMent.rightMove{
                            self.animCheck.moving = true
                            self.anim(state: "Move", isRepeat: true, body: .human, completion: {})
                        }
                    }
                }else if nowState == .human{
                    anim(state: "Dead", isRepeat: false, body: .cat) {
                        self.nowState = State.cat
                        self.animCheck.transforming = false
                        self.action.transform = false
                        if self.moveMent.leftMove || self.moveMent.rightMove{
                            self.animCheck.moving = true
                            self.anim(state: "Move", isRepeat: true, body: .cat, completion: {})
                        }
                    }
                }
            }
        }
    }
    
    open func moveUpdate(){
        guard checkIdle() else {
            return
        }
        let nowMoveSpeed: CGFloat = abs((self.physicsBody?.velocity.dx)!)
        if moveMent.leftMove == true{
            
            if Int(nowMoveSpeed) < limitMoveSpeed{
                if self.xScale < 0{
                    self.xScale = abs(self.xScale)
                }
                self.physicsBody?.velocity = CGVector(dx: -moveSpeed, dy: Int((self.physicsBody?.velocity.dy)!))
                guard checkAtkAnim() else{
                    return
                }
                if !(animCheck.transforming) && !(animCheck.jumping) && !(animCheck.attacking1) && !(animCheck.dash){
                    if animCheck.moving == false{
                        animCheck.moving = true
                        if nowState == .cat{
                            anim(state: "Move", isRepeat: true, body: .cat, completion: {})
                        }else if nowState == .human{
                            anim(state: "Move", isRepeat: true, body: .human, completion: {})
                        }
                    }
                }
            }
        }
        if moveMent.rightMove == true{
            if Int(nowMoveSpeed) < limitMoveSpeed{
                if self.xScale > 0{
                    self.xScale = self.xScale * -1
                }
                self.physicsBody?.velocity = CGVector(dx: moveSpeed, dy: Int((self.physicsBody?.velocity.dy)!))
                guard checkAtkAnim() else{
                    return
                }
                if !(animCheck.transforming) && !(animCheck.jumping) && !(animCheck.attacking1){
                    if animCheck.moving == false{
                        animCheck.moving = true
                        if nowState == .cat{
                            anim(state: "Move", isRepeat: true, body: .cat, completion: {})
                        }else if nowState == .human{
                            anim(state: "Move", isRepeat: true, body: .human, completion: {})
                        }
                    }
                }
            }
        }
        
    }
    private func anim(state: String, isRepeat: Bool, body: State, completion: @escaping () -> ()){
        animArray.removeAll()
        
        if action.dead == false{
            animAtlas = SKTextureAtlas(named: "\(body)\(state)")
            for i in 1...animAtlas.textureNames.count{
                let FName =  "\(body)\(state)\(i).png"
                animArray.append(SKTexture(imageNamed: FName))
            }
            if isRepeat == true{
                switch state{
                case "Idle":
                    let seq = SKAction.sequence([SKAction.animate(with: animArray, timePerFrame: 0.1), SKAction.wait(forDuration: 1)])
                    self.run(SKAction.repeatForever(seq), withKey: state)
                    completion()
                case "Move":
                    action.idle = false
                    self.run(action: SKAction.repeatForever(SKAction.animate(with: animArray, timePerFrame: 0.1)), withKey: state) {
                        completion()
                    }
                default:
                    action.idle = false
                    self.run(SKAction.repeatForever(SKAction.animate(with: animArray, timePerFrame: 0.1)), withKey: state)
                    completion()
                }
                
            }else{
                switch state{
                case "Attack":
                    animCheck.moving = false
                    action.idle = false
                    self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.1), withKey: "Attack") {
                        self.animCheck.attacking1 = false
                        self.action.attack1 = false
                        completion()
                    }
                case "Attack1":
                    animCheck.moving = false
                    action.idle = false
                    self.run(SKAction.animate(with: animArray, timePerFrame: 0.1)){
                        self.animCheck.attacking1 = false
                        self.action.attack1 = false
                        completion()
                    }
                case "Attack2":
                    animCheck.moving = false
                    action.idle = false
                    self.run(SKAction.animate(with: animArray, timePerFrame: 0.1)){
                        self.animCheck.attacking2 = false
                        self.action.attack2 = false
                        completion()
                    }
                case "Attack3":
                    animCheck.moving = false
                    action.idle = false
                    self.run(SKAction.animate(with: animArray, timePerFrame: 0.1)){
                        self.animCheck.attacking3 = false
                        self.action.attack3 = false
                        completion()
                    }
                case "Dead":
                    animCheck.moving = false
                    action.idle = false
                    self.run(SKAction.animate(with: animArray, timePerFrame: 0.05)){
                        
                        completion()
                    }
                case "Jump":
                    animCheck.moving = false
                    action.idle = false
                    animCheck.jumping = true
                    self.run(SKAction.animate(with: animArray, timePerFrame: 0.05)) {
                        self.animCheck.jumping = false
                        completion()
                    }
                case "Run":
                    animCheck.moving = false
                    action.idle = false
                    animCheck.dash = true
                    self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.03), withKey: "dash") {
                        self.animCheck.dash = false
                        completion()
                    }
                default:
                    completion()
                }
            }
        }
    }
}

extension SKNode{
    func run(action: SKAction!, withKey: String!, completion: @escaping () -> ()) {
        let completionAction = SKAction.run(completion)
        let compositeAction = SKAction.sequence([ action, completionAction ])
        run(compositeAction, withKey: withKey )
    }
    
    func actionForKeyIsRunning(key: String) -> Bool {
        return self.action(forKey: key) != nil ? true : false
    }
}
extension Player{
    func setPlayerMoveLeft(isMoving: Bool){
        moveMent.leftMove = isMoving
    }
    func setPlayerMoveRight(isMoving: Bool){
        moveMent.rightMove = isMoving
    }
    func setActionTrans(isTransforming: Bool){
        action.transform = isTransforming
    }
    func setActionOnGround(isOn: Bool){
        action.onGround = isOn
    }
    func getState() -> State{
        return self.nowState
    }
}
