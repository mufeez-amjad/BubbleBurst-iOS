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
    var highScore: Int = 0
    var gameMode: String!
    
    var lifeAd: GADRewardBasedVideoAd?
    var interstitial: GADInterstitial!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (gameMode != "Classic") {
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
                     withAdUnitID: "ca-app-pub-3940256099942544/1712485313")
        //ca-app-pub-4669355053831786/4776540656
        interstitial = createAndLoadInterstitial()
        
        Retry.setImage(UIImage(named: "restart"), for: .normal)
        Home.setImage(UIImage(named: "home"), for: .normal)
        Leaderboard.setImage(UIImage(named: "leaderboard"), for: .normal)
        videoAdButton.setImage(UIImage(named: "videoAd"), for: .normal)
        
        let defaults = UserDefaults.standard
        
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
        
        if (defaults.value(forKeyPath: "Points") == nil) {
            defaults.set(score, forKey: "Points")
        }
        else {
            let readPoints = defaults.integer(forKey: "Points")
            let points = readPoints + score
            defaults.set(points, forKey: "Points")
        }
        
        scoreLabel.text = "Score: \(score)"
        //scoreLabel.center.x = self.view.center.x
        
        highScoreLabel.center.x = self.view.center.x
        interstitial.present(fromRootViewController: self)
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        var interstitial = GADInterstitial(adUnitID: "ca-app-pub-4669355053831786/7207262873")
        
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    @IBAction func watchVideo(_ sender: Any) {
        if lifeAd?.isReady == true {
            lifeAd?.present(fromRootViewController: self)
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        if let presenter = presentingViewController as? GameViewController {
            presenter.scene?.oneLife()
        }
        NSLog("REWARDED.");
        backPressed(self)
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
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        NSLog("REWARDED.");
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

