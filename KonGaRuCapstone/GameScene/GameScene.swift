//
//  GameScene.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 2018. 9. 20..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol ControlDelegate {
    func MakeVibe()
}

protocol TransitionDelegate {
    func GoDungeon()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var transitionDelegate: TransitionDelegate?
    var controlDelegate: ControlDelegate?
    
    let player : Player
    var npc : NPC
    var mole : Enemy
    var boss: BossBat
    let teleport: Teleport
    
    var ground : SKSpriteNode!
    var mapEdge: MapEdge!
    
    var playerSpeed = 400
    let limitSpeed = 300
    
    var zoom: PlayerSniperZoom!
    var zoomLevel: Int = 1
    
    var cam1 = SKCameraNode()
    let cam2 = SKCameraNode()
    let crop = SKCropNode()
    
    override init(size: CGSize) {
        zoom = PlayerSniperZoom()
        player = Player(pos: CGPoint(x: 150, y: 100))
        npc = NPC()
        mole = Enemy(type: .mud, position: CGPoint(x: 300, y: 100))
        boss = BossBat(position: CGPoint(x: 800, y: 400), player: player)
        teleport = Teleport(pos: CGPoint(x: 6430, y: -400))
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        zoom = PlayerSniperZoom()
        player = Player(pos: CGPoint(x: 150, y: 100))
        npc = NPC()
        mole = Enemy(type: .snale, position: CGPoint(x: 300, y: 100))
        boss = BossBat(position: CGPoint(x: 800, y: 400), player: player)
        teleport = Teleport(pos: CGPoint(x: 6430, y: -400))
        super.init(coder: aDecoder)        
        setup()
    }

    func setup(){
        self.addChild(player)
        self.addChild(npc)
//        self.addChild(mole)
//        self.addChild(boss)
        self.addChild(teleport)
        
        mapEdge = MapEdge(size: CGSize(width: 7500, height: 1500))
        self.addChild(mapEdge)
        
        ground = (childNode(withName: "Ground") as! SKSpriteNode)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.Npc | PhysicsCategory.Player | PhysicsCategory.Enemy
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.Npc | PhysicsCategory.Player | PhysicsCategory.Enemy
        
        ground.physicsBody?.restitution = 0.0
        ground.physicsBody?.friction = 1
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -25)
        
        setupCam1()
        setupCam2()                
    }
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        ZoomWindow()
        BGManager.shared.SetBG(bgName: BGList.TownBG, loop: true, scene: self.scene!)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if self.camera == cam1{
            followCam()
        }else{
            zoom.position = convert(CGPoint(x: cam2.position.x, y: cam2.position.y), to: cam2)
        }
        PlayerActionUpdate()
        mole.CheckMove()
        boss.CheckMove()
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
    func setupCam1(){
        self.addChild(cam1)
        self.camera = cam1
        
        camera?.setScale(1.1)
                
    }
    func setupCam2(){
        cam2.physicsBody = SKPhysicsBody.init(texture: zoom.aimT, size: zoom.aimT.size())
        cam2.physicsBody?.categoryBitMask = PhysicsCategory.CameraEdge
        cam2.physicsBody?.collisionBitMask = PhysicsCategory.EdgeWall
        cam2.physicsBody?.affectedByGravity = false
        cam2.physicsBody?.allowsRotation = false
        cam2.physicsBody?.usesPreciseCollisionDetection = true
        cam2.physicsBody?.friction = 0
        cam2.physicsBody?.restitution = 0
        self.addChild(cam2)
    }
    func followCam(){
        let cX = Float(player.position.x)
        let lP = Float((mapEdge.frame.width) - ((view?.frame.width)!) - 300)
        if (cX >= 100) && (cX <= lP){
            camera?.position.x = player.position.x
        }
        camera?.position.y = player.position.y*0.1
    }
    func followCam2(changedPos: String){
        cam2.Move(changedBtn: changedPos)
    }
    func addZoom(){
        self.cam2.addChild(self.zoom)
    }
    
    func ChangeCam(normal: Bool){
        if normal == true{
            self.camera = cam1
            crop.removeFromParent()
        }else{
            self.cam2.position = CGPoint(x: player.position.x, y: player.position.y + 200)
            self.camera = cam2
            camera?.setScale(1.1)
            cam2.addChild(crop)
        }
    }
    
    func ZoomWindow(){
        let fullScreen = SKSpriteNode(color: .black, size: self.size)
        fullScreen.position = CGPoint.zero
        fullScreen.zPosition = 100
        fullScreen.alpha = 0.7
        
        //let's make a mask to punch circles in our shape
        let mask = SKSpriteNode(color: .white, size: self.size)
        mask.position = CGPoint.zero
        mask.zPosition = 100
        mask.alpha = 1
        
        let circle = SKShapeNode(circleOfRadius: 300)
        circle.fillColor = .white
        circle.lineWidth = 0
        circle.alpha = 1
        
        //let circle_mask = SKSpriteNode()
        circle.blendMode = .subtract
        mask.addChild(circle)
        
        //let's create the node to place on screen
        crop.maskNode = mask
        crop.addChild(fullScreen)
    }
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Player | PhysicsCategory.Teleport {
            self.transitionDelegate?.GoDungeon()
        }
        
        if collision == PhysicsCategory.Ground | PhysicsCategory.Player{
            if(contact.bodyA.node?.name == "player"){
                (contact.bodyA.node as! Player).setActionOnGround(isOn: true)
            }else{
                (contact.bodyB.node as! Player).setActionOnGround(isOn: true)
            }
        }
        else if collision == PhysicsCategory.Player | PhysicsCategory.Npc{
            if player.quest == currentQuest.none{
                npc.PlayNpcStory(camera: camera!,scene: self, player: player)
            }
        }
        if collision == PhysicsCategory.Player | PhysicsCategory.Enemy{
            if(contact.bodyA.node?.name == "enemy"){
                (contact.bodyA.node as! Enemy).Attack(player: player){
                    self.player.run(SKAction.sequence([
                        SKAction.run {
                            [weak self] in
                            self?.player.setInHit(inhit: true)
                        },
                        SKAction.wait(forDuration: 0.4),
                        SKAction.run {
                            [weak self] in
                            if self?.player.getInHit() == true{
                                self?.player.setActionInHit(inActionHit: true)
                                self?.player.HitIn(enemy: contact.bodyA.node!)
                                self?.controlDelegate?.MakeVibe()
                            }
                        }
                        ]))
                }
            }else{
                (contact.bodyB.node as! Enemy).Attack(player: player){
                    self.player.run(SKAction.sequence([
                        SKAction.run {
                            [weak self] in
                            self?.player.setInHit(inhit: true)
                        },
                        SKAction.wait(forDuration: 0.2),
                        SKAction.run {
                            [weak self] in
                            if self?.player.getInHit() == true{
                                self?.player.setActionInHit(inActionHit: true)
                                self?.player.HitIn(enemy: contact.bodyB.node!)
                                self?.controlDelegate?.MakeVibe()
                            }
                        }
                        ]))
                }
            }
            
            return
        }
        if collision == PhysicsCategory.PlayerAttack | PhysicsCategory.Enemy{
            if(contact.bodyA.node?.name == "enemy"){
                (contact.bodyA.node as! Enemy).HitInAttack(player: player)
            }else{
                (contact.bodyB.node as! Enemy).HitInAttack(player: player)
            }
            
            return
        }
        if collision == PhysicsCategory.Zoom | PhysicsCategory.Enemy{
            if(contact.bodyA.node?.name == "zoom"){
                (contact.bodyA.node as! PlayerSniperZoom).OnEnemy()
            }else{
                (contact.bodyB.node as! PlayerSniperZoom).OnEnemy()
            }
            return
        }
        if collision == PhysicsCategory.ZoomShot | PhysicsCategory.Enemy{
            if(contact.bodyA.node?.name == "enemy"){
                (contact.bodyA.node as! Enemy).HitInSkill(player: player)
            }else{
                (contact.bodyB.node as! Enemy).HitInSkill(player: player)
            }
            
            return
        }
        if collision == PhysicsCategory.Player | PhysicsCategory.Bat{
            if (!self.player.action.skill1 && !self.player.action.sniping){
                
                if(contact.bodyA.node?.name == "bat"){
                    if !(contact.bodyA.node as! BossBat).batAction.die{
                        (contact.bodyA.node as! BossBat).Attack(player: player){
                            self.player.run(SKAction.sequence([
                                SKAction.run {
                                    [weak self] in
                                    self?.player.setInHit(inhit: true)
                                    self?.player.setActionInHit(inActionHit: true)
                                    self?.player.HitIn(enemy: contact.bodyA.node!)
                                    self?.controlDelegate?.MakeVibe()
                                }
                                ]))
                        }
                    }
                }else{
                    if !(contact.bodyB.node as! BossBat).batAction.die{
                        (contact.bodyB.node as! BossBat).Attack(player: player){
                            self.player.run(SKAction.sequence([
                                SKAction.run {
                                    [weak self] in
                                    self?.player.setInHit(inhit: true)
                                    self?.player.setActionInHit(inActionHit: true)
                                    self?.player.HitIn(enemy: contact.bodyB.node!)
                                    self?.controlDelegate?.MakeVibe()
                                }
                                ]))
                        }
                    }
                }
            }
            return
        }
        if collision == PhysicsCategory.Player | PhysicsCategory.BatCrystal{
            if(contact.bodyA.node?.name == "crystal"){
                self.player.run(SKAction.run {
                    [weak self] in
                    self?.player.setInHit(inhit: true)
                    self?.player.setActionInHit(inActionHit: true)
                    self?.player.HitIn(enemy: contact.bodyA.node!)
                    self?.controlDelegate?.MakeVibe()
                })
            }else{
                self.player.run(SKAction.run {
                    [weak self] in
                    self?.player.setInHit(inhit: true)
                    self?.player.setActionInHit(inActionHit: true)
                    self?.player.HitIn(enemy: contact.bodyB.node!)
                    self?.controlDelegate?.MakeVibe()
                })
            }
            return
        }
        if collision == PhysicsCategory.PlayerAttack | PhysicsCategory.Bat{
            if(contact.bodyA.node?.name == "bat"){
                (contact.bodyA.node as! BossBat).HitInAttack()
            }else{
                (contact.bodyB.node as! BossBat).HitInAttack()
            }
            return
        }
        if collision == PhysicsCategory.Zoom | PhysicsCategory.Bat{
            if(contact.bodyA.node?.name == "zoom"){
                (contact.bodyA.node as! PlayerSniperZoom).OnEnemy()
            }else{
                (contact.bodyB.node as! PlayerSniperZoom).OnEnemy()
            }
            return
        }
        if collision == PhysicsCategory.ZoomShot | PhysicsCategory.Bat{
            if(contact.bodyA.node?.name == "bat"){
                (contact.bodyA.node as! BossBat).HitInSkill()
            }else{
                (contact.bodyB.node as! BossBat).HitInSkill()
            }
            return
        }
        if collision == PhysicsCategory.GhostShot | PhysicsCategory.Bat{
            if(contact.bodyA.node?.name == "bat"){
                (contact.bodyA.node as! BossBat).HitInSkill()
            }else{
                (contact.bodyB.node as! BossBat).HitInSkill()
            }
            return
        }
        if collision == PhysicsCategory.GhostShot | PhysicsCategory.Enemy{
            if(contact.bodyA.node?.name == "enemy"){
                (contact.bodyA.node as! Enemy).HitInSkill(player: player)
            }else{
                (contact.bodyB.node as! Enemy).HitInSkill(player: player)
            }
            return
        }        
    }
    func didEnd(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Player | PhysicsCategory.Enemy{
            if(contact.bodyA.node?.name == "player"){
                (contact.bodyB.node as! Enemy).run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.5),
                    SKAction.run {
                        (contact.bodyB.node as! Enemy).StateManager()
                    }
                    ]))
                (contact.bodyA.node as! Player).HitOut()
                (contact.bodyA.node as! Player).setInHit(inhit: false)
            }else{
                (contact.bodyA.node as! Enemy).run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.5),
                    SKAction.run {
                        (contact.bodyA.node as! Enemy).StateManager()
                    }
                    ]))
                (contact.bodyB.node as! Player).HitOut()
                (contact.bodyB.node as! Player).setInHit(inhit: false)
            }
            return
        }
        if collision == PhysicsCategory.Player | PhysicsCategory.Bat{
            if(contact.bodyA.node?.name == "player"){
                (contact.bodyA.node as! Player).HitOut()
                (contact.bodyA.node as! Player).setInHit(inhit: false)
            }else{
                (contact.bodyB.node as! Player).HitOut()
                (contact.bodyB.node as! Player).setInHit(inhit: false)
            }
            return
        }
        if collision == PhysicsCategory.Player | PhysicsCategory.BatCrystal{
            if(contact.bodyA.node?.name == "player"){
                (contact.bodyA.node as! Player).HitOut()
                (contact.bodyA.node as! Player).setInHit(inhit: false)
            }else{
                (contact.bodyB.node as! Player).HitOut()
                (contact.bodyB.node as! Player).setInHit(inhit: false)
            }
            return
        }
        if collision == PhysicsCategory.PlayerAttack | PhysicsCategory.Enemy{
            if(contact.bodyA.node?.name == "enemy"){
                (contact.bodyA.node as! Enemy).HitOut()
            }else{
                (contact.bodyB.node as! Enemy).HitOut()
            }
            return
        }
        if collision == PhysicsCategory.Enemy | PhysicsCategory.Zoom{
            if(contact.bodyA.node?.name == "zoom"){
                (contact.bodyA.node as! PlayerSniperZoom).OutEnemy()
            }else{
                (contact.bodyB.node as! PlayerSniperZoom).OutEnemy()
            }
            return
        }
        if collision == PhysicsCategory.PlayerAttack | PhysicsCategory.Bat{
            if(contact.bodyA.node?.name == "bat"){
                (contact.bodyA.node as! BossBat).HitOut()
            }else{
                (contact.bodyB.node as! BossBat).HitOut()
            }
            return
        }
        if collision == PhysicsCategory.Zoom | PhysicsCategory.Bat{
            if(contact.bodyA.node?.name == "zoom"){
                (contact.bodyA.node as! PlayerSniperZoom).OutEnemy()
            }else{
                (contact.bodyB.node as! PlayerSniperZoom).OutEnemy()
            }
            return
        }
        if collision == PhysicsCategory.ZoomShot | PhysicsCategory.Enemy{
            if(contact.bodyA.node?.name == "enemy"){
                (contact.bodyA.node as! Enemy).HitOut()
            }else{
                (contact.bodyB.node as! Enemy).HitOut()
            }
            return
        }
    }
}


