//
//  ViewController.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 2018. 9. 20..
//  Copyright © 2018년 MGHouse. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class MainViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    @IBOutlet weak var connectionLabel: NSTextField!
    
    let controllService = ControllerService()
    
    override func viewWillAppear() {
//        enterFullScreen()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controllService.delegate = self
        
        if let view = self.skView {
//            view.showsPhysics = true
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill

                view.presentScene(scene)
            }            
            view.ignoresSiblingOrder = true
        }
    }
    @IBAction func exitBtn(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func enterFullScreen(){
        let presOptions: NSApplication.PresentationOptions = [.fullScreen, .autoHideMenuBar]
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions: presOptions]
        view.enterFullScreenMode(NSScreen.main!, withOptions: optionsDictionary)
        view.wantsLayer = true
    }
}

extension MainViewController : ControllerServiceDelegate {
    func connectedDevicesChanged(manager: ControllerService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
//            self.connectionLabel.stringValue = "연결됨";
        }
    }    
    func buttonChanged(manager: ControllerService, changedBtn: String) {
        if let game = skView.scene as? GameScene{
            OperationQueue.main.addOperation {
                guard game.player.action.skill1 == false else{
                    return
                }
                switch changedBtn {
                case "L":
                    game.player.setPlayerMoveLeft(isMoving: true)
                case "LUp":
                    game.player.setPlayerMoveLeft(isMoving: false)
                case "R":
                    game.player.setPlayerMoveRight(isMoving: true)
                case "RUp":
                    game.player.setPlayerMoveRight(isMoving: false)
                case "Jp":
                    game.player.Jump()
                case "A1":
                    game.player.Attack1()
                    game.player.action.attack1 = true
                case "A2":
                    game.player.action.attack2 = true
                case "A3":
                    game.player.action.attack3 = true
                case "S":
                    game.player.Skill()
                case "D":
                    game.player.Dash()
                case "T":
                    game.player.Transform()
                default:
                    NSLog("%@", "Unknown value received")
                }
            }
        }
    }
}
