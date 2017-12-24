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

    var iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()
    
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
    var gameMode: String!
    var coins: Int = 0
    
    var lifeAd: GADRewardBasedVideoAd?
    var interstitial: GADInterstitial!
    
    /* Variables */
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    var LEADERBOARD_ID: String!
    
    @IBOutlet weak var fade: UIImageView!
    
    override func viewDidLoad() {
        
        if !(GKLocalPlayer.localPlayer().isAuthenticated) {
            authenticateLocalPlayer()
        }

        super.viewDidLoad()
        
        if (gameMode == "Endless") {
            videoAdButton.isHidden = true
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
                     withAdUnitID: "ca-app-pub-4669355053831786/4776540656") //TODO: ca-app-pub-4669355053831786/4776540656
        // ca-app-pub-3940256099942544/1712485313
        interstitial = createAndLoadInterstitial()
        
        Retry.setImage(UIImage(named: "restart"), for: .normal)
        Home.setImage(UIImage(named: "home"), for: .normal)
        Leaderboard.setImage(UIImage(named: "leaderboard"), for: .normal)
        videoAdButton.setImage(UIImage(named: "videoAd"), for: .normal)
        
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
        
        LEADERBOARD_ID = "BubbleBurst" + gameMode
        
        if (gameMode != "Timed"){
            if (defaults.value(forKeyPath: gameMode) == nil){
                if (score > 0) {
                    defaults.set(score, forKey: gameMode)
                    highScoreLabel.text = "New Best!"
                }
                else {
                    highScoreLabel.text = "Best: "
                }
            }
            else {
                let readHighScore = defaults.integer(forKey: gameMode)
                if readHighScore < score {
                    highScore = score
                    defaults.set(score, forKey: gameMode)
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
                        defaults.set(gameMode, forKey: "failed\(gameMode)")
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
                        defaults.set(gameMode, forKey: "failed\(gameMode)")
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
    
    override func viewDidAppear(_ animated: Bool) {
        if lifeAd?.isReady == true {
            videoAdButton.isHidden = false
        }
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
        updateiCloud()
    }
    
    @IBAction func backPressed(_ sender: Any) {
        AppDelegate.playClick()
        //fadeOut() TODO: uncomment
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
        performSegue(withIdentifier: "backtoMenu", sender: self)
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
    
    func updateiCloud(){
        
        if !(defaults.object(forKey: "Classic") == nil){
            let classicHigh = defaults.integer(forKey: "Classic")
            iCloudKeyStore?.set(classicHigh, forKey: "Classic")
        }
        else {
            iCloudKeyStore?.set(0, forKey: "Classic")
        }
        
        if !(defaults.object(forKey: "Timed") == nil){
            let timedHigh = defaults.integer(forKey: "Timed")
            iCloudKeyStore?.set(timedHigh, forKey: "Timed")
        }
        else {
            iCloudKeyStore?.set(0, forKey: "Timed")
        }
        
        if !(defaults.object(forKey: "Endless") == nil){
            let endlessHigh = defaults.integer(forKey: "Endless")
            iCloudKeyStore?.set(endlessHigh, forKey: "Endless")
        }
        else {
            iCloudKeyStore?.set(0, forKey: "Endless")
        }
        iCloudKeyStore?.synchronize()
    }
}

