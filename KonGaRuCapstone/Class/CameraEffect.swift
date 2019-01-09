//
//  CameraEffect.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 21/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit

extension SKCameraNode{
    func shakeCamera(layer:SKCameraNode, duration:Float) {
        let amplitudeX:Float = 10;
        let amplitudeY:Float = 6;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        layer.run(actionSeq);
    }
    func Move(changedBtn: String){    
        let parseString = changedBtn.components(separatedBy: ",")
        let tmpX = CGFloat(NSString(string: parseString[0]).floatValue) / 16
        let tmpY = CGFloat(NSString(string: parseString[1]).floatValue) / 12
        let moveAction = SKAction.moveBy(x: tmpX, y: -tmpY, duration: 0.1)
        self.run(moveAction)
    }
}
