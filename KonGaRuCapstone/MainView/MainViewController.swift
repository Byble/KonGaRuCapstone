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
        enterFullScreen()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controllService.delegate = self
        
        if let view = self.skView {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }
    
    func enterFullScreen(){
        let presOptions: NSApplication.PresentationOptions = [.fullScreen, .autoHideMenuBar]
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions: presOptions]
        view.enterFullScreenMode(NSScreen.main!, withOptions: optionsDictionary)
        view.wantsLayer = true
    }
    
    func move(direction: String){
        if let game = skView.scene as? GameScene{
            switch direction {
            case "L":
                game.player.moveMent.leftMove = true
            case "LUp":
                game.player.moveMent.leftMove = false
            case "R":
                game.player.moveMent.rightMove = true
            case "RUp":
                game.player.moveMent.rightMove = false
            default:
                NSLog("%@", "Unknown value received")
            }
        }
    }
    func action(act: String){
        if let game = skView.scene as? GameScene{
            switch act{
            case "Jp":
                game.player.action.jump = true
            case "A":
                game.player.action.attack = true
            case "D":
                game.player.action.dash = true
            case "T":
                game.player.action.transform = true
            default:
                NSLog("%@", "Unknown value received")
            }
        }
    }
}

extension MainViewController : ControllerServiceDelegate {
    func connectedDevicesChanged(manager: ControllerService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionLabel.stringValue = "연결됨";
        }
    }
    
    func buttonChanged(manager: ControllerService, changedBtn: String) {
        
        OperationQueue.main.addOperation {
            switch changedBtn {
            case "L":
                self.move(direction: "L")
            case "LUp":
                self.move(direction: "LUp")
            case "R":
                self.move(direction: "R")
            case "RUp":
                self.move(direction: "RUp")
            case "Jp":
                self.action(act: "Jp")
            case "A":
                self.action(act: "A")
            case "D":
                self.action(act: "D")
            case "T":
                self.action(act: "T")
            default:
                NSLog("%@", "Unknown value received")
            }
        }
    }
}
