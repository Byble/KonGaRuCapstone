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
    var attack1 = false
    var attack2 = false
    var attack3 = false
    var skill1 = false
    var dead = false
    var sniping = false
    var hit = false
}
struct AnimCheck {
    var moving = false
    var attacking1 = false
    var attacking2 = false
    var attacking3 = false
    var transforming = false
    var jumping = false
    var dash = false
    var skill = false
    var hit = false
}

enum playerState: String {
    case human = "human"
    case cat = "cat"
}

enum playerActionState: String{
    case Idle = "Idle"
    case Jump = "Jump"
    case Move = "Move"
    case Run = "Run"
    case Attack1 = "Attack1"
    case Attack2 = "Attack2"
    case Attack3 = "Attack3"
    case Dead = "Dead"
    case Trans = "Trans"
    case Skill = "Skill"
    case Hit = "Hit"
}

enum currentQuest: String{
    case none = "None"
    case first = "First"
}
class Player: SKSpriteNode {
    
    private let PlayerT = SKTexture(imageNamed: "cat.png")
    private let PlayerT2 = SKTexture(imageNamed: "human.png")
    private var bodySize = CGSize()
    private var animAtlas = SKTextureAtlas()
    private var animArray = [SKTexture]()
    
    private var skillAtlas = SKTextureAtlas()
    private var skillArray = [SKTexture]()
    
    private var humanEffect = SKSpriteNode(imageNamed: "humanSkillEffect.png")
    private var effectAtlas = SKTextureAtlas()
    private var effectArray = [SKTexture]()
    
    fileprivate var moveMent: PlayerMove
    var action: Action
    var animCheck : AnimCheck
    
    private var moveSpeed = 600
    private let limitMoveSpeed = 600
    
    private var jumpSpeed = 650
    
    private var dashSpeed = 700
    fileprivate var nowState: playerState
    
    var quest: currentQuest = currentQuest.none
    var stop: Bool = false
    
    var hitTimer = Timer()    
    var HP: Int = 100
    
    private var inHit: Bool = false
    
    private let normalize: ((CGFloat) -> CGFloat) = { (input) in
        return round(input * 1000) / 1000
    }
    
    init(pos: CGPoint) {
        bodySize = CGSize(width: PlayerT.size().width, height: PlayerT.size().height)
        
        moveMent = PlayerMove()
        action = Action()
        animCheck = AnimCheck()
        nowState = playerState.cat
        quest = currentQuest.none
        
        super.init(texture: nil, color: NSColor.clear, size: bodySize)
        
        Setup(pos: pos)
    }
    required init?(coder aDecoder: NSCoder) {
        moveMent = PlayerMove()
        action = Action()
        animCheck = AnimCheck()
        nowState = playerState.cat
        quest = currentQuest.none
        
        super.init(coder: aDecoder)
    }
    private func Setup(pos: CGPoint){
        self.name = "player"
        self.texture = PlayerT
        position = pos
        self.zPosition = 0
        
        self.SetupCat()        
    }
    private func SetupCat(){
        self.texture = PlayerT
        self.size = PlayerT.size()
        
        physicsBody = SKPhysicsBody(polygonFrom: CGPath(ellipseIn: CGRect(x: -40, y: -60, width: 80, height: 120), transform: nil))
        
        physicsBody?.friction = 0.9
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = true
        physicsBody?.restitution = 0.0
        
        jumpSpeed = 550
        dashSpeed = 700
        
        physicsBody?.categoryBitMask = PhysicsCategory.Player
        physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.EdgeWall
        physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Npc | PhysicsCategory.Enemy | PhysicsCategory.Bat | PhysicsCategory.BatCrystal
        physicsBody?.usesPreciseCollisionDetection = true
    }
    private func SetupHumam(){
        self.texture = PlayerT2
        self.size = PlayerT2.size()
        
        physicsBody = SKPhysicsBody(polygonFrom: CGPath(ellipseIn: CGRect(x: -45, y: -115, width: 90, height: 230), transform: nil))
        physicsBody?.friction = 0.9
        physicsBody?.allowsRotation = false
        physicsBody?.affectedByGravity = true
        physicsBody?.restitution = 0.0
        
        jumpSpeed = 850
        dashSpeed = 350
        
        physicsBody?.categoryBitMask = PhysicsCategory.Player
        physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.EdgeWall
        physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Npc | PhysicsCategory.Enemy | PhysicsCategory.Bat | PhysicsCategory.BatCrystal
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    open func CheckIdle(){
        if !(animCheck.moving) && !(animCheck.jumping) && !(animCheck.attacking1) && !(animCheck.attacking2) && !(animCheck.attacking3) && !(animCheck.dash) && !(animCheck.transforming) && !(animCheck.skill) && !(animCheck.hit) && !(action.idle){
            action.idle = true
            
            if nowState == .cat{
                Anim(state: .Idle, isRepeat: true, body: .cat, completion: {})
            }else if nowState == .human{
                Anim(state: .Idle, isRepeat: true, body: .human, completion: {})
            }
        }
    }
    private func CheckTransAnim() -> Bool{
        if animCheck.transforming == true{
            return false
        }
        return true
    }
    private func CheckAtkAnim() -> Bool{
        if actionForKeyIsRunning(key: "Attack"){
            return false
        }
        return true
    }
    private func CheckHSkillAnim() -> Bool{
        if action.sniping == true{
            return false
        }
        return true
    }
    open func CheckMoveAnim(){
        let speedX = normalize((self.physicsBody?.velocity.dx)!)
        let speedY = normalize((self.physicsBody?.velocity.dy)!)
        if (speedX > -0.5 && speedX < 0.5){
            if (speedY > -0.5 && speedY < 0.5){
                removeAction(forKey: "Move")
                animCheck.moving = false
            }
        }
    }
    open func Jump(){
        guard !stop else{
            return
        }
        guard CheckHSkillAnim() else {
            return
        }
        guard !actionForKeyIsRunning(key: "CSkill") else{
            return
        }
        if action.onGround == true{
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpSpeed))
            action.onGround = false
            
            if !actionForKeyIsRunning(key: "Attack1") && !actionForKeyIsRunning(key: "Attack2") && !actionForKeyIsRunning(key: "Attack3"){
                if nowState == .cat{
                    Anim(state: .Jump, isRepeat: false, body: .cat) {
                        
                    }
                }else if nowState == .human{
                    Anim(state: .Jump, isRepeat: false, body: .human) {
                        
                    }
                }
            }            
        }
    }
    open func Dash(){
        guard !stop else{
            return
        }
        guard CheckHSkillAnim() else {
            return
        }
        guard !actionForKeyIsRunning(key: "CSkill") else{
            return
        }
        let nowMoveSpeed: CGFloat = abs((self.physicsBody?.velocity.dx)!)
        if self.xScale > 0{
            if Int(nowMoveSpeed) < moveSpeed{

                self.physicsBody?.velocity = CGVector(dx: -2100, dy: Int((self.physicsBody?.velocity.dy)!))
                guard CheckAtkAnim() else{
                    return
                }
                if animCheck.transforming == false{
                    if nowState == .cat{
                        let tmpDash = DashEffect(position: self.position, state: .cat)
                        self.addChild(tmpDash)
                        Anim(state: .Run, isRepeat: false, body: .cat, completion: {})
                    }else if nowState == .human{
                        let tmpDash = DashEffect(position: self.position, state: .human)
                        self.addChild(tmpDash)
                        Anim(state: .Run,isRepeat: false, body: .human, completion: {})
                    }
                }
            }
        }else{
            if Int(nowMoveSpeed) < moveSpeed{

                self.physicsBody?.velocity = CGVector(dx: 2100, dy: Int((self.physicsBody?.velocity.dy)!))
                
                guard CheckAtkAnim() else{
                    return
                }
                if animCheck.transforming == false{
                    if nowState == .cat{
                        let tmpDash = DashEffect(position: self.position, state: .cat)
                        self.addChild(tmpDash)
                        Anim(state: .Run, isRepeat: false, body: .cat, completion: {})
                    }else if nowState == .human{
                        let tmpDash = DashEffect(position: self.position, state: .human)
                        self.addChild(tmpDash)
                        Anim(state: .Run,isRepeat: false, body: .human, completion: {})
                    }
                    
                }
            }
        }
    }
    func WhileAttackRemoveAction(){
        if(self.actionForKeyIsRunning(key: "Jump")){
            removeAction(forKey: "Jump")
            animCheck.jumping = false
        }
    }
    open func Attack1(){
        guard !stop else{
            return
        }
        guard CheckTransAnim() else{
            return
        }
        guard CheckHSkillAnim() else {
            return
        }
        guard !actionForKeyIsRunning(key: "CSkill") else{
            return
        }
        if animCheck.attacking1 == false{
            WhileAttackRemoveAction()
            if nowState == .cat{
                AddAttackRange(wType: .sword, turn: .first)
                Anim(state: .Attack1, isRepeat: false, body: .cat){
                    if(self.action.attack2){
                        self.WhileAttackRemoveAction()
                        self.AddAttackRange(wType: .sword, turn: .second)
                        self.Anim(state: .Attack2, isRepeat: false, body: .cat, completion: {
                            if(self.action.attack3){
                                self.WhileAttackRemoveAction()
                                self.AddAttackRange(wType: .sword, turn: .third)
                                self.HitOut()
                                self.Anim(state: .Attack3, isRepeat: false, body: .cat, completion: {
                                    
                                })
                            }
                        })
                    }
                }
            }else if nowState == .human{
                AddAttackRange(wType: .gun, turn: .first)
                Anim(state: .Attack1, isRepeat: false, body: .human) {
                    if(self.action.attack2){
                        self.WhileAttackRemoveAction()
                        self.AddAttackRange(wType: .gun, turn: .second)
                        self.Anim(state: .Attack2, isRepeat: false, body: .human, completion: {
                            if(self.action.attack3){
                                self.WhileAttackRemoveAction()
                                self.AddAttackRange(wType: .gun, turn: .third)
                                self.Anim(state: .Attack3, isRepeat: false, body: .human, completion: {
                                    
                                })
                            }
                        })
                    }
                }
            }
        }
    }
    func AddAttackRange(wType: WeaponType, turn: Turn){
        let a1 = PlayerAttack(wType: wType, turn: turn, playerPos: self.position, xScale: self.xScale)
        if wType == .gun{
            self.parent?.addChild(a1)
        }else{
            self.addChild(a1)
        }
    }
    open func Skill(){
        guard !stop else{
            return
        }
        guard CheckTransAnim() else{
            return
        }
        if action.skill1 == false{
            self.removeAllActions()
            if nowState == .cat{
                if self.xScale > 0{
                    SkillEffect(point: CGPoint(x: self.position.x-350, y: self.position.y), body: .cat, by: -800)
                }else{
                    SkillEffect(point: CGPoint(x: self.position.x+350, y: self.position.y), body: .cat, by: 800)
                }
                Anim(state: .Skill, isRepeat: false, body: .cat, completion: {})
            }else if nowState == .human{
                Anim(state: .Skill, isRepeat: false, body: .human, completion: {})
            }
        }
    }
    
    func SkillEffect(point: CGPoint, body: playerState, by: CGFloat){
        self.physicsBody?.contactTestBitMask = PhysicsCategory.None
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.affectedByGravity = false
                
        let catEffect = SKSpriteNode(imageNamed: "catSkillEffect.png")
        catEffect.position = point
        catEffect.size = CGSize(width: catEffect.size.width*3.5, height: catEffect.size.height*2.5)
        parent?.addChild(catEffect)
        
        catEffect.physicsBody = SKPhysicsBody(rectangleOf: catEffect.size)
        catEffect.physicsBody?.categoryBitMask = PhysicsCategory.GhostShot
        catEffect.physicsBody?.collisionBitMask = PhysicsCategory.None
        catEffect.physicsBody?.contactTestBitMask = PhysicsCategory.Bat | PhysicsCategory.Enemy
        catEffect.physicsBody?.affectedByGravity = false
        
        self.run(action: SKAction.moveBy(x: by, y: 0, duration: 0.3), withKey: "nn"){

            self.skillArray.removeAll()
            self.skillAtlas = SKTextureAtlas(named: "\(body)SkillEffect")
            for i in 1...self.skillAtlas.textureNames.count{
                let FName =  "\(body)SkillEffect_\(i).png"
                self.skillArray.append(SKTexture(imageNamed: FName))
            }

            catEffect.run(action: SKAction.animate(with: self.skillArray, timePerFrame: 0.2), withKey: "catSkillEffect") {
                catEffect.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: 0.2),
                        SKAction.run { [weak self] in if ((self?.actionForKeyIsRunning(key: "CSkill"))!){
                            self?.animCheck.jumping = false
                            self?.animCheck.moving = false
                            self?.animCheck.skill = false
                            self?.action.skill1 = false
                            self?.removeAction(forKey: "CSkill")
                            }},
                        SKAction.run { [weak self] in
                            self?.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Npc | PhysicsCategory.Enemy | PhysicsCategory.Bat | PhysicsCategory.BatCrystal
                            self?.physicsBody?.affectedByGravity = true
                        },
                        SKAction.removeFromParent()
                        ]))
            }
        }
        
        
    }
    
    open func AttackCheck(){
        if !(self.actionForKeyIsRunning(key: "Attack1")){
            animCheck.attacking1 = false
        }
        if !(self.actionForKeyIsRunning(key: "Attack2")){
            animCheck.attacking2 = false
        }
        if !(self.actionForKeyIsRunning(key: "Attack3")){
            animCheck.attacking3 = false
        }
    }
    open func ActionUpdate(){
        if (action.onGround) && (animCheck.jumping) && (!animCheck.transforming){
            removeAction(forKey: "Jump")
            animCheck.jumping = false
        }
    }
    
    open func Transform(completion: @escaping (_ type: playerState)->Void){
        guard !stop else{
            return
        }
        guard CheckHSkillAnim() else {
            return
        }
        guard !actionForKeyIsRunning(key: "CSkill") else{
            return
        }
        if animCheck.transforming == false && animCheck.attacking1 == false{
            if nowState == .cat{
                self.run(SKAction.moveTo(y: self.position.y+PlayerT.size().height, duration: 0))
                action.onGround = false
                animCheck.jumping = true
                self.nowState = playerState.human
                Anim(state: .Trans, isRepeat: false, body: .cat) {
                    self.SetupHumam()
                    completion(.human)
                    if self.moveMent.leftMove || self.moveMent.rightMove{
                        self.Anim(state: .Move, isRepeat: true, body: .human, completion: {})
                    }
                }
            }else if nowState == .human{
                self.run(SKAction.moveTo(y: self.position.y+PlayerT2.size().height, duration: 0))
                action.onGround = false
                animCheck.jumping = true
                self.nowState = playerState.cat
                Anim(state: .Trans, isRepeat: false, body: .human) {
                    self.SetupCat()
                    completion(.cat)
                    if self.moveMent.leftMove || self.moveMent.rightMove{
                        self.Anim(state: .Move, isRepeat: true, body: .cat, completion: {})
                    }
                }
            }
        }
    }

    @objc func HitIn(enemy: SKNode){
        if HP > 0{
            HP -= 10
        }
        if enemy.position.x < self.position.x{
            if enemy.name == "crystal"{
                self.physicsBody?.velocity = CGVector(dx: 1250, dy: Int((self.physicsBody?.velocity.dy)!))
            }else{
                self.physicsBody?.velocity = CGVector(dx: 1500, dy: Int((self.physicsBody?.velocity.dy)!))
            }
        }else{
            if enemy.name == "crystal"{
                self.physicsBody?.velocity = CGVector(dx: -1250, dy: Int((self.physicsBody?.velocity.dy)!))
            }else{
                self.physicsBody?.velocity = CGVector(dx: -1500, dy: Int((self.physicsBody?.velocity.dy)!))
            }
        }

        if !animCheck.hit{
            if nowState == .cat{
                Anim(state: .Hit, isRepeat: false, body: .cat) {
                    self.RunHitTimer()
                }
            }
            else if nowState == .human{
                Anim(state: .Hit, isRepeat: false, body: .human) {
                    self.RunHitTimer()
                }
            }
        }
    }
    func HitOut(){
        hitTimer.invalidate()
        action.hit = false
        
    }
    func RunHitTimer(){
        if action.hit{
            hitTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(HitIn), userInfo: nil, repeats: false)
        }
    }
    open func MoveUpdate(){
        guard !stop else{
            return
        }
        guard CheckHSkillAnim() else {
            return
        }
        guard !actionForKeyIsRunning(key: "CSkill") else{
            return
        }
        let nowMoveSpeed: CGFloat = abs((self.physicsBody?.velocity.dx)!)
        if moveMent.leftMove == true{
            
            if Int(nowMoveSpeed) < limitMoveSpeed{
                if self.xScale < 0{
                    self.xScale = 1
                }
                self.physicsBody?.velocity = CGVector(dx: -moveSpeed, dy: Int((self.physicsBody?.velocity.dy)!))

                if !(animCheck.transforming) && !(animCheck.jumping) && !(animCheck.attacking1) && !(animCheck.attacking2) && !(animCheck.attacking3){
                    if animCheck.moving == false{
                        animCheck.moving = true
                        if nowState == .cat{
                            Anim(state: .Move, isRepeat: true, body: .cat, completion: {})
                        }else if nowState == .human{
                            Anim(state: .Move, isRepeat: true, body: .human, completion: {})
                        }
                    }
                }
            }
        }
        if moveMent.rightMove == true{
            if Int(nowMoveSpeed) < limitMoveSpeed{
                if self.xScale > 0{
                    self.xScale = -1
                }
                self.physicsBody?.velocity = CGVector(dx: moveSpeed, dy: Int((self.physicsBody?.velocity.dy)!))

                if !(animCheck.transforming) && !(animCheck.jumping) && !(animCheck.attacking1) && !(animCheck.attacking2) && !(animCheck.attacking3){
                    if animCheck.moving == false{
                        animCheck.moving = true
                        if nowState == .cat{
                            Anim(state: .Move, isRepeat: true, body: .cat, completion: {})
                        }else if nowState == .human{
                            Anim(state: .Move, isRepeat: true, body: .human, completion: {})
                        }
                    }
                }
            }
        }
        
    }
    func Anim(state: playerActionState, isRepeat: Bool, body: playerState, completion: @escaping () -> ()){
        animArray.removeAll()
        
        if action.dead == false{
            animAtlas = SKTextureAtlas(named: "\(body)\(state)")
            for i in 1...animAtlas.textureNames.count{
                let FName =  "\(body)\(state)_\(i).png"
                animArray.append(SKTexture(imageNamed: FName))
            }
            if isRepeat == true{
                switch state{
                case .Idle:
                    self.removeAllActions()
                    let seq = SKAction.sequence([SKAction.animate(with: animArray, timePerFrame: 0.1), SKAction.wait(forDuration: 1)])
                    self.run(SKAction.repeatForever(seq), withKey: "Idle")
                    completion()
                case .Move:
                    action.idle = false
                    self.run(action: SKAction.repeatForever(SKAction.animate(with: animArray, timePerFrame: 0.1)), withKey: "Move") {
                        completion()
                    }
                default:
                    
                    completion()
                }
            }else{
                switch state{
                case .Attack1:
                    animCheck.moving = false
                    action.idle = false
                    self.animCheck.attacking1 = true
                    self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.1), withKey: "Attack1") {
                        self.action.attack1 = false
                        self.animCheck.attacking1 = false
                        completion()
                    }
                case .Attack2:
                    animCheck.moving = false
                    action.idle = false
                    self.animCheck.attacking2 = true
                    if body == .cat{
                        self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.1), withKey: "Attack2") {
                            self.action.attack2 = false
                            self.animCheck.attacking2 = false
                            completion()
                        }
                    }else if body == .human{
                        self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.1), withKey: "Attack2") {
                            self.action.attack2 = false
                            self.animCheck.attacking2 = false
                            completion()
                        }
                    }
                case .Attack3:
                    animCheck.moving = false
                    action.idle = false
                    self.animCheck.attacking3 = true
                    if body == .cat{
                        self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.08), withKey: "Attack3") {
                            self.action.attack3 = false
                            self.animCheck.attacking3 = false
                            completion()
                        }
                    }else if body == .human{
                        self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.08), withKey: "Attack3") {
                            self.action.attack3 = false
                            self.animCheck.attacking3 = false
                            completion()
                        }
                    }
                    
                case .Skill:
                    animCheck.skill = true
                    action.idle = false
                    if body == .human{
                        action.sniping = true
                        self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.15), withKey: "HSkill") {
                            completion()
                        }
                    }else if body == .cat{
                        action.skill1 = true
                        self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.15), withKey: "CSkill") {
                            self.animCheck.skill = false
                            self.action.skill1 = false
                            completion()
                        }
                    }
                    
                case .Trans:
                    self.removeAllActions()
                    animCheck.transforming = true
                    action.transform = true
                    action.idle = false
                    self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.05), withKey: "Trans") {
                        self.animCheck.transforming = false
                        self.action.transform = false
                        completion()
                    }
                case .Jump:
                    animCheck.jumping = true
                    action.idle = false
                    self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.08), withKey: "Jump") {
//                        self.animCheck.jumping = false
                        completion()
                    }
                case .Run:
                    animCheck.moving = false
                    action.idle = false
                    animCheck.dash = true
                    if nowState == .cat{
                        self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.15), withKey: "Dash") {
                            self.animCheck.dash = false
                            completion()
                        }
                    }else{
                        self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.17), withKey: "Dash") {
                            self.animCheck.dash = false
                            completion()
                        }
                    }
                case .Hit:
                    animCheck.hit = true
                    action.idle = false
                    self.run(action: SKAction.animate(with: animArray, timePerFrame: 0.5), withKey: "Hit") {
                        self.animCheck.hit = false
                        completion()
                    }
                default:
                    completion()
                }
            }
        }else{
            animAtlas = SKTextureAtlas(named: "\(body)\(state)")
            for i in 1...animAtlas.textureNames.count{
                let FName =  "\(body)\(state)_\(i).png"
                animArray.append(SKTexture(imageNamed: FName))
            }
            switch state{
            case .Dead:
                self.run(SKAction.animate(with: animArray, timePerFrame: 0.1)){
                    completion()
                }
            default:
                break
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
    func getState() -> playerState{
        return self.nowState
    }
    func getInHit() -> Bool{
        return self.inHit
    }
    func setInHit(inhit: Bool){
        self.inHit = inhit
    }
    func setActionInHit(inActionHit: Bool){
        self.action.hit = inActionHit
    }
}
