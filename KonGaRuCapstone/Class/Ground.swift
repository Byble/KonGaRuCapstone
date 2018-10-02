//
//  Ground.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 2018. 9. 20..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

class Ground: SKSpriteNode {
    init() {
        let groundSize = CGSize(width: 40, height: 40)
        
        super.init(texture: nil, color: NSColor.yellow, size: groundSize)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setup(){
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody!.isDynamic = false
    }
}
