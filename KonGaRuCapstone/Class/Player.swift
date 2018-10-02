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
    var jump = false
    var onGround = false
    var dash = false
    var transform = false
    var attack = false
    var skill1 = false
    var dead = false
}
struct AnimCheck {
    var moving = false
    var attacking = false
    var transforming = false
}

enum State: String {
    case human = "human"
    case cat = "cat"
}

class Player: SKSpriteNode {
    
    let PlayerT = SKTexture(imageNamed: "BearRun1.png")
    var bodySize = CGSize()
    
    var animAtlas = SKTextureAtlas()
    var animArray = [SKTexture]()
    
    var moveMent: PlayerMove
    var action: Action
    var animCheck : AnimCheck
    
    var moveSpeed = 400
    let limitMoveSpeed = 300
    
    var jumpSpeed = 150
    let limitJumpSpeed = 300
    
    var dashSpeed = 250
    var nowState: State
    
    init() {
        bodySize = CGSize(width: PlayerT.size().width, height: PlayerT.size().height)
        
        moveMent = PlayerMove()
        action = Action()
        animCheck = AnimCheck()
        nowState = State.human
        
        super.init(texture: nil, color: NSColor.clear, size: bodySize)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        moveMent = PlayerMove()
        action = Action()
        animCheck = AnimCheck()
        nowState = State.human
        
        super.init(coder: aDecoder)
    }
    
    func setup(){
        self.texture = PlayerT
        
        let collSize = CGSize(width: PlayerT.size().width / 8, height: PlayerT.size().height / 6.7)
        
        physicsBody = SKPhysicsBody(rectangleOf: collSize, center: CGPoint(x: 0, y: self.centerRect.height+2))
        physicsBody?.friction = 1
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = true
        physicsBody?.restitution = 0.0
        physicsBody?.categoryBitMask = ColliderType.charactor.rawValue
        physicsBody?.collisionBitMask = ColliderType.enemy.rawValue | ColliderType.floor.rawValue | ColliderType.item.rawValue
        physicsBody?.contactTestBitMask = ColliderType.enemy.rawValue | ColliderType.floor.rawValue | ColliderType.item.rawValue
    }
    
    func checkIdle() -> Bool{
        if !(moveMent.leftMove) && !(moveMent.rightMove) && !(action.jump) && !(action.dash) && !(action.attack) && !(action.skill1) && !(action.transform) && !(action.idle){
            if nowState == .cat{
                anim(state: "Idle", isRepeat: true, body: .cat, completion: {})
            }else if nowState == .human{
                anim(state: "Idle", isRepeat: true, body: .human, completion: {})
            }
            
            action.idle = true
            animCheck.moving = false
            return false
        }
        return true
    }
    func checkMoveAnim() -> Bool{
        if (moveMent.leftMove == false) && (moveMent.rightMove == false) && (action.dash == false){
            self.removeAction(forKey: "Move")
        }
        return true
    }
    func checkActionAnim() -> Bool{
        if (action.attack == false){
            self.removeAction(forKey: "Attack")
        }
//        if (action.skill1 == false){
//            self.removeAction(forKey: "Skill1")
//        }
        if (action.transform == false){
            self.removeAction(forKey: "transform")
        }
        return true
    }
    func checkTransAnim() -> Bool{
        if animCheck.transforming == true{
            return false
        }else{
            return true
        }
    }
    
    
    func move(){
        guard checkIdle() else {
            return
        }
        guard checkMoveAnim() else {
            return
        }
//        guard checkActionAnim() else {
//            return
//        }
        
        let nowMoveSpeed: CGFloat = abs((self.physicsBody?.velocity.dx)!)

        if moveMent.leftMove == true{
            if Int(nowMoveSpeed) < limitMoveSpeed{
                if self.xScale > 0{
                    self.xScale = self.xScale * -1
                }
                self.physicsBody?.velocity = CGVector(dx: -moveSpeed, dy: 0)
                action.idle = false
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
        
        if moveMent.rightMove == true{
            if Int(nowMoveSpeed) < limitMoveSpeed{
                if self.xScale < 0{
                    self.xScale = abs(self.xScale)
                }
                self.physicsBody?.velocity = CGVector(dx: moveSpeed, dy: 0)
                action.idle = false
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
        
        if action.jump == true && action.onGround == true{
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpSpeed))
            action.jump = false
            action.onGround = false
            action.idle = false
        }
        
        if action.dash == true{
            if self.xScale > 0{
                if Int(nowMoveSpeed) < moveSpeed{
                    self.physicsBody?.applyImpulse(CGVector(dx: dashSpeed, dy: 0))
                }
            }else{
                if Int(nowMoveSpeed) < moveSpeed{
                    self.physicsBody?.applyImpulse(CGVector(dx: -dashSpeed, dy: 0))
                }
            }
            animCheck.moving = true
            if nowState == .cat{
                anim(state: "Move",isRepeat: true, body: .cat, completion: {})
            }else if nowState == .human{
                anim(state: "Move",isRepeat: true, body: .human, completion: {})
            }

            action.dash = false
            action.idle = false
        }
        
        if action.attack == true{
            action.idle = false
            if animCheck.attacking == false{
                animCheck.attacking = true
                if nowState == .cat{
                    anim(state: "Attack", isRepeat: false, body: .cat, completion: {})
                }else if nowState == .human{
                    anim(state: "Attack", isRepeat: false, body: .human, completion: {})
                }
            }
        }
        
        if action.transform == true{ //나중에 변경 모션으로 이름 바꾸기 Dead -> ?
            action.idle = false
            if animCheck.transforming == false{
                animCheck.transforming = true
                if nowState == .cat{
                    anim(state: "Dead", isRepeat: false, body: .human) {
                        self.texture = SKTexture(imageNamed: "TigerIdle1")
                        self.nowState = State.human
                    }
                }else if nowState == .human{
                    anim(state: "Dead", isRepeat: false, body: .cat) {
                        self.texture = SKTexture(imageNamed: "BearRun1")
                        self.nowState = State.cat
                    }
                }
            }
        }
    }
    
    func anim(state: String, isRepeat: Bool, body: State, completion: @escaping () -> ()){
        animArray.removeAll()
        if action.dead == false{
            animAtlas = SKTextureAtlas(named: "\(body)\(state)")

            for i in 1...animAtlas.textureNames.count{
                let FName =  "\(body)\(state)\(i).png"
                animArray.append(SKTexture(imageNamed: FName))
            }
            if isRepeat == true{
                self.run(SKAction.repeatForever(SKAction.animate(with: animArray, timePerFrame: 0.1)), withKey: state)
                completion()
            }else{
                if state == "Attack"{
                    self.run(SKAction.animate(with: animArray, timePerFrame: 0.1)){
                        self.animCheck.attacking = false
                        self.action.attack = false
                        completion()
                    }
                }else if state == "Dead"{ //나중에 변경 모션으로 이름 바꾸기 Dead -> ?
                    self.run(SKAction.animate(with: animArray, timePerFrame: 0.1)){
                        self.animCheck.transforming = false
                        self.action.transform = false
                        completion()
                    }
                }
                else{
                    self.run(SKAction.animate(with: animArray, timePerFrame: 0.1), withKey: state)
                    completion()
                }
            }
        }
    }
}
