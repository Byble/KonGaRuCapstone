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
    static let Enemy: uint32 = 0b1000
}
