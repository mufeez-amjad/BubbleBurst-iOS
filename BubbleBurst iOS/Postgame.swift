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
import StoreKit

class Postgame: UIViewController, GADBannerViewDelegate, GADRewardBasedVideoAdDelegate, GADInterstitialDelegate {
    
    @IBOutlet weak var gameOverOverlay: UIImageView!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var Retry: UIButton!
    @IBOutlet weak var Home: UIButton!
    @IBOutlet weak var Leaderboard: UIButton!
    
    @IBOutlet var videoAdButton: UIButton!
    
    @IBOutlet weak var bannerAd: GADBannerView!
    
    var score: Int = 0
    var time: Int = 0
    var highScore: Int = 0
    var gameMode: String!
    var coins: Int = 0
    
    var lifeAd: GADRewardBasedVideoAd?
    var interstitial: GADInterstitial!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (gameMode == "Endless") {
            videoAdButton.isHidden = true
        }
        
        //Request
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        //Set up ad
        bannerAd.adUnitID = "ca-app-pub-4669355053831786/6468914787"
        
        bannerAd.rootViewController = self
        bannerAd.delegate = self
        
        bannerAd.load(request)
        
        lifeAd = GADRewardBasedVideoAd.sharedInstance()
        lifeAd?.delegate = self
        
        lifeAd?.load(GADRequest(),
                     withAdUnitID: "ca-app-pub-4669355053831786/4776540656")
        // ca-app-pub-3940256099942544/1712485313
        interstitial = createAndLoadInterstitial()
        
        Retry.setImage(UIImage(named: "restart"), for: .normal)
        Home.setImage(UIImage(named: "home"), for: .normal)
        Leaderboard.setImage(UIImage(named: "leaderboard"), for: .normal)
        videoAdButton.setImage(UIImage(named: "videoAd"), for: .normal)
        
        let defaults = UserDefaults.standard
        
        if (gameMode != "Timed"){
            if (defaults.value(forKeyPath: gameMode) == nil){
                defaults.set(score, forKey: gameMode)
                highScoreLabel.text = "New Best!"
            }
            else {
                let readHighScore = defaults.integer(forKey: gameMode)
                if readHighScore < score {
                    highScore = score
                    defaults.set(score, forKey: gameMode)
                    highScoreLabel.text = "New Best!"
                }
                else {
                    highScore = readHighScore
                    highScoreLabel.text = "Best: \(highScore)"
                }
            }
        }
        else {
            if (defaults.value(forKeyPath: gameMode) == nil){
                defaults.set(time, forKey: gameMode)
                highScoreLabel.text = "New Best!"
            }
            else {
                let readHighScore = defaults.integer(forKey: gameMode)
                if readHighScore < time {
                    highScore = time
                    defaults.set(time, forKey: gameMode)
                    highScoreLabel.text = "New Best!"
                }
                else {
                    highScore = readHighScore
                    highScoreLabel.text = "Best: \(highScore)"
                    let minutes = Int(highScore) / 60 % 60
                    let seconds = Int(highScore) % 60
                    highScoreLabel.text = "Best: \(String(format:"%02i:%02i", minutes, seconds))"
                }
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

        if (defaults.value(forKeyPath: "Coins") == nil) {
            defaults.set(coins, forKey: "Coins")
        }
        else {
            let readCoins = defaults.integer(forKey: "Coins")
            let newCoins = readCoins + coins
            defaults.set(newCoins, forKey: "Coins")
        }
        
        if (gameMode != "Timed") {
            scoreLabel.text = "Score: \(score)"
        }
        else {
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            scoreLabel.text = "Time: \(String(format:"%02i:%02i", minutes, seconds))"
        }
        //scoreLabel.center.x = self.view.center.x
        
        highScoreLabel.center.x = self.view.center.x
        interstitial.present(fromRootViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 10.3, *) {
            //SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4669355053831786/7207262873")
        //interstitial = GADInterstitial(adUnitID: "ca-app-pub-4669355053831786/7207262873")

        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        interstitial.load(request)
        interstitial.delegate = self

        return interstitial
        
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("ad loaded")
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("failed")
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        //interstitial = createAndLoadInterstitial()
    }
    
    @IBAction func watchVideo(_ sender: Any) {
        if lifeAd?.isReady == true {
            lifeAd?.present(fromRootViewController: self)
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        if let presenter = presentingViewController as? GameViewController {
            presenter.scene?.oneLife()
        }
        backPressed(self)
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load: \(error.localizedDescription)")
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
        AppDelegate.player?.pause()
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        NSLog("REWARDED.");
        AppDelegate.player?.play()
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    /*override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Remove self from navigation hierarchy
        guard let viewControllers = navigationController?.viewControllers,
            let index = viewControllers.index(of: self) else { return }
        navigationController?.viewControllers.remove(at: index)
    }*/
    
    override func viewDidAppear(_ animated: Bool) {
        if lifeAd?.isReady == true {
            videoAdButton.isHidden = false
        }
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
    }

    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

