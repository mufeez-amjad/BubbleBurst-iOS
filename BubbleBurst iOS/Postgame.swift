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
import GameKit


class Postgame: UIViewController, GADBannerViewDelegate, GADRewardBasedVideoAdDelegate, GADInterstitialDelegate, GKGameCenterControllerDelegate {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var BG: UIImageView!
    
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
    var coins: Int = 0
    
    var usedExtraLife = false
    
    var lifeAd: GADRewardBasedVideoAd?
    var interstitial: GADInterstitial!
    
    var gcEnabled = Bool()
    var gcDefaultLeaderBoard = String()
    
    var LEADERBOARD_ID: String!
    
    @IBOutlet weak var fade: UIImageView!
    
    var noAdsPurchased: Bool!
    var plays = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noAdsPurchased = defaults.bool(forKey: "noAdsPurchased")
        
        if (defaults.value(forKey: "plays") != nil){
            plays = defaults.integer(forKey: "plays")
        }
        else {
            plays = 0
        }
        
        plays += 1
        defaults.set(plays, forKey: "plays")
        
        if !(GKLocalPlayer.localPlayer().isAuthenticated) {
            authenticateLocalPlayer()
        }
        
        if (Menu.bundle == "Classic"){
            BG.image = UIImage(named: "BG")
        }
            
        else if (Menu.bundle == "Bubble Tea"){
            BG.image = UIImage(named: "milkBG")
        }
            
        else if (Menu.bundle == "Snowy"){
            BG.image = UIImage(named: "snowBG")
        }
            
        else if (Menu.bundle == "Greenery"){
            BG.image = UIImage(named: "grassBG")
        }
        
        if (!noAdsPurchased){
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
            
            bannerAd.adUnitID = "ca-app-pub-4669355053831786/6468914787"
            bannerAd.rootViewController = self
            bannerAd.delegate = self
            
            bannerAd.load(request)
        }
        
        if (GameViewController.gameMode != "Endless" || !usedExtraLife){
            lifeAd = GADRewardBasedVideoAd.sharedInstance()
            lifeAd?.delegate = self
            
            lifeAd?.load(GADRequest(),
                         withAdUnitID: "ca-app-pub-4669355053831786/4776540656")
        }
        
        interstitial = createAndLoadInterstitial()
        
        
        Retry.setImage(UIImage(named: "restart"), for: .normal)
        Home.setImage(UIImage(named: "home"), for: .normal)
        Leaderboard.setImage(UIImage(named: "leaderboard"), for: .normal)
        videoAdButton.setImage(UIImage(named: "videoAd2"), for: .normal)
        
        
        
        if (defaults.string(forKey: "failedGameCenter") == "Y") { //uploads score to GameCenter if previously offline
            if (defaults.string(forKey: "failedClassic") != "" && defaults.string(forKey: "failedClassic") != nil){
                let readHighScore = defaults.integer(forKey: "Classic")
                if Reachability.isConnectedToNetwork(){
                    LEADERBOARD_ID = "BubbleBurstClassic"
                    let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
                    bestScoreInt.value = Int64(highScore)
                    GKScore.report([bestScoreInt]) { (error) in
                        if error != nil {
                            print(error!.localizedDescription)
                        } else {
                            print("Best Score submitted to your Leaderboard!")
                        }
                    }
                    defaults.set("", forKey: "failedClassic")
                }
            }
            
            if (defaults.string(forKey: "failedTimed") != "" && defaults.string(forKey: "failedTimed") != nil){
                let readHighScore = defaults.integer(forKey: "Timed")
                if Reachability.isConnectedToNetwork(){
                    LEADERBOARD_ID = "BubbleBurstTimed"
                    let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
                    bestScoreInt.value = Int64(highScore)
                    GKScore.report([bestScoreInt]) { (error) in
                        if error != nil {
                            print(error!.localizedDescription)
                        } else {
                            print("Best Score submitted to your Leaderboard!")
                        }
                    }
                    defaults.set("", forKey: "failedTimed")
                }
            }
            
            if (defaults.string(forKey: "failedEndless") != "" && defaults.string(forKey: "failedEndless") != nil){
                let readHighScore = defaults.integer(forKey: "Endless")
                if Reachability.isConnectedToNetwork(){
                    LEADERBOARD_ID = "BubbleBurstEndless"
                    let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
                    bestScoreInt.value = Int64(highScore)
                    GKScore.report([bestScoreInt]) { (error) in
                        if error != nil {
                            print(error!.localizedDescription)
                        } else {
                            print("Best Score submitted to your Leaderboard!")
                        }
                    }
                    defaults.set("", forKey: "failedEndless")
                }
            }
            defaults.set("N", forKey: "failedGameCenter")
        }
        
        LEADERBOARD_ID = "BubbleBurst" + GameViewController.gameMode
        
        if (GameViewController.gameMode != "Timed"){
            if (defaults.value(forKeyPath: GameViewController.gameMode) == nil){
                if (score > 0) {
                    defaults.set(score, forKey: GameViewController.gameMode)
                    highScoreLabel.text = "New Best!"
                }
                else {
                    highScoreLabel.text = "Best: "
                }
            }
            else {
                let readHighScore = defaults.integer(forKey: GameViewController.gameMode)
                if readHighScore < score {
                    highScore = score
                    defaults.set(score, forKey: GameViewController.gameMode)
                    highScoreLabel.text = "New Best!"
                    if Reachability.isConnectedToNetwork(){
                        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
                        bestScoreInt.value = Int64(highScore)
                        GKScore.report([bestScoreInt]) { (error) in
                            if error != nil {
                                print(error!.localizedDescription)
                            } else {
                                print("Best Score submitted to your Leaderboard!")
                            }
                        }
                    } else{
                        defaults.set(GameViewController.gameMode, forKey: "failed\(GameViewController.gameMode)")
                        defaults.set("Y", forKey: "failedGameCenter")
                    }
                }
                else {
                    highScore = readHighScore
                    highScoreLabel.text = "Best: \(highScore)"
                }
            }
        }
        else {
            if (defaults.value(forKeyPath: GameViewController.gameMode) == nil){
                defaults.set(time, forKey: GameViewController.gameMode)
                highScoreLabel.text = "New Best!"
            }
            else {
                let readHighScore = defaults.integer(forKey: GameViewController.gameMode)
                if readHighScore < time {
                    highScore = time
                    defaults.set(time, forKey: GameViewController.gameMode)
                    highScoreLabel.text = "New Best!"
                    if Reachability.isConnectedToNetwork(){
                        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
                        bestScoreInt.value = Int64(highScore)
                        GKScore.report([bestScoreInt]) { (error) in
                            if error != nil {
                                print(error!.localizedDescription)
                            } else {
                                print("Best Score submitted to your Leaderboard!")
                            }
                        }
                    } else{
                        defaults.set(GameViewController.gameMode, forKey: "failed\(GameViewController.gameMode)")
                        defaults.set("Y", forKey: "failedGameCenter")
                    }
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
        
        if (GameViewController.gameMode != "Timed") {
            scoreLabel.text = "Score: \(score)"
        }
        else {
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            scoreLabel.text = "Time: \(String(format:"%02i:%02i", minutes, seconds))"
        }
        
        highScoreLabel.center.x = self.view.center.x
        if (!noAdsPurchased){
            interstitial.present(fromRootViewController: self)
        }
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
        
        if (plays % 3 == 0){
            if !(noAdsPurchased) {
                let request = GADRequest()
                request.testDevices = [kGADSimulatorID]
                interstitial.load(request)
                interstitial.delegate = self
            }
        }
        
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("ad loaded")
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("failed")
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) { }
    
    @IBAction func watchVideo(_ sender: Any) {
        if(!usedExtraLife) {
            if lifeAd?.isReady == true {
                lifeAd?.present(fromRootViewController: self)
            }
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        if let presenter = presentingViewController as? GameViewController {
            presenter.scene?.oneLife()
            usedExtraLife = true
        }
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load: \(error.localizedDescription)")
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        if(!usedExtraLife) {
            videoAdButton.setImage(UIImage(named: "videoAd"), for: .normal)
            print("Reward based video ad is received.")
        }
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
        if usedExtraLife {
            backPressed(self)
        }
        AppDelegate.player?.play()
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
        if(usedExtraLife || GameViewController.gameMode == "Endless") {
            videoAdButton.isHidden = true
        }
        else {
            videoAdButton.isHidden = false
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        AppDelegate.playClick()
        fadeOut()
        dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func homePressed(_ sender: Any) {
        AppDelegate.playClick()
        fadeOut()
        if let presenter = presentingViewController as? GameViewController {
            presenter.scene?.reset()
        }
        
        self.presentingViewController?.dismiss(animated: false, completion: nil)
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func leaderboardPressed(_ sender: Any) {
        AppDelegate.playClick()
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
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
    
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error)
            }
        }
    }
}

