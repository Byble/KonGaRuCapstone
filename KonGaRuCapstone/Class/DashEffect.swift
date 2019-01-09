//
//  DashEffect.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 23/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

enum DashState{
    case cat
    case human
}
class DashEffect: SKSpriteNode {
    
    let dashT = SKTexture(imageNamed: "dashEffect.png")
    private var effectAtlas = SKTextureAtlas()
    private var effectArray = [SKTexture]()
    
    init(position: CGPoint, state: DashState) {
        super.init(texture: dashT, color: NSColor.clear, size: dashT.size())
        Setup(pos: position, state: state)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func Setup(pos: CGPoint, state: DashState){
        if state == .cat{
            self.position = CGPoint(x: 125, y: -25)
        }else{
            self.position = CGPoint(x: 150, y: -75)
        }
        Anim {
            self.removeFromParent()
        }
    }
    private func Anim(completion: @escaping ()->()){
        effectArray.removeAll()
        
        effectAtlas = SKTextureAtlas(named: "DashEffect")
        for i in 1...effectAtlas.textureNames.count{
            let FName =  "dashEffect_\(i).png"
            effectArray.append(SKTexture(imageNamed: FName))
        }
        self.run(SKAction.animate(with: effectArray, timePerFrame: 0.13)) {
            completion()
        }
    }
}
