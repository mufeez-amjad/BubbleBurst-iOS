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
    
    @IBOutlet weak var Menu: UIImageView!
    
    var menu = "PowerUp"
    
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
    
    let removeAdsID = "2017101"
    let fiftyCoinsID = "2017102"
    let hundredCoinsID = "2017103"
    
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var noAdsPurchased = UserDefaults.standard.bool(forKey: "noAdsPurchased")
    
    override func viewDidLoad() {
        Back.setImage(UIImage(named: "back"), for: .normal)
        coinAd.setImage(UIImage(named: "coinAd"), for: .normal)
        buyCoins.setImage(UIImage(named: "buyCoin"), for: .normal)
        noAds.setImage(UIImage(named: "noAds"), for: .normal)
        restorePurchases.setImage(UIImage(named: "restore"), for: .normal)
        
        Menu.image = UIImage(named: "powerUpMenu")
        
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
        
        if noAdsPurchased {
            noAds.setImage(UIImage(named: "noAds2"), for: .normal)
        }
        
        // Fetch IAP Products available
        fetchAvailableProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (defaults.value(forKey: "Coins") != nil){
            coins = defaults.integer(forKey: "Coins")
        }
        coinsLabel.text = "\(coins)"
        
        //autoProgress.image = resizeImage(image: autoProgress.image!, scaledToSize: CGSize(width: autoProgress.bounds.size.width * CGFloat(autoWidth), height: autoProgress.bounds.size.height))
        updateProgress()
        
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
    
    @IBAction func customizePressed(_ sender: Any) {
        menu = "Customize"
        changeMenu()
    }
    
    @IBAction func powerUpPressed(_ sender: Any) {
        menu = "PowerUp"
        changeMenu()
    }
    
    func changeMenu(){
        if (menu == "Customize"){
            Menu.image = UIImage(named: "customizeMenu")
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
            
            
        }
        else if (menu == "PowerUp"){
            Menu.image = UIImage(named: "powerUpMenu")
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
        }
    }
    
    @IBAction func noAdsPressed(_ sender: Any) {
        purchaseMyProduct(product: iapProducts[0])
    }
    @IBAction func adCoinsPressed(_ sender: Any) {
        
    }
    @IBAction func restorePressed(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    @IBAction func buyCoinsPressed(_ sender: Any) {
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        noAdsPurchased = true
        UserDefaults.standard.set(noAdsPurchased, forKey: "noAdsPurchased")
        let alert = UIAlertController(title: "Restore Purchases", message: "You've successfully restored your purchase!", preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func fetchAvailableProducts()  {
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects: removeAdsID, fiftyCoinsID, hundredCoinsID
        )
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
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
            
            // Show its description
            //consumableLabel.text = firstProduct.localizedDescription + "\nfor just \(price1Str!)"
            // ------------------------------------------------
            
            
            
            // 2nd IAP Product (Non-Consumable) ------------------------------
            let secondProd = response.products[1] as SKProduct
            
            // Get its price from iTunes Connect
            numberFormatter.locale = secondProd.priceLocale
            let price2Str = numberFormatter.string(from: secondProd.price)
            
            // Show its description
            //nonConsumableLabel.text = secondProd.localizedDescription + "\nfor just \(price2Str!)"
            // ------------------------------------
        
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
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    // The Consumable product (10 coins) has been purchased -> gain 10 extra coins!
                    if productID == fiftyCoinsID {
                        
                        // Add 10 coins and save their total amount
                        coins += 50
                        UserDefaults.standard.set(coins, forKey: "coins")
                        coinsLabel.text = "\(coins)"
                        
                        let alert = UIAlertController(title: "Purchase Successful", message: "You've successfully purchased 50 coins!", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancelAction = UIAlertAction(title: "OK",
                                                         style: .cancel, handler: nil)
                        
                        alert.addAction(cancelAction)
                        present(alert, animated: true)
                        
                    }
                        
                    else if productID == hundredCoinsID {
                        coins += 100
                        UserDefaults.standard.set(coins, forKey: "coins")
                        coinsLabel.text = "\(coins)"
                        
                        let alert = UIAlertController(title: "Purchase Successful", message: "You've successfully purchased 100 coins!", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancelAction = UIAlertAction(title: "OK",
                                                         style: .cancel, handler: nil)
                        
                        alert.addAction(cancelAction)
                        present(alert, animated: true)
                    }
                    
                    else if productID == removeAdsID {
                        
                        // Save your purchase locally (needed only for Non-Consumable IAP)
                        noAdsPurchased = true
                        UserDefaults.standard.set(noAdsPurchased, forKey: "noAdsPurchased")
                        
                        noAds.setImage(UIImage(named: "noAds2"), for: .normal)

                        let alert = UIAlertController(title: "Purchase Successful", message: "You've successfully removed ads!", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let cancelAction = UIAlertAction(title: "OK",
                                                         style: .cancel, handler: nil)
                        
                        alert.addAction(cancelAction)
                        present(alert, animated: true)
                    }
                    
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
}
