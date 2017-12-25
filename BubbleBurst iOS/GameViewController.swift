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
    
    @IBOutlet weak var blurOverlay: UIVisualEffectView!
    @IBOutlet weak var pausesLeft: UILabel!
    @IBOutlet weak var pausedOverlay: UIImageView!
    @IBOutlet weak var Back: UIButton!
    @IBOutlet weak var Home: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var livesTimeLabel: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    let scene = GameScene(fileNamed: "GameScene")
    var gameMode: String!
    var pauseShowing = false
    
    @IBOutlet weak var fade: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        Back.setImage(UIImage(named: "back"), for: .normal)
        Home.setImage(UIImage(named: "end"), for: .normal)
        Home.isHidden = true
        Home.alpha = 0
        Back.center.x -= view.bounds.width
        instructionsLabel.center.y -= view.bounds.height
        
        BubbleIcon.center.x -= view.bounds.width
        scoreLabel.center.x -= view.bounds.width
        LivesIcon.center.x -= view.bounds.width
        TimerIcon.center.x -= view.bounds.width
        livesTimeLabel.center.x -= view.bounds.width
        coinsIcon.center.x -= view.bounds.width
        coinsLabel.center.x -= view.bounds.width
        
        if (Menu.bundle == "Classic" || Menu.bundle == "Greenery"){
            BubbleIcon.image = UIImage(named: "Bubble")
        }
            
        else if (Menu.bundle == "Bubble Tea"){
            BubbleIcon.image = UIImage(named: "Tapioca")
        }
            
        else if (Menu.bundle == "Snowy"){
            BubbleIcon.image = UIImage(named: "Snow")
        }
        
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
                scene?.gameMode = gameMode
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            //view.allowsTransparency = true;
            //view.showsFPS = true
            //view.showsNodeCount = true
        }
        scene?.viewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.popViewController(animated: false)
        
        scoreLabel.text = "0"
        
        if (gameMode == "Timed") {
            livesTimeLabel.text = "0"
            instructionsLabel.text = "Keep your finger \n on the screen!"
        }
        if (gameMode == "Classic") {
            livesTimeLabel.text = "10"
            instructionsLabel.text = "Swipe or tap the bubbles \n to pop them!"
        }
        if (gameMode == "Endless") {
            livesTimeLabel.isHidden = true
            coinsLabel.frame.origin.y = livesTimeLabel.frame.origin.y
            instructionsLabel.text = "Swipe or tap the bubbles \n to pop them!"
        }
        coinsLabel.text = "0"
        
        fadeIn()
        
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.BubbleIcon.center.x += self.view.bounds.width
                        self.scoreLabel.center.x += self.view.bounds.width
                        self.LivesIcon.center.x += self.view.bounds.width
                        self.TimerIcon.center.x += self.view.bounds.width
                        self.livesTimeLabel.center.x += self.view.bounds.width
                        self.coinsIcon.center.x += self.view.bounds.width
                        self.coinsLabel.center.x += self.view.bounds.width
                        self.instructionsLabel.center.y += self.view.bounds.height
        },
                       completion: nil
        )
        
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
        
        /*if (gameMode == "Timed"){
         UIView.animate(withDuration: 0.7, delay: 0,
         options: [.curveEaseOut],
         animations: {
         self.blurOverlay.alpha = 1
         self.pausedOverlay.alpha = 1
         self.pausesLeft.alpha = 1
         },
         completion: nil
         )
         }*/
        
        UIView.animate(withDuration: 1, delay: 5,
                       options: [.curveEaseOut],
                       animations: {
                        self.instructionsLabel.center.y -= self.view.bounds.height
        },
                       completion: nil
        )
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
        BubbleIcon.center.x -= view.bounds.width
        scoreLabel.center.x -= view.bounds.width
        LivesIcon.center.x -= view.bounds.width
        TimerIcon.center.x -= view.bounds.width
        livesTimeLabel.center.x -= view.bounds.width
        coinsIcon.center.x -= view.bounds.width
        coinsLabel.center.x -= view.bounds.width
    }
    
    func hidePause(){
        pauseShowing = false
        Home.isHidden = true
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.blurOverlay.alpha = 0
                        self.pausedOverlay.alpha = 0
                        self.pausesLeft.alpha = 0
                        self.Home.alpha = 0
        },
                       completion: nil
        )
    }
    
    func showPause(){
        pauseShowing = true
        Home.isHidden = false
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.blurOverlay.alpha = 1
                        self.pausedOverlay.alpha = 1
                        self.pausesLeft.alpha = 1
                        self.Home.alpha = 1
        },
                       completion: nil
        )
    }
    
    @objc func segueToGameOver(){
        performSegue(withIdentifier: "gameIsOver", sender: self)
        nullify()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? Postgame {
            nextVC.score = scene!.score
            nextVC.time = scene!.time
            nextVC.gameMode = scene!.gameMode
            nextVC.coins = scene!.coinCount
            nextVC.usedExtraLife = scene!.usedExtraLife
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
    
    @IBAction func homePressed(_ sender: Any) {
        segueToGameOver()
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
    
    override func viewWillDisappear(_ animated: Bool)  {}
    
    @IBAction func backPressed(_ sender: Any) {
        AppDelegate.playClick()
        segueToGameOver()
    }
    
    func fadeIn(){
        UIView.animate(withDuration: 1, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.fade.alpha = 0
        },
                       completion: nil
        )
    }
    
    func fadeOut(){
        UIView.animate(withDuration: 1, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.fade.alpha = 1
        },
                       completion: nil
        )
    }
    
}
