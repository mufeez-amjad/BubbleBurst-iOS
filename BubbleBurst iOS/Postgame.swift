//
//  Postgame.swift
//  BubbleBurst iOS
//
//  Created by Mufeez Amjad on 2017-10-05.
//  Copyright © 2017 Mufeez Amjad. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class Postgame: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet var gameOverOverlay: UIImageView!
    
    @IBOutlet var highScoreLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var Retry: UIButton!
    @IBOutlet var Home: UIButton!
    
    @IBOutlet var bannerAd: GADBannerView!
    
    var score: Int = 0
    var highScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Request
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        //Set up ad
        bannerAd.adUnitID = "ca-app-pub-4669355053831786/6468914787"
        
        bannerAd.rootViewController = self
        bannerAd.delegate = self
        
        bannerAd.load(request)
        Retry.setImage(UIImage(named: "restart"), for: .normal)
        Home.setImage(UIImage(named: "home"), for: .normal)
        
        let defaults = UserDefaults.standard
        
        if (defaults.value(forKeyPath: "Highscore") == nil){
            defaults.set(score, forKey: "Highscore")
            highScore = score
            highScoreLabel.text = "Best: \(highScore)"
        }
        else {
            let readHighScore = defaults.integer(forKey: "Highscore")
            if readHighScore < score {
                highScore = score
                defaults.set(score, forKey: "Highscore")
                highScoreLabel.text = "New Best!"
            }
            else {
                highScore = readHighScore
                highScoreLabel.text = "Best: \(highScore)"
            }
        }
        
        if (defaults.value(forKeyPath: "Points") == nil) {
            defaults.set(score, forKey: "Points")
        }
        else {
            let readPoints = defaults.integer(forKey: "Points")
            let points = readPoints + score
            defaults.set(points, forKey: "Points")
        }
        
        scoreLabel.text = "Score: \(score)"
        scoreLabel.center.x = self.view.center.x
        
        highScoreLabel.center.x = self.view.center.x
    }
    
}

