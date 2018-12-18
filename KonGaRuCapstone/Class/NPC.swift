//
//  NPC.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 17/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Foundation
import Cocoa
import SpriteKit

class NPC: SKSpriteNode {
    
    private let npcT = SKTexture(imageNamed: "npc1.png")
    private var bodySize = CGSize()
    
    var storyLabel: SKLabelNode!
    
    let storyTxt: [String] = [
        "퀘스트를 받겠는가 흑우여",
        "잉간이 되고싶으면 재료가 마니 필요하다네",
        "자네는 그럴 용기가 없어 보이긴 하군",
        "흑우여",
        "그래도 잉간이 되고 싶으면",
        "재료를 구해보게나"
    ]
    
    init() {
        bodySize = CGSize(width: npcT.size().width, height: npcT.size().height)
        super.init(texture: nil, color: NSColor.clear, size: bodySize)
        SetupNpc()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func SetupNpc(){
        self.texture = npcT
        self.size = npcT.size()
        self.position = CGPoint(x: 2567, y: -394.847)
        self.zPosition = 0
        let collSize = CGSize(width: npcT.size().width*2, height: npcT.size().height)
        physicsBody = SKPhysicsBody(rectangleOf: collSize, center: CGPoint(x: 0, y: self.centerRect.height))
        
        physicsBody?.affectedByGravity = false
        
        physicsBody?.categoryBitMask = PhysicsCategory.Npc
        physicsBody?.collisionBitMask = PhysicsCategory.None
        physicsBody?.contactTestBitMask = PhysicsCategory.Player
    }
    
    func PlayNpcStory(camera: SKCameraNode, scene: SKScene, player: Player){
        player.stop = true
        player.quest = currentQuest.first
        storyLabel = SKLabelNode(fontNamed: "Chalkduster")
        storyLabel.horizontalAlignmentMode = .center
        storyLabel.position = CGPoint(x: scene.frame.midX, y: scene.size.height*0.3)
        camera.addChild(storyLabel)
        DispatchQueue.global().async {
            for txt in self.storyTxt{
                DispatchQueue.main.async {
                    self.storyLabel.text = txt
                }
                sleep(2)
            }
            self.storyLabel.removeFromParent()
            player.stop = false
        }
    }
}
