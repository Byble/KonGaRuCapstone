//
//  PhysicsCategory.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 17/12/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Foundation

struct PhysicsCategory{
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Ground: UInt32 = 0b10
    static let Npc: UInt32 = 0b100
    static let Enemy: UInt32 = 0b1000
    static let PlayerAttack: UInt32 = 0b10000
    static let CameraEdge: UInt32 = 0b100000
    static let Zoom: UInt32 = 0b1000000
    static let ZoomShot: UInt32 = 0b10000000
    static let Bat: UInt32 = 0b100000000
    static let GhostShot: UInt32 = 0b1000000000
    static let BatCrystal: UInt32 = 0b10000000000
    static let MapEdge: UInt32 = 0b100000000000
    static let Wall: UInt32 = 0b1000000000000
    static let EdgeWall: UInt32 = 0b10000000000000
    static let Teleport: UInt32 = 0b100000000000000
    static let BossDoor: UInt32 = 0b1000000000000000
}
