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
import StoreKit

class Shop: UIViewController, GADBannerViewDelegate, GADRewardBasedVideoAdDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    let defaults = UserDefaults.standard
    
    var iCloudKeyStore: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore()

    @IBOutlet weak var BG: UIImageView!
    
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
    
    @IBOutlet weak var powerUpMenu: UIImageView!
    
    
    @IBOutlet weak var customizeMenu: UIImageView!
    @IBOutlet weak var buyTitle: UILabel!
    @IBOutlet weak var buyImage: UIImageView!
    
    @IBOutlet weak var includes: UILabel!
    @IBOutlet weak var details: UILabel!
    
    @IBOutlet weak var buySet: UIButton!
    
    @IBOutlet weak var coinPrice: UIImageView!
    @IBOutlet weak var price: UILabel!
    
    var grassPrice = 100
    var snowPrice = 200
    var tapiocaPrice = 200
    
    @IBOutlet weak var Regular: UIButton!
    @IBOutlet weak var Grass: UIButton!
    @IBOutlet weak var Snow: UIButton!
    @IBOutlet weak var Tapioca: UIButton!
    
    var menu = "PowerUp"
    
    var autoCost = 70
    var lifeCost = 60
    var slowCost = 50
    
    var autoLevel = 0
    var slowLevel = 1
    var lifeLevel = 1
    
    var autoWidth = "0"
    var slowWidth = "20"
    var lifeWidth = "20"
    
    var coins = 0
    
    @IBOutlet weak var coinIcon: UIImageView!
    @IBOutlet weak var coinsLabel: UILabel!
    
    @IBOutlet weak var bannerAd: GADBannerView!
    var coinRewardAd: GADRewardBasedVideoAd?
    
    let removeAdsID = "BubbleBurstNoAds"
    let hundredCoinsID = "BubbleBurst100Coins"
    let twohundredCoinsID = "BubbleBurst200Coins"
    let fivehundredCoinsID = "BubbleBurst500Coins"

    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var noAdsPurchased = UserDefaults.standard.bool(forKey: "noAdsPurchased")
    
    var grassUnlocked = false
    var snowUnlocked = false
    var tapiocaUnlocked = false
    
    var regularSelected = true
    var grassSelected = false
    var snowSelected = false
    var tapiocaSelected = false
    
    
    @IBOutlet weak var Blur: UIVisualEffectView!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var buyCoinsLabel: UILabel!
    @IBOutlet weak var buyCoinsMenu: UIImageView!
    
    @IBOutlet weak var hundredCoins: UIButton!
    @IBOutlet weak var twoHundredCoins: UIButton!
    @IBOutlet weak var fiveHundredCoins: UIButton!
    
    override func viewDidLoad() {
        if (defaults.bool(forKey: "Greenery") == true){
            grassUnlocked = true
        }
        
        if (defaults.bool(forKey: "Snowy") == true){
            snowUnlocked = true
        }
        
        if (defaults.bool(forKey: "Bubble Tea") == true){
            tapiocaUnlocked = true
        }
        
        Regular.setImage(UIImage(named: "regularS"), for: .normal)
        Grass.setImage(UIImage(named: "leaf"), for: .normal)
        Snow.setImage(UIImage(named: "snow"), for: .normal)
        Tapioca.setImage(UIImage(named: "tapioca"), for: .normal)
        
        if (Menu.bundle != "Classic"){
            buySet.setImage(UIImage(named: "setItem"), for: .normal)
        }
        else {
            buySet.setImage(UIImage(named: "setItemI"), for: .normal)
        }
        Back.setImage(UIImage(named: "back"), for: .normal)
        coinAd.setImage(UIImage(named: "coinAd2"), for: .normal)
        buyCoins.setImage(UIImage(named: "buyCoin"), for: .normal)
        noAds.setImage(UIImage(named: "noAds"), for: .normal)
        restorePurchases.setImage(UIImage(named: "restore"), for: .normal)
    
        powerUpMenu.isHidden = false
        
        customizeMenu.isHidden = true
        buyImage.isHidden = true
        buyTitle.isHidden = true
        coinPrice.isHidden = true
        price.isHidden = true
        details.isHidden = true
        includes.isHidden = true
        buySet.isHidden = true
        Regular.isHidden = true
        Grass.isHidden = true
        Snow.isHidden = true
        Tapioca.isHidden = true
        
        buyImage.image = UIImage(named: "regularI")
        
        buyTitle.text = "Classic"
        
        details.text = "Bubbles, Ocean"
        coinPrice.isHidden = true
        price.isHidden = true
        
        if (!noAdsPurchased){
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID]
        
        
            bannerAd.adUnitID = "ca-app-pub-4669355053831786/6468914787"
            
            bannerAd.rootViewController = self
            bannerAd.delegate = self
            bannerAd.load(request)
        }
        
        coinRewardAd = GADRewardBasedVideoAd.sharedInstance()
        coinRewardAd?.delegate = self
        
        coinRewardAd?.load(GADRequest(),
                           withAdUnitID: "ca-app-pub-4669355053831786/3619020008")
        
        Back.center.x -= view.bounds.width
        coinsLabel.center.y += view.bounds.height
        coinIcon.center.y += view.bounds.height
        
        xButton.setImage(UIImage(named: "xButton"), for: .normal)
        buyCoinsMenu.center.y += view.bounds.height
        buyCoinsLabel.center.y += view.bounds.height
        xButton.center.y += view.bounds.height
        hundredCoins.center.y += view.bounds.height
        twoHundredCoins.center.y += view.bounds.height
        fiveHundredCoins.center.y += view.bounds.height
        
        if noAdsPurchased {
            noAds.setImage(UIImage(named: "noAds2"), for: .normal)
        }
        
        fetchAvailableProducts()
        
        updateProgress(powerUp: 0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Back.center.x -= view.bounds.width
        coinsLabel.center.y += view.bounds.height
        coinIcon.center.y += view.bounds.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        if (defaults.value(forKey: "Coins") != nil){
            coins = defaults.integer(forKey: "Coins")
        }
        
        if (Menu.bundle != "Classic"){
            buySet.setImage(UIImage(named: "setItem"), for: .normal)
        }
        else {
            buySet.setImage(UIImage(named: "setItemI"), for: .normal)
        }
        
        coinsLabel.text = "\(coins)"
        
        updateProgress(powerUp: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.Back.center.x += self.view.bounds.width
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
        coins += 3
        defaults.set(coins, forKey: "Coins")
        coinsLabel.text = "\(coins)"
        AppDelegate.playMoney()
        coinRewardAd?.load(GADRequest(),
                           withAdUnitID: "ca-app-pub-4669355053831786/3619020008")
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load: \(error.localizedDescription)")
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        coinAd.setImage(UIImage(named: "coinAd"), for: .normal)
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
        AppDelegate.playClick()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func autoPopUpgrade(_ sender: Any) {
        if (coins >= autoCost && autoLevel < 3){
            AppDelegate.playMoney()
            coins -= autoCost
            autoLevel += 1
            coinsLabel.text = "\(coins)"
            defaults.setValue(autoLevel, forKey: "AutoPop")
            updateProgress(powerUp: 1)
            updateiCloud()
        }
        else {
            AppDelegate.playError()
        }
    }
    
    @IBAction func slowMoUpgrade(_ sender: Any) {
        

        if (coins >= slowCost && slowLevel < 5){
            AppDelegate.playMoney()
            coins -= slowCost
            slowLevel += 1
            coinsLabel.text = "\(coins)"
            defaults.setValue(slowLevel, forKey: "SlowMo")
            updateProgress(powerUp: 2)
            updateiCloud()
        }
        else {
            AppDelegate.playError()
        }
    }
    
    @IBAction func lifeUpgrade(_ sender: Any) {

        if (coins >= lifeCost && lifeLevel < 5){
            AppDelegate.playMoney()
            coins -= lifeCost
            lifeLevel += 1
            coinsLabel.text = "\(coins)"
            defaults.setValue(lifeLevel, forKey: "Life")
            updateProgress(powerUp: 3)
            updateiCloud()
        }
        else {
            AppDelegate.playError()
        }
    }
    
    func updateProgress(powerUp: Int){
        
        if (powerUp == 1 || powerUp == 0) { //all or autoPop
            if (defaults.object(forKey: "AutoPop") == nil){
                autoCost = 75
                autoLevel = 0
            }
            else if (defaults.integer(forKey: "AutoPop") == 1){
                autoWidth = "33"
                autoCost = 125
                autoLevel = 1
                autoDetails.text = "Longer duration"
            }
            else if (defaults.integer(forKey: "AutoPop") == 2){
                autoWidth = "66"
                autoCost = 200
                autoLevel = 2
                autoDetails.text = "Longer duration"
            }
            else if (defaults.integer(forKey: "AutoPop") == 3){
                autoWidth = "100"
                autoLevel = 3
                autoDetails.text = "MAX Level Reached"
            }
            autoProgress.image = UIImage(named: autoWidth)
            
            autoCurrent.text = "Current Level: \(autoLevel)"
            
            if (autoLevel < 3) {
                autoNext.text = "Next Level: \(autoLevel+1)"
                autoUpgrade.setTitle("\(autoCost)", for: .normal)
            }
            else {
                autoNext.text = "Next Level: \(autoLevel)"
                autoUpgrade.setTitle("MAX", for: .normal)
            }
        }
        
        if (powerUp == 2 || powerUp == 0) {
            if (defaults.object(forKey: "SlowMo") == nil){
                slowCost = 60
                slowLevel = 1
                slowDetails.text = "Slower"
            }
            else if (defaults.integer(forKey: "SlowMo") == 2){
                slowWidth = "40"
                slowCost = 100
                slowLevel = 2
                slowDetails.text = "Slower"
            }
            else if (defaults.integer(forKey: "SlowMo") == 3){
                slowWidth = "60"
                slowCost = 180
                slowLevel = 3
                slowDetails.text = "Slower"
            }
            else if (defaults.integer(forKey: "SlowMo") == 4){
                slowWidth = "80"
                slowCost = 340
                slowLevel = 4
                slowDetails.text = "Slower"
            }
            else if (defaults.integer(forKey: "SlowMo") == 5){
                slowWidth = "100"
                slowLevel = 5
                slowDetails.text = "MAX Level Reached"
            }
            
            slowCurrent.text = "Current Level: \(slowLevel)"
            if (slowLevel < 5) {
                slowNext.text = "Next Level: \(slowLevel+1)"
                slowUpgrade.setTitle("\(slowCost)", for: .normal)
            }
            else {
                slowNext.text = "Next Level: \(slowLevel)"
                slowUpgrade.setTitle("MAX", for: .normal)
            }
            slowProgress.image = UIImage(named: slowWidth)
        }
        if (powerUp == 3 || powerUp == 0) {

            if (defaults.object(forKey: "Life") == nil) {
                lifeCost = 50
                lifeLevel = 1
                lifeDetails.text = "One more life"
            }
            else if (defaults.integer(forKey: "Life") == 2){
                lifeWidth = "40"
                lifeCost = 100
                lifeLevel = 2
                lifeDetails.text = "One more life"
            }
            else if (defaults.integer(forKey: "Life") == 3){
                lifeWidth = "60"
                lifeCost = 200
                lifeLevel = 3
                lifeDetails.text = "One more life"
            }
            else if (defaults.integer(forKey: "Life") == 4){
                lifeWidth = "80"
                lifeCost = 400
                lifeLevel = 4
                lifeDetails.text = "One more life"
            }
            else if (defaults.integer(forKey: "Life") == 5){
                lifeWidth = "100"
                lifeLevel = 5
                lifeDetails.text = "MAX Level Reached"
            }
            
            lifeProgress.image = UIImage(named: lifeWidth)
            
            lifeCurrent.text = "Current Level: \(lifeLevel)"
            if (lifeLevel < 5) {
                lifeNext.text = "Next Level: \(lifeLevel+1)"
                lifeUpgrade.setTitle("\(lifeCost)", for: .normal)
            }
            else {
                lifeNext.text = "Next Level: \(lifeLevel)"
                lifeUpgrade.setTitle("MAX", for: .normal)
            }
        }
        
    }
    
    @IBAction func customizePressed(_ sender: Any) {
        AppDelegate.playClick()
        menu = "Customize"
        changeMenu()
    }
    
    @IBAction func powerUpPressed(_ sender: Any) {
        AppDelegate.playClick()
        menu = "PowerUp"
        changeMenu()
        
        
    }
    
    func changeMenu(){
        if (menu == "Customize"){
            powerUpMenu.isHidden = true
            slowUpgrade.isHidden = true
            autoUpgrade.isHidden = true
            lifeUpgrade.isHidden = true
            autoCurrent.isHidden = true
            autoNext.isHidden = true
            autoDetails.isHidden = true
            autoProgress.isHidden = true
            slowCurrent.isHidden = true
            slowNext.isHidden = true
            slowDetails.isHidden = true
            slowProgress.isHidden = true
            lifeCurrent.isHidden = true
            lifeNext.isHidden = true
            lifeDetails.isHidden = true
            lifeProgress.isHidden = true
            
            customizeMenu.isHidden = false
            buyImage.isHidden = false
            buyTitle.isHidden = false
            coinPrice.isHidden = true
            price.isHidden = true
            details.isHidden = false
            includes.isHidden = false
            buySet.isHidden = false
            Regular.isHidden = false
            Grass.isHidden = false
            Snow.isHidden = false
            Tapioca.isHidden = false
        }
        else if (menu == "PowerUp"){
            customizeMenu.isHidden = true
            buyImage.isHidden = true
            buyTitle.isHidden = true
            coinPrice.isHidden = true
            price.isHidden = true
            details.isHidden = true
            includes.isHidden = true
            buySet.isHidden = true
            Regular.isHidden = true
            Grass.isHidden = true
            Snow.isHidden = true
            Tapioca.isHidden = true
            
            powerUpMenu.isHidden = false
            
            slowUpgrade.isHidden = false
            autoUpgrade.isHidden = false
            lifeUpgrade.isHidden = false
            autoCurrent.isHidden = false
            autoNext.isHidden = false
            autoDetails.isHidden = false
            autoProgress.isHidden = false
            slowCurrent.isHidden = false
            slowNext.isHidden = false
            slowDetails.isHidden = false
            slowProgress.isHidden = false
            lifeCurrent.isHidden = false
            lifeNext.isHidden = false
            lifeDetails.isHidden = false
            lifeProgress.isHidden = false
            
            buyImage.image = UIImage(named: "regularI")
            
            buyTitle.text = "Classic"
            
            details.text = "Bubbles, Ocean"
            coinPrice.isHidden = true
            price.isHidden = true
            
            if (Menu.bundle != "Classic") {
                buySet.setImage(UIImage(named: "setItem"), for: .normal)
            }
            else {
                buySet.setImage(UIImage(named: "setItemI"), for: .normal)
            }
            
            Regular.setImage(UIImage(named: "regularS"), for: .normal)
            Grass.setImage(UIImage(named: "leaf"), for: .normal)
            Snow.setImage(UIImage(named: "snow"), for: .normal)
            Tapioca.setImage(UIImage(named: "tapioca"), for: .normal)
        }
    }
    
    func noNetworkAlert() {
        let alert = UIAlertController(title: "Unable to purchase", message: "Connect to a network and try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @IBAction func noAdsPressed(_ sender: Any) {
        AppDelegate.playClick()
        if !(noAdsPurchased){
            if (!iapProducts.isEmpty) {
                purchaseMyProduct(product: iapProducts[3])
            }
            else {
                noNetworkAlert()
            }
        }
    }
    
    @IBAction func restorePressed(_ sender: Any) {
        AppDelegate.playClick()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @IBAction func buyCoinsPressed(_ sender: Any) {
        AppDelegate.playClick()
        buyCoinsLabel.text = "\(coins)"
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.buyCoinsMenu.center.y -= self.view.bounds.height
                        self.buyCoinsLabel.center.y -= self.view.bounds.height
                        self.xButton.center.y -= self.view.bounds.height
                        self.hundredCoins.center.y -= self.view.bounds.height
                        self.twoHundredCoins.center.y -= self.view.bounds.height
                        self.fiveHundredCoins.center.y -= self.view.bounds.height
                        self.Blur.alpha = 1
        },
                       completion: nil
        )
    }
    @IBAction func xButtonPressed(_ sender: Any) {
        AppDelegate.playClick()
        coinsLabel.text = "\(coins)"
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.buyCoinsMenu.center.y += self.view.bounds.height
                        self.buyCoinsLabel.center.y += self.view.bounds.height
                        self.xButton.center.y += self.view.bounds.height
                        self.hundredCoins.center.y += self.view.bounds.height
                        self.twoHundredCoins.center.y += self.view.bounds.height
                        self.fiveHundredCoins.center.y += self.view.bounds.height
                        self.Blur.alpha = 0
        },
                       completion: nil
        )
    }
    
    @IBAction func hundredCoinsPressed(_ sender: Any) {
        AppDelegate.playClick()
        if (!iapProducts.isEmpty) {
            purchaseMyProduct(product: iapProducts[0])
        }
        else {
            noNetworkAlert()
        }
    }
    
    @IBAction func twoHundredCoinsPressed(_ sender: Any) {
        AppDelegate.playClick()
        if (!iapProducts.isEmpty) {
            purchaseMyProduct(product: iapProducts[1])
        }
        else {
            noNetworkAlert()
        }
    }
    
    @IBAction func fiveHundredCoinsPressed(_ sender: Any) {
        AppDelegate.playClick()
        if (!iapProducts.isEmpty) {
            purchaseMyProduct(product: iapProducts[2])
        }
        else {
            noNetworkAlert()
        }
    }
    
    @IBAction func regularPressed(_ sender: Any) {
        AppDelegate.playClick()
        regularSelected = true
        snowSelected = false
        grassSelected = false
        tapiocaSelected = false
        
        buyImage.image = UIImage(named: "regularI")
        
        buyTitle.text = "Classic"
        
        details.text = "Bubbles, Ocean"
        coinPrice.isHidden = true
        price.isHidden = true
        
        if (Menu.bundle != "Classic") {
            buySet.setImage(UIImage(named: "setItem"), for: .normal)
        }
        else {
            buySet.setImage(UIImage(named: "setItemI"), for: .normal)
        }
        
        Regular.setImage(UIImage(named: "regularS"), for: .normal)
        Grass.setImage(UIImage(named: "leaf"), for: .normal)
        Snow.setImage(UIImage(named: "snow"), for: .normal)
        Tapioca.setImage(UIImage(named: "tapioca"), for: .normal)
    }
    
    @IBAction func grassPressed(_ sender: Any) {
        AppDelegate.playClick()
        regularSelected = false
        snowSelected = false
        grassSelected = true
        tapiocaSelected = false
        
        buyImage.image = UIImage(named: "leafI")
        
        buyTitle.text = "Greenery"
        
        details.text = "Grassy Hills"
        coinPrice.isHidden = false
        price.isHidden = false
        price.text = "\(grassPrice)"
        
        if !(grassUnlocked){
            if (coins >= grassPrice){
                buySet.setImage(UIImage(named: "buyItem"), for: .normal)
            }
            else {
                buySet.setImage(UIImage(named: "buyItemI"), for: .normal)
            }
        }
        else {
            if (Menu.bundle != "Greenery") {
                buySet.setImage(UIImage(named: "setItem"), for: .normal)
            }
            else {
                buySet.setImage(UIImage(named: "setItemI"), for: .normal)
            }
            coinPrice.isHidden = true
            price.isHidden = true
        }
        
        Grass.setImage(UIImage(named: "leafS"), for: .normal)
        Regular.setImage(UIImage(named: "regular"), for: .normal)
        Snow.setImage(UIImage(named: "snow"), for: .normal)
        Tapioca.setImage(UIImage(named: "tapioca"), for: .normal)
    }
    
    @IBAction func snowPressed(_ sender: Any) {
        AppDelegate.playClick()
        regularSelected = false
        snowSelected = true
        grassSelected = false
        tapiocaSelected = false
        
        buyImage.image = UIImage(named: "snowI")
        
        buyTitle.text = "Winter"
        
        details.text = "Snowflakes\nSnowy Mountains"
        coinPrice.isHidden = false
        price.isHidden = false
        price.text = "\(snowPrice)"
        
        if !(snowUnlocked){
            if (coins >= snowPrice){
                buySet.setImage(UIImage(named: "buyItem"), for: .normal)
            }
            else {
                buySet.setImage(UIImage(named: "buyItemI"), for: .normal)
            }
        }
        else {
            if (Menu.bundle != "Snowy") {
                buySet.setImage(UIImage(named: "setItem"), for: .normal)
            }
            else {
                buySet.setImage(UIImage(named: "setItemI"), for: .normal)
            }
            coinPrice.isHidden = true
            price.isHidden = true
        }
        
        Snow.setImage(UIImage(named: "snowS"), for: .normal)
        Regular.setImage(UIImage(named: "regular"), for: .normal)
        Grass.setImage(UIImage(named: "leaf"), for: .normal)
        Tapioca.setImage(UIImage(named: "tapioca"), for: .normal)
    }
    
    @IBAction func Tapioca(_ sender: Any) {
        AppDelegate.playClick()
        regularSelected = false
        snowSelected = false
        grassSelected = false
        tapiocaSelected = true
        
        buyImage.image = UIImage(named: "tapiocaI")
        
        buyTitle.text = "Bubble Tea"
        
        details.text = "Tapioca Balls\nMilk Tea"
        coinPrice.isHidden = false
        price.isHidden = false
        price.text = "\(tapiocaPrice)"
        
        if !(tapiocaUnlocked){
            if (coins >= tapiocaPrice){
                buySet.setImage(UIImage(named: "buyItem"), for: .normal)
            }
            else {
                buySet.setImage(UIImage(named: "buyItemI"), for: .normal)
            }
        }
        else {
            if (Menu.bundle != "Bubble Tea") {
                buySet.setImage(UIImage(named: "setItem"), for: .normal)
            }
            else {
                buySet.setImage(UIImage(named: "setItemI"), for: .normal)
            }
            coinPrice.isHidden = true
            price.isHidden = true
        }
        
        Tapioca.setImage(UIImage(named: "tapiocaS"), for: .normal)
        Regular.setImage(UIImage(named: "regular"), for: .normal)
        Grass.setImage(UIImage(named: "leaf"), for: .normal)
        Snow.setImage(UIImage(named: "snow"), for: .normal)
        updateiCloud()
    }
    
    @IBAction func buySetPressed(_ sender: Any) {
        if (regularSelected){
            if (Menu.bundle != "Classic") {
                AppDelegate.playClick()
                coinPrice.isHidden = true
                price.isHidden = true
                Menu.bundle = "Classic"
                defaults.set(Menu.bundle, forKey: "bundle")
                BG.image = UIImage(named: "BG")
                buySet.setImage(UIImage(named: "setItemI"), for: .normal)
            }
        }
        else if (grassSelected){
            if (Menu.bundle != "Greenery"){
                if (grassUnlocked){
                    AppDelegate.playClick()
                    coinPrice.isHidden = true
                    price.isHidden = true
                    Menu.bundle = "Greenery"
                    defaults.set(Menu.bundle, forKey: "bundle")
                    buySet.setImage(UIImage(named: "setItemI"), for: .normal)
                    BG.image = UIImage(named: "grassBG")
                }
                else if (coins >= grassPrice){
                    AppDelegate.playMoney()

                    coinPrice.isHidden = true
                    price.isHidden = true
                    coins -= grassPrice
                    coinsLabel.text = "\(coins)"
                    Menu.bundle = "Greenery"
                    defaults.set(Menu.bundle, forKey: "bundle")
                    grassUnlocked = true
                    defaults.set(grassUnlocked, forKey: "Greenery")
                    buySet.setImage(UIImage(named: "setItemI"), for: .normal)
                    BG.image = UIImage(named: "grassBG")
                }
            }
        }
        else if (snowSelected){
            if (Menu.bundle != "Snowy"){
                if (snowUnlocked){
                    AppDelegate.playClick()
                    coinPrice.isHidden = true
                    price.isHidden = true
                    Menu.bundle = "Snowy"
                    defaults.set(Menu.bundle, forKey: "bundle")
                    buySet.setImage(UIImage(named: "setItemI"), for: .normal)
                    BG.image = UIImage(named: "snowBG")
                }
                else if (coins >= snowPrice){
                    AppDelegate.playMoney()

                    coinPrice.isHidden = true
                    price.isHidden = true
                    coins -= snowPrice
                    coinsLabel.text = "\(coins)"
                    Menu.bundle = "Snowy"
                    defaults.set(Menu.bundle, forKey: "bundle")
                    snowUnlocked = true
                    defaults.set(snowUnlocked, forKey: "Snowy")
                    buySet.setImage(UIImage(named: "setItemI"), for: .normal)
                    BG.image = UIImage(named: "snowBG")
                }
            }
        }
        else if (tapiocaSelected){
            if (Menu.bundle != "Bubble Tea"){
                if (tapiocaUnlocked){
                    AppDelegate.playClick()

                    coinPrice.isHidden = true
                    price.isHidden = true
                    Menu.bundle = "Bubble Tea"
                    defaults.set(Menu.bundle, forKey: "bundle")
                    BG.image = UIImage(named: "milkBG")
                    buySet.setImage(UIImage(named: "setItemI"), for: .normal)
                }
                else if (coins >= tapiocaPrice){
                    AppDelegate.playMoney()

                    coinPrice.isHidden = true
                    price.isHidden = true
                    coins -= tapiocaPrice
                    coinsLabel.text = "\(coins)"
                    Menu.bundle = "Bubble Tea"
                    defaults.set(Menu.bundle, forKey: "bundle")
                    tapiocaUnlocked = true
                    defaults.set(tapiocaUnlocked, forKey: "Bubble Tea")
                    BG.image = UIImage(named: "milkBG")
                    buySet.setImage(UIImage(named: "setItemI"), for: .normal)
                }
            }
        }
        coinsLabel.text = "\(coins)"
        updateiCloud()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        noAdsPurchased = true
        defaults.set(noAdsPurchased, forKey: "noAdsPurchased")
        let alert = UIAlertController(title: "Restore Purchases", message: "You've successfully restored your purchase!", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @IBAction func adCoinsPressed(_ sender: Any) {
        if coinRewardAd?.isReady == true {
            AppDelegate.playClick()
            coinRewardAd?.present(fromRootViewController: self)
        }
        else {
            AppDelegate.playError()
        }
    }
    
    func fetchAvailableProducts()  {
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects: hundredCoinsID, twohundredCoinsID, fivehundredCoinsID, removeAdsID)
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request == productsRequest {
            var count: Int = 0
            count += 1
            print("Request \(request) failed on \(count). attempt with error: \(error)")
            productsRequest.cancel()
            // try again until we succeed
            fetchAvailableProducts()
        }
    }
    
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            iapProducts = response.products
            
            // 1st IAP Product (Consumable) ------------------------------------
            let firstProduct = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = firstProduct.priceLocale
            let price1Str = numberFormatter.string(from: firstProduct.price)
            
            
            // 2nd IAP Product (Non-Consumable) ------------------------------
            let secondProd = response.products[1] as SKProduct
            
            // Get its price from iTunes Connect
            numberFormatter.locale = secondProd.priceLocale
            let price2Str = numberFormatter.string(from: secondProd.price)
            
        }
    }
    
    
    
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
            
        } else {
            let alert = UIAlertController(title: "Purchase Error", message: "Purchases are disabled on your device!", preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "OK",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            present(alert, animated: true)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                
                case .purchasing, .deferred: break
                
                case .purchased, .restored:
                    
                    if productID == hundredCoinsID {
                        
                        // Add 10 coins and save their total amount
                        coins += 100
                        defaults.set(coins, forKey: "Coins")
                        buyCoinsLabel.text = "\(coins)"
                        
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        
                        let alert = UIAlertController(title: "Purchase Successful", message: "You've successfully purchased 100 B-Coins!", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancelAction = UIAlertAction(title: "OK",
                                                         style: .cancel, handler: nil)
                        
                        alert.addAction(cancelAction)
                        present(alert, animated: true)
                        
                    }
                        
                    else if productID == twohundredCoinsID {
                        coins += 200
                        defaults.set(coins, forKey: "Coins")
                        buyCoinsLabel.text = "\(coins)"
                        
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        
                        let alert = UIAlertController(title: "Purchase Successful", message: "You've successfully purchased 200 B-Coins!", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancelAction = UIAlertAction(title: "OK",
                                                         style: .cancel, handler: nil)
                        
                        alert.addAction(cancelAction)
                        present(alert, animated: true)
                    }
                        
                    else if productID == fivehundredCoinsID {
                        coins += 500
                        defaults.set(coins, forKey: "Coins")
                        buyCoinsLabel.text = "\(coins)"
                        
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        
                        let alert = UIAlertController(title: "Purchase Successful", message: "You've successfully purchased 500 B-Coins!", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancelAction = UIAlertAction(title: "OK",
                                                         style: .cancel, handler: nil)
                        
                        alert.addAction(cancelAction)
                        present(alert, animated: true)
                    }
                        
                    else if productID == removeAdsID {
                        
                        // Save your purchase locally (needed only for Non-Consumable IAP)
                        noAdsPurchased = true
                        defaults.set(noAdsPurchased, forKey: "noAdsPurchased")
                        
                        noAds.setImage(UIImage(named: "noAds2"), for: .normal)
                        
                        SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                        
                        let alert = UIAlertController(title: "Purchase Successful", message: "You've successfully removed ads!", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancelAction = UIAlertAction(title: "OK",
                                                         style: .cancel, handler: nil)
                        
                        alert.addAction(cancelAction)
                        present(alert, animated: true)
                    }
                    
                    break
                    
                case .failed:
                    print("Purchase Failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
    
    func updateiCloud(){
        if (Reachability.isConnectedToNetwork()){
            
            if (defaults.bool(forKey: "UpdatedLocal")){
                
                iCloudKeyStore?.set(true, forKey: "synced")
                
                iCloudKeyStore?.set(Menu.bundle, forKey: "bundle")
                
                iCloudKeyStore?.set(Int64(coins), forKey: "Coins")
                
                if !(defaults.object(forKey: "noAdsPurchased") == nil){
                    let noAdsPurchased = defaults.bool(forKey: "noAdsPurchased")
                    iCloudKeyStore?.set(noAdsPurchased, forKey: "noAdsPurchased")
                }
                else {
                    iCloudKeyStore?.set(false, forKey: "noAdsPurchased")
                }
                
                if !(defaults.object(forKey: "AutoPop") == nil){
                    let autoLevel = defaults.integer(forKey: "AutoPop")
                    iCloudKeyStore?.set(Int64(autoLevel), forKey: "AutoPop")
                }
                else {
                    iCloudKeyStore?.set(0, forKey: "AutoPop")
                }
                
                if !(defaults.object(forKey: "SlowMo") == nil){
                    let slowLevel = defaults.integer(forKey: "SlowMo")
                    iCloudKeyStore?.set(Int64(slowLevel), forKey: "SlowMo")
                }
                else {
                    iCloudKeyStore?.set(0, forKey: "SlowMo")
                }
                
                if !(defaults.object(forKey: "Life") == nil){
                    let lifeLevel = defaults.integer(forKey: "Life")
                    iCloudKeyStore?.set(Int64(lifeLevel), forKey: "Life")
                }
                else {
                    iCloudKeyStore?.set(0, forKey: "Life")
                }
                
                if !(defaults.object(forKey: "Greenery") == nil){
                    let grassUnlocked = defaults.bool(forKey: "Greenery")
                    iCloudKeyStore?.set(grassUnlocked, forKey: "Greenery")
                }
                else {
                    iCloudKeyStore?.set(false, forKey: "Greenery")
                }
                
                if !(defaults.object(forKey: "Snowy") == nil){
                    let snowUnlocked = defaults.bool(forKey: "Snowy")
                    iCloudKeyStore?.set(snowUnlocked, forKey: "Snowy")
                }
                else {
                    iCloudKeyStore?.set(false, forKey: "Snowy")
                }
                
                if !(defaults.object(forKey: "Bubble Tea") == nil){
                    let tapiocaUnlocked = defaults.bool(forKey: "Bubble Tea")
                    iCloudKeyStore?.set(tapiocaUnlocked, forKey: "Bubble Tea")
                }
                else {
                    iCloudKeyStore?.set(false, forKey: "Bubble Tea")
                }
                iCloudKeyStore?.synchronize()
            }
        }
        
    }
}
