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
    
    @IBOutlet weak var BubbleIcon: UIImageView!
    @IBOutlet weak var LivesIcon: UIImageView!
    @IBOutlet weak var TimerIcon: UIImageView!
    @IBOutlet weak var coinsIcon: UIImageView!
    
    @IBOutlet weak var Back: UIButton!

    let scene = GameScene(fileNamed: "GameScene")
    var gameMode: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Back.setImage(UIImage(named: "back"), for: .normal)
        Back.center.x -= view.bounds.width
        
        if (gameMode == "Timed" || gameMode == "Endless"){
            LivesIcon.isHidden = true
        }
        
        if (gameMode == "Endless"){
            coinsIcon.frame.origin.y = LivesIcon.frame.origin.y
        }
        
        if (gameMode != "Timed"){
            TimerIcon.isHidden = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.segueToGameOver), name: NSNotification.Name(rawValue: "seguetoGameOver"), object: nil)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if scene != nil {
                // Set the scale mode to scale to fit the window
                scene?.scaleMode = .aspectFill
                
                // Present the scene
                //scene.viewController = self
                scene?.gameMode = gameMode
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            //view.allowsTransparency = true;
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scene?.playAgain()
        if (gameMode == "Endless"){
            UIView.animate(withDuration: 0.7, delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                            self.Back.center.x += self.view.bounds.width
            },
                           completion: nil
            )
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scene?.gameEnd()
        if (gameMode == "Endless"){
            UIView.animate(withDuration: 0.7, delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                            self.Back.center.x -= self.view.bounds.width
            },
                           completion: nil
            )
        }
    }
    
    @objc func segueToGameOver(){
        performSegue(withIdentifier: "gameIsOver", sender: self)
        //self.view.removeFromSuperview()
        //self.view = nil
        nullify()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let yourVC = segue.destination as? Postgame {
            yourVC.score = scene!.score
            yourVC.time = scene!.time
            yourVC.gameMode = scene!.gameMode
            yourVC.coins = scene!.coinCount
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
    func nullify(){
        if (scene?.bubbleTimer != nil) {
            scene?.bubbleTimer.invalidate()
        }
        if (gameMode == "Timed") {
            if (scene?.gameTimer != nil) {
                scene?.gameTimer.invalidate()
            }
        }
        scene?.gameTimer = nil
        scene?.bubbleTimer = nil
        scene?.oneUpTimer = nil
        scene?.freezeTimer = nil
        scene?.slowMoTimer = nil
        scene?.autoPopTimer = nil
        scene?.superPopTimer = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //nullify()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        segueToGameOver()
    }
    
}
