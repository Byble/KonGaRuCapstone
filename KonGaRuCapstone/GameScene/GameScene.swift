//
//  GameScene.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 2018. 9. 20..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player : Player
    var npc : NPC
    var mole : Enemy
    
    var ground : SKSpriteNode!
    var map: SKSpriteNode!
    
    var playerSpeed = 400
    let limitSpeed = 300
    
    var cam: SKCameraNode?
    
    override init(size: CGSize) {
        player = Player()
        npc = NPC()
        mole = Enemy(type: .snale, position: CGPoint(x: 300, y: 100))
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        player = Player()
        npc = NPC()
        mole = Enemy(type: .snale, position: CGPoint(x: 300, y: 100))
        
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup(){
        self.addChild(player)
        self.addChild(npc)
        self.addChild(mole)
        
        map = (childNode(withName: "Map") as! SKSpriteNode)
//        map.physicsBody = SKPhysicsBody(edgeLoopFrom: map.frame)
        ground = (childNode(withName: "Ground") as! SKSpriteNode)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.Npc | PhysicsCategory.Player | PhysicsCategory.Enemy
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.Npc | PhysicsCategory.Player | PhysicsCategory.Enemy
        
        ground.physicsBody?.restitution = 0.0
        ground.physicsBody?.friction = 1
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -25)
        
        setupCam()
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        followCam()
        PlayerActionUpdate()
        mole.CheckMove()
    }

    func PlayerActionUpdate(){
        if !player.stop{
            player.zRotation = 0
            player.CheckMoveAnim()
            player.MoveUpdate()
            player.ActionUpdate()
            player.AttackCheck()
        }else{
            player.action.attack1 = false
            player.action.attack2 = false
            player.action.attack3 = false
            player.action.onGround = true
            player.action.skill1 = false
            player.action.sniping = false
            player.action.transform = false
            player.action.idle = false
            player.animCheck.attacking1 = false
            player.animCheck.attacking2 = false
            player.animCheck.attacking3 = false
            player.animCheck.dash = false
            player.animCheck.jumping = false
            player.animCheck.moving = false
            player.animCheck.skill = false
            player.animCheck.transforming = false
        }
        player.CheckIdle()
    }
    func setupCam(){
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam!)
        let zoomInAction = SKAction.scale(to: 1, duration: 0)
        camera?.run(zoomInAction)
    }
    func followCam(){
        let cX = Float(player.position.x)
        let lP = Float((map.frame.width) - ((view?.frame.width)!) - 200)
        if (cX >= 0) && (cX <= lP){
            camera?.position.x = player.position.x
        }
        camera?.position.y = player.position.y*0.1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Ground | PhysicsCategory.Player{
            player.setActionOnGround(isOn: true)
        }
        else if collision == PhysicsCategory.Player | PhysicsCategory.Npc{
            if player.quest == currentQuest.none{
                npc.PlayNpcStory(camera: camera!,scene: self, player: player)
            }
        }else if collision == PhysicsCategory.Player | PhysicsCategory.Enemy{
            //player hited
            //enemy anim
            mole.Attack()
            
        }
        
        //if enemy랑 player가 부딪혔을때
        //AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
    func didEnd(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.Player | PhysicsCategory.Enemy{
            mole.StateManager()
        }
    }
}


