//
//  GameViewController.swift
//  BubbleBurst iOS
//
//  Created by Mufeez Amjad on 2017-09-30.
//  Copyright © 2017 Mufeez Amjad. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    let scene = GameScene(fileNamed: "GameScene")
    var gameMode: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.segueToGameOver), name: NSNotification.Name(rawValue: "seguetoGameOver"), object: nil)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if scene != nil {
                // Set the scale mode to scale to fit the window
                scene?.scaleMode = .aspectFill
                
                // Present the scene
                //scene.viewController = self
                
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            //view.allowsTransparency = true;
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
    }
    
    @objc func segueToGameOver(){
        performSegue(withIdentifier: "gameIsOver", sender: self)
        //self.view.removeFromSuperview()
        //self.view = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let yourVC = segue.destination as? Postgame {
            yourVC.score = scene!.score
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func unwindToGame(segue: UIStoryboardSegue) {
        scene?.playAgain()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (scene?.gameTimer != nil) {
            scene?.gameTimer.invalidate()
        }
        scene?.gameTimer = nil
        scene?.oneUpTimer = nil
        scene?.freezeTimer = nil
        scene?.slowMoTimer = nil
        scene?.autoPopTimer = nil
        scene?.superPopTimer = nil
    }
    deinit {
        print("deinit called")
    }
}
