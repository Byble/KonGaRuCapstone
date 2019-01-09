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

class MainViewController: NSViewController, ControlDelegate, TransitionDelegate, TransitionMenuDelegate {
    
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
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                let transition = SKTransition.fade(withDuration: 1)
                scene.scaleMode = .aspectFill
                scene.size = view.bounds.size
                scene.controlDelegate = self
                scene.transitionDelegate = self
                scene.name = "GameScene"
                view.ignoresSiblingOrder = true
                view.presentScene(scene, transition: transition)
            }
        }
    }
//    @IBAction func exitBtn(_ sender: Any) {
//        NSApplication.shared.terminate(self)
//    }
    
    func enterFullScreen(){
        let presOptions: NSApplication.PresentationOptions = [.fullScreen, .autoHideMenuBar]
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions: presOptions]
        view.enterFullScreenMode(NSScreen.main!, withOptions: optionsDictionary)
        view.wantsLayer = true
    }
    func ReturnToMenu() {
        self.view.window?.performClose(self)
    }
    
    func MakeVibe() {
        controllService.send(buttonName: "MV")
    }
    func GoDungeon() {
        if let view = self.skView {
//            view.showsPhysics = true
            if let scene = SKScene(fileNamed: "DungeonScene") as? DungeonScene {
                let transition = SKTransition.fade(withDuration: 5)
                scene.scaleMode = .aspectFill
                scene.size = view.bounds.size
                scene.name = "DungeonScene"
                scene.controlDelegate = self
                scene.transitionMenuDelegate = self
                view.ignoresSiblingOrder = true
                view.presentScene(scene, transition: transition)
            }
            
        }
    }
}

extension MainViewController : ControllerServiceDelegate {
    func connectedDevicesChanged(manager: ControllerService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionLabel.stringValue = connectedDevices.first!
        }
    }    
    func buttonChanged(manager: ControllerService, changedBtn: String) {
        if skView.scene?.name == "GameScene"{
            if let game = skView.scene as? GameScene{
                OperationQueue.main.addOperation {
                    guard game.player.action.skill1 == false else{
                        return
                    }
                    if !game.player.action.sniping{
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
                            if (game.player.action.attack3 == false){
                                game.player.action.attack1 = true
                                game.player.Attack1()
                            }
                        case "A2":
                            if (game.player.action.attack1 == true){
                                game.player.action.attack2 = true
                            }
                        case "A3":
                            if (game.player.action.attack2 == true){
                                game.player.action.attack3 = true
                            }
                        case "S":
                            if game.player.getState() == playerState.human{
                                self.controllService.send(buttonName: "HSS")
                                if let sview = (self.skView.scene) as? GameScene{
                                    sview.addZoom()
                                    sview.ChangeCam(normal: false)
                                }
                            }
                            game.player.Skill()
                        case "D":
                            game.player.Dash()
                        case "T":
                            game.player.Transform(){ (type) in
                                if type == playerState.cat{
                                    self.controllService.send(buttonName: "TC")
                                }else{
                                    self.controllService.send(buttonName: "TH")
                                }
                            }
                        default:
                            break
                        }
                    }else{
                        if let sview = (self.skView.scene) as? GameScene{
                            let zoomDown = SKAction.scale(by: 1.2, duration: 0.5)
                            let zoomUpOnce = SKAction.reversed(zoomDown)
                            
                            switch changedBtn{
                            case "HSF":
                                game.player.action.sniping = false
                                game.player.animCheck.skill = false
                                sview.zoom.removeFromParent()
                                sview.ChangeCam(normal: true)
                                if (sview.camera?.actionForKeyIsRunning(key: "CameraMove"))!{
                                    sview.camera?.removeAction(forKey: "CameraMove")
                                }
                                sview.zoomLevel = 1
                                sview.camera?.setScale(1.1)
                            case "HSG":
                                sview.zoom.Shot()
                            case "HSD":
                                //zoom down
                                if sview.zoomLevel > 1{
                                    sview.zoomLevel -= 1
                                    
                                    sview.camera?.run(zoomUpOnce())
                                }
                            case "HSU":
                                //zoom up
                                if sview.zoomLevel < 4{
                                    sview.zoomLevel += 1
                                    
                                    sview.camera?.run(zoomDown)
                                }
                            case "S":
                                if game.player.getState() == playerState.human{
                                    self.controllService.send(buttonName: "HSS")
                                    if let sview = (self.skView.scene) as? GameScene{
                                        sview.addZoom()
                                        sview.ChangeCam(normal: false)
                                    }
                                }
                            default:
                                sview.followCam2(changedPos: changedBtn)
                            }
                        }
                    }
                }
            }
        }
        
        if skView.scene?.name == "DungeonScene"{
            if let game = skView.scene as? DungeonScene{
                OperationQueue.main.addOperation {
                    guard game.player.action.skill1 == false else{
                        return
                    }
                    if !game.player.action.sniping{
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
                            if (game.player.action.attack3 == false){
                                game.player.action.attack1 = true
                                game.player.Attack1()
                            }
                        case "A2":
                            if (game.player.action.attack1 == true){
                                game.player.action.attack2 = true
                            }
                        case "A3":
                            if (game.player.action.attack2 == true){
                                game.player.action.attack3 = true
                            }
                        case "S":
                            if game.player.getState() == playerState.human{
                                self.controllService.send(buttonName: "HSS")
                                if let sview = (self.skView.scene) as? DungeonScene{
                                    sview.addZoom()
                                    sview.ChangeCam(normal: false)
                                }
                            }
                            game.player.Skill()
                        case "D":
                            game.player.Dash()
                        case "T":
                            game.player.Transform(){ (type) in
                                if type == playerState.cat{
                                    self.controllService.send(buttonName: "TC")
                                }else{
                                    self.controllService.send(buttonName: "TH")
                                }
                            }
                        default:
                            break
                        }
                    }else{
                        if let sview = (self.skView.scene) as? DungeonScene{
                            let zoomDown = SKAction.scale(by: 1.2, duration: 0.5)
                            let zoomUpOnce = SKAction.reversed(zoomDown)
                            
                            switch changedBtn{
                            case "HSF":
                                game.player.action.sniping = false
                                game.player.animCheck.skill = false
                                sview.zoom.removeFromParent()
                                sview.ChangeCam(normal: true)
                                if (sview.camera?.actionForKeyIsRunning(key: "CameraMove"))!{
                                    sview.camera?.removeAction(forKey: "CameraMove")
                                }
                                sview.zoomLevel = 1
                                sview.camera?.setScale(1.1)
                            case "HSG":
                                sview.zoom.Shot()
                            case "HSD":
                                //zoom down
                                if sview.zoomLevel > 1{
                                    sview.zoomLevel -= 1
                                    
                                    sview.camera?.run(zoomUpOnce())
                                }
                            case "HSU":
                                //zoom up
                                if sview.zoomLevel < 4{
                                    sview.zoomLevel += 1
                                    
                                    sview.camera?.run(zoomDown)
                                }
                            case "S":
                                if game.player.getState() == playerState.human{
                                    self.controllService.send(buttonName: "HSS")
                                    if let sview = (self.skView.scene) as? DungeonScene{
                                        sview.addZoom()
                                        sview.ChangeCam(normal: false)
                                    }
                                }
                            default:
                                sview.followCam2(changedPos: changedBtn)
                            }
                        }
                    }
                }
            }

        }
    }
}
