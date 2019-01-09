//
//  DungeonScene.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 23/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

protocol TransitionMenuDelegate {
    func ReturnToMenu()
}

class DungeonScene: SKScene, SKPhysicsContactDelegate {
    
    var controlDelegate: ControlDelegate?
    var transitionMenuDelegate: TransitionMenuDelegate?
    
    let player : Player
    var npc : NPC
    var mole : Enemy
    var mud: Enemy
    var snale: Enemy
    
    var boss: BossBat
    
    var ground : SKSpriteNode!
    var mapEdge: MapEdge!
    
    var playerSpeed = 400
    let limitSpeed = 300
    
    var zoom: PlayerSniperZoom!
    var zoomLevel: Int = 1
    
    var cam1 = SKCameraNode()
    let cam2 = SKCameraNode()
    let crop = SKCropNode()
    
    var bossON = false
    
    override init(size: CGSize) {
        zoom = PlayerSniperZoom()
        player = Player(pos: CGPoint(x: -800, y: 2700))
        npc = NPC()
        mole = Enemy(type: .mole, position: CGPoint(x: 872, y: -844))
        mud = Enemy(type: .mud, position: CGPoint(x: 1881, y: -2068))
        snale = Enemy(type: .snale, position: CGPoint(x: 3667, y: -1918))
        
        boss = BossBat(position: CGPoint(x: 3300, y: -600), player: player)
        super.init()
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.setup()
        }
        
    }
    required init?(coder aDecoder: NSCoder) {
        zoom = PlayerSniperZoom()
        player = Player(pos: CGPoint(x: -800, y: 2700))
        npc = NPC()
        boss = BossBat(position: CGPoint(x: 3300, y: -460), player: player)
        
        mole = Enemy(type: .mole, position: CGPoint(x: 872, y: -844))
        mud = Enemy(type: .mud, position: CGPoint(x: 1881, y: -2068))
        snale = Enemy(type: .snale, position: CGPoint(x: 3667, y: -1918))
        
        super.init(coder: aDecoder)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.setup()
        }
    }
    
    func setup(){
        self.addChild(player)
//        self.addChild(npc)
        self.addChild(mole)
        self.addChild(mud)
        self.addChild(snale)
        
        mapEdge = MapEdge(size: CGSize(width: 9600, height: 5400))
        self.addChild(mapEdge)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -25)
        
        setupCam1()
        setupCam2()        
    }

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        ZoomWindow()
        BGManager.shared.SetBG(bgName: BGList.DungeonBG, loop: true, scene: self.scene!)
    }
    override func update(_ currentTime: TimeInterval) {
        if self.camera == cam1{
            followCam()
        }else{
            zoom.position = convert(CGPoint(x: cam2.position.x, y: cam2.position.y), to: cam2)
        }
        PlayerActionUpdate()
        mole.CheckMove()
        mud.CheckMove()
        snale.CheckMove()
        boss.CheckMove()
        if (player.HP <= 0) && (!player.action.dead) {
            BGManager.shared.CurrentBG().removeFromParent()
            PlayerDie()
        }
        if (boss.batHP <= 0) && (boss.batAction.die) && (bossON){
            bossON = false            
            BGManager.shared.SetBG(bgName: BGList.DungeonBG, loop: true, scene: self.scene!)
        }
    }
    func PlayerDie(){        
        player.action.dead = true
        
        player.removeAllActions()
        player.action.attack1 = false
        player.action.attack2 = false
        player.action.attack3 = false
        player.action.dash = false
        player.action.hit = false
        player.action.idle = false
        player.action.jump = false
        player.action.onGround = false
        player.action.skill1 = false
        player.action.sniping = false
        player.action.transform = false
        player.animCheck.attacking1 = false
        player.animCheck.attacking2 = false
        player.animCheck.attacking3 = false
        player.animCheck.dash = false
        player.animCheck.hit = false
        player.animCheck.jumping = false
        player.animCheck.moving = false
        player.animCheck.skill = false
        player.animCheck.transforming = false
        
        player.physicsBody?.contactTestBitMask = PhysicsCategory.None
        player.Anim(state: .Dead, isRepeat: false, body: player.getState()) {
            self.run(SKAction.sequence([
                SKAction.wait(forDuration: 3),
                SKAction.run {
                    self.transitionMenuDelegate?.ReturnToMenu()
                }
                ]), withKey: "Die")
        }
    }
    func PlayerActionUpdate(){
        player.CheckIdle()
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
    }
    func setupCam1(){
        self.addChild(cam1)
        self.camera = cam1
        
        camera?.setScale(1.2)
        
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
        camera?.position.y = player.position.y + 200
    }
    func followCam2(changedPos: String){
        cam2.Move(changedBtn: changedPos)
    }
    func addZoom(){
        self.zoom.Reset()
        self.cam2.addChild(self.zoom)
    }
    
    func ChangeCam(normal: Bool){
        if normal == true{
            self.camera = cam1
            crop.removeFromParent()
        }else{
            self.cam2.position = CGPoint(x: player.position.x, y: player.position.y + 200)
            self.camera = cam2
            camera?.setScale(1.2)
            cam2.addChild(crop)
        }
    }
    
    func ZoomWindow(){
        let fullScreen = SKSpriteNode(color: .black, size: self.size)
        fullScreen.position = CGPoint.zero
        fullScreen.zPosition = 100
        fullScreen.alpha = 0.7
        
        let mask = SKSpriteNode(color: .white, size: self.size)
        mask.position = CGPoint.zero
        mask.zPosition = 100
        mask.alpha = 1
        
        let circle = SKShapeNode(circleOfRadius: 300)
        circle.fillColor = .white
        circle.lineWidth = 0
        circle.alpha = 1
        
        circle.blendMode = .subtract
        mask.addChild(circle)
        
        crop.maskNode = mask
        crop.addChild(fullScreen)
    }
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
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
        else if collision == PhysicsCategory.Player | PhysicsCategory.BossDoor{
            if (bossON == false) && (!boss.batAction.die){
                bossON = true
                self.addChild(boss)
                BGManager.shared.SetBG(bgName: BGList.BossBG, loop: true, scene: self.scene!)
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
