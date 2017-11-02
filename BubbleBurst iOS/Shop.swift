//
//  Shop.swift
//  BubbleBurst iOS
//
//  Created by Mufeez Amjad on 2017-10-28.
//  Copyright © 2017 Mufeez Amjad. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class Shop: UIViewController, GADBannerViewDelegate, GADRewardBasedVideoAdDelegate, GADInterstitialDelegate {
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var Back: UIButton!
    @IBOutlet weak var PowerUp: UIButton!
    @IBOutlet weak var Customize: UIButton!
    
    @IBOutlet weak var slowUpgrade: UIButton!
    @IBOutlet weak var autoUpgrade: UIButton!
    @IBOutlet weak var lifeUpgrade: UIButton!
    
    @IBOutlet weak var autoCurrent: UILabel!
    @IBOutlet weak var autoNext: UILabel!
    @IBOutlet weak var autoDetails: UILabel!
    @IBOutlet weak var autoProgress: UIImageView!

    @IBOutlet weak var slowCurrent: UILabel!
    @IBOutlet weak var slowNext: UILabel!
    @IBOutlet weak var slowDetails: UILabel!
    @IBOutlet weak var slowProgress: UIImageView!

    @IBOutlet weak var lifeCurrent: UILabel!
    @IBOutlet weak var lifeNext: UILabel!
    @IBOutlet weak var lifeDetails: UILabel!
    @IBOutlet weak var lifeProgress: UIImageView!

    @IBOutlet weak var coinAd: UIButton!
    @IBOutlet weak var buyCoins: UIButton!
    @IBOutlet weak var noAds: UIButton!
    @IBOutlet weak var restorePurchases: UIButton!
    
    var autoCost = 0
    var lifeCost = 0
    var slowCost = 0
    
    var autoLevel = 0
    var slowLevel = 1
    var lifeLevel = 1
    
    var coins = 0
    
    @IBOutlet weak var coinIcon: UIImageView!
    @IBOutlet weak var coinsLabel: UILabel!
    
    @IBOutlet weak var bannerAd: GADBannerView!
    var coinRewardAd: GADRewardBasedVideoAd?
    
    override func viewDidLoad() {
        Back.setImage(UIImage(named: "back"), for: .normal)
        coinAd.setImage(UIImage(named: "coinAd"), for: .normal)
        buyCoins.setImage(UIImage(named: "buyCoin"), for: .normal)
        noAds.setImage(UIImage(named: "noAds"), for: .normal)
        restorePurchases.setImage(UIImage(named: "restore"), for: .normal)
        
        //Request
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        //Set up ad
        bannerAd.adUnitID = "ca-app-pub-4669355053831786/6468914787"
        
        bannerAd.rootViewController = self
        bannerAd.delegate = self
        
        bannerAd.load(request)
        
        coinRewardAd = GADRewardBasedVideoAd.sharedInstance()
        coinRewardAd?.delegate = self
        
        coinRewardAd?.load(GADRequest(),
                     withAdUnitID: "ca-app-pub-4669355053831786/3619020008")
        
        /*
         if lifeAd?.isReady == true {
         lifeAd?.present(fromRootViewController: self)
         }
         */
        
        Back.center.x -= view.bounds.width
        coinsLabel.center.y += view.bounds.height
        coinIcon.center.y += view.bounds.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (defaults.value(forKey: "Coins") != nil){
            coins = defaults.integer(forKey: "Coins")
        }
        coinsLabel.text = "\(coins)"
        
        //autoProgress.image = resizeImage(image: autoProgress.image!, scaledToSize: CGSize(width: autoProgress.bounds.size.width * CGFloat(autoWidth), height: autoProgress.bounds.size.height))
        
        updateProgress()
        
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.Back.center.x += self.view.bounds.width
        },
                       completion: nil
        )
        
        UIView.animate(withDuration: 0.7, delay: 0.7,
                       options: [.curveEaseOut],
                       animations: {
                        self.coinsLabel.center.y -= self.view.bounds.height
                        self.coinIcon.center.y -= self.view.bounds.height
        },
                       completion: nil
        )
    }
    
    func resizeImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        //coins = reward.amount
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
    
    @IBAction func backPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func autoPopUpgrade(_ sender: Any) {
        if (coins >= autoCost && autoLevel < 3){
            coins -= autoCost
            autoLevel += 1
            coinsLabel.text = "\(coins)"
            defaults.setValue(autoLevel, forKey: "AutoPop")
            updateProgress()
        }
    }
    
    @IBAction func slowMoUpgrade(_ sender: Any) {
        if (coins >= slowCost && slowLevel < 5){
            coins -= slowCost
            slowLevel += 1
            coinsLabel.text = "\(coins)"
            defaults.setValue(slowLevel, forKey: "SlowMo")
            updateProgress()
        }
        print(slowLevel)
    }
    
    @IBAction func lifeUpgrade(_ sender: Any) {
        if (coins >= lifeCost && lifeLevel < 5){
            coins -= lifeCost
            lifeLevel += 1
            coinsLabel.text = "\(coins)"
            defaults.setValue(lifeLevel, forKey: "Life")
            updateProgress()
        }
        print(lifeLevel)
    }
    
    func updateProgress(){
        var autoWidth = 0.0
        var slowWidth = 0.2
        var lifeWidth = 0.2
        
        if (defaults.object(forKey: "AutoPop") == nil){
            autoCost = 75
            autoProgress.isHidden = true
            autoLevel = 0
        }
        else if (defaults.integer(forKey: "AutoPop") == 1){
            autoWidth = 0.33
            autoCost = 125
            autoProgress.isHidden = false
            autoProgress.image = UIImage(named: "0.33")
            autoLevel = 1
            autoDetails.text = "Longer duration"
        }
        else if (defaults.integer(forKey: "AutoPop") == 2){
            autoWidth = 0.66
            autoCost = 200
            autoProgress.image = UIImage(named: "0.66")
            autoLevel = 2
            autoDetails.text = "Longer duration"
        }
        else if (defaults.integer(forKey: "AutoPop") == 3){
            autoWidth = 1
            autoProgress.image = UIImage(named: "1")
            autoLevel = 3
            autoDetails.text = "MAX Level Reached"
        }
        
        if (defaults.object(forKey: "SlowMo") == nil){
            slowCost = 60
            slowProgress.image = UIImage(named: "0.2")
            slowLevel = 1
            slowDetails.text = "Slower"
        }
        else if (defaults.integer(forKey: "SlowMo") == 2){
            slowWidth = 0.4
            slowCost = 100
            slowProgress.image = UIImage(named: "0.4")
            slowLevel = 2
            slowDetails.text = "Slower"
        }
        else if (defaults.integer(forKey: "SlowMo") == 3){
            slowWidth = 0.6
            slowCost = 180
            slowProgress.image = UIImage(named: "0.6")
            slowLevel = 3
            slowDetails.text = "Slower"
        }
        else if (defaults.integer(forKey: "SlowMo") == 4){
            slowWidth = 0.8
            slowCost = 340
            slowProgress.image = UIImage(named: "0.8")
            slowLevel = 4
            slowDetails.text = "Slower"
        }
        else if (defaults.integer(forKey: "SlowMo") == 5){
            slowWidth = 1
            slowProgress.image = UIImage(named: "1")
            slowLevel = 5
            slowDetails.text = "MAX Level Reached"
        }
        
        if (defaults.object(forKey: "Life") == nil) {
            lifeCost = 50
            lifeProgress.image = UIImage(named: "0.2")
            lifeLevel = 1
            lifeDetails.text = "One more life"
        }
        else if (defaults.integer(forKey: "Life") == 2){
            lifeWidth = 0.4
            lifeCost = 100
            lifeProgress.image = UIImage(named: "0.4")
            lifeLevel = 2
            lifeDetails.text = "One more life"
        }
        else if (defaults.integer(forKey: "Life") == 3){
            lifeWidth = 0.6
            lifeCost = 200
            lifeProgress.image = UIImage(named: "0.6")
            lifeLevel = 3
            lifeDetails.text = "One more life"
        }
        else if (defaults.integer(forKey: "Life") == 4){
            lifeWidth = 0.8
            lifeCost = 400
            lifeProgress.image = UIImage(named: "0.8")
            lifeLevel = 4
            lifeDetails.text = "One more life"
        }
        else if (defaults.integer(forKey: "Life") == 5){
            lifeWidth = 1
            lifeProgress.image = UIImage(named: "1")
            lifeLevel = 5
            lifeDetails.text = "MAX Level Reached"
        }
        
        autoUpgrade.setTitle("\(autoCost)", for: .normal)
        slowUpgrade.setTitle("\(slowCost)", for: .normal)
        lifeUpgrade.setTitle("\(lifeCost)", for: .normal)
        
        autoCurrent.text = "Current Level: \(autoLevel)"
        if (autoLevel < 3) {
            autoNext.text = "Next Level: \(autoLevel+1)"
        }
        else {
            autoNext.text = "Next Level: \(autoLevel)"
        }
        slowCurrent.text = "Current Level: \(slowLevel)"
        if (slowLevel < 5) {
            slowNext.text = "Next Level: \(slowLevel+1)"
        }
        else {
            slowNext.text = "Next Level: \(slowLevel)"
        }
        lifeCurrent.text = "Current Level: \(lifeLevel)"
        if (lifeLevel < 5) {
            lifeNext.text = "Next Level: \(lifeLevel+1)"
        }
        else {
            lifeNext.text = "Next Level: \(lifeLevel)"
        }
        
    }
    
    
}
