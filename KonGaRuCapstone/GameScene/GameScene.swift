//
//  GameScene.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 2018. 9. 20..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import SpriteKit
import GameplayKit

enum ColliderType: uint32 {
    case charactor
    case enemy
    case floor
    case item
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player : Player
    var ground : SKSpriteNode?
    
    var playerSpeed = 400
    let limitSpeed = 300
    
    var cam: SKCameraNode?
    
    override init(size: CGSize) {
        player = Player()
        
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        player = Player()
        
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup(){
        self.addChild(player)
        player.position.x = 0
        player.position.y = size.height / 2
        
        ground = (self.childNode(withName: "Ground") as! SKSpriteNode)
        ground?.physicsBody = SKPhysicsBody(rectangleOf: (ground?.size)!)
        ground?.physicsBody?.isDynamic = false
        
        ground?.physicsBody?.categoryBitMask = ColliderType.floor.rawValue
        ground?.physicsBody?.collisionBitMask = ColliderType.charactor.rawValue | ColliderType.enemy.rawValue
        ground?.physicsBody?.contactTestBitMask = ColliderType.charactor.rawValue | ColliderType.enemy.rawValue
        
        ground?.physicsBody?.restitution = 0.0
        ground?.physicsBody?.friction = 1
        
        cam = SKCameraNode()
        self.camera = cam
        self.addChild(cam!)
        let zoomInAction = SKAction.scale(to: 1.5, duration: 0)
        camera?.run(zoomInAction)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -15)
        
/* for test
        let skView = self.view as! SKView
        skView.showsPhysics
*/
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        player.move()
        followCam()
    }
    
    override func touchesBegan(with event: NSEvent) {
        
    }
    
    func followCam(){
        camera?.position.x = player.position.x
        camera?.position.y = player.position.y * 0.2
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.floor.rawValue || contact.bodyB.categoryBitMask == ColliderType.floor.rawValue {
            
            if contact.bodyA.categoryBitMask == ColliderType.charactor.rawValue || contact.bodyB.categoryBitMask == ColliderType.charactor.rawValue {
                player.action.onGround = true
                return
            }
        }
    }
}


