//
//  Menu.swift
//  BubbleBurst iOS
//
//  Created by Mufeez Amjad on 2017-10-05.
//  Copyright © 2017 Mufeez Amjad. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AVFoundation
import GameKit

class Menu: UIViewController, GADBannerViewDelegate, GKGameCenterControllerDelegate {
    
    let defaults = UserDefaults.standard
    var gameSegue = false
    var transitionOut = false
    
    var infoScreen = false
    var playScreen = false
    var endlessLocked = true
    var timedLocked = true
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var Play: UIButton!
    @IBOutlet weak var Info: UIButton!
    @IBOutlet weak var Back: UIButton!
    @IBOutlet weak var Shop: UIButton!
    
    @IBOutlet weak var Classic: UIButton!
    @IBOutlet weak var Timed: UIButton!
    @IBOutlet weak var Endless: UIButton!
    
    @IBOutlet weak var Multiplayer: UIButton!
    
    @IBOutlet weak var unlockPopUp: UIImageView!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var unlockButton: UIButton!
    @IBOutlet var blur: UIVisualEffectView!
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    var endlessSelected = false
    var timedSelected = false
    
    //var endlessCost = 50000
    var endlessCost = 100
    var timedCost = 50
    //var timedCost = 20000

    @IBOutlet weak var TimedLock: UIImageView!
    @IBOutlet weak var EndlessLock: UIImageView!
    
    @IBOutlet weak var musicButton: UIButton!
    
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var dropdown: UIImageView!
    @IBOutlet weak var Settings: UIButton!
    
    @IBOutlet weak var bannerAd: GADBannerView!
    @IBOutlet weak var Instructions: UIImageView!
    
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsIcon: UIImageView!
    
    @IBOutlet weak var coinsIcon: UIImageView!
    @IBOutlet weak var coinsLabel: UILabel!
    
    var gameMode = "Classic"
    var points = 0
    var coins = 0
    
    static var player: AVAudioPlayer?
    
    var musicImage: String!
    var soundImage: String!
    var colorImage: String!
    
    static var music = true
    static var sound = true
    static var color = false
    
    var settings = false
    
    @IBOutlet weak var fade: UIImageView!
    
    static var bundle = "Classic"
    
    @IBOutlet weak var BG: UIImageView!
    
    @IBOutlet weak var PointsImage: UIImageView!
    @IBOutlet weak var PowerupImage: UIImageView!
    @IBOutlet weak var DangerImage: UIImageView!
    
    @IBOutlet weak var PointsTitle: UILabel!
    @IBOutlet weak var PowerupTitle: UILabel!
    @IBOutlet weak var DangerTitle: UILabel!
    @IBOutlet weak var PowerUpsTitle: UILabel!
    @IBOutlet weak var tapEachDetails: UILabel!
    
    override func viewDidLoad() {
        defaults.setValue(1500, forKey: "Coins")
        defaults.setValue(100000, forKey: "Points")
        defaults.setValue(false, forKey: "TimedLock")
        defaults.setValue(false, forKey: "EndlessLock")
        super.viewDidLoad()
        
        if (defaults.string(forKey: "bundle") != nil) {
            Menu.bundle = defaults.string(forKey: "bundle")!
        }
        
        //Request
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        
        //Set up ad
        bannerAd.adUnitID = "ca-app-pub-4669355053831786/6468914787"
        
        bannerAd.rootViewController = self
        bannerAd.delegate = self
        
        bannerAd.load(request)
        
        Play.setImage(UIImage(named: "play"), for: .normal)
        Info.setImage(UIImage(named: "info"), for: .normal)
        Back.setImage(UIImage(named: "back"), for: .normal)
        Shop.setImage(UIImage(named: "shop"), for: .normal)
        Settings.setImage(UIImage(named: "settings"), for: .normal)
        xButton.setImage(UIImage(named: "xButton"), for: .normal)
        unlockButton.setImage(UIImage(named: "unlockButton"), for: .normal)
        
        Classic.setImage(UIImage(named: "classic"), for: .normal)
        Timed.setImage(UIImage(named: "timed"), for: .normal)
        Endless.setImage(UIImage(named: "endless"), for: .normal)

        if (defaults.value(forKeyPath: "music") == nil || defaults.string(forKey: "music") == "on"){
            Menu.music = true
        }
        else {
            Menu.music = false
        }
        if (Menu.music == true) {
            musicButton.setImage(UIImage(named: "musicOn"), for: .normal)
        }
        else {
            musicButton.setImage(UIImage(named: "musicOff"), for: .normal)
        }
        
        if (defaults.value(forKeyPath: "sound") == nil || defaults.string(forKey: "sound") == "on"){
            Menu.sound = true
        }
        else {
            Menu.sound = false
        }
        if (Menu.sound == true) {
            soundButton.setImage(UIImage(named: "soundOn"), for: .normal)
        }
        else {
            soundButton.setImage(UIImage(named: "soundOff"), for: .normal)
        }
        
        colorButton.setImage(UIImage(named: "colorOff"), for: .normal)
        
        if defaults.string(forKey: "color") == "on" {
            Menu.color = true
            colorButton.setImage(UIImage(named: "colorOn"), for: .normal)
            
        }
        
        Multiplayer.setImage(UIImage(named: "multiplayersoon"), for: .normal)
        
        Play.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        Info.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        Back.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        Classic.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        
        dropdown.isHidden = true
        musicButton.isHidden = true
        soundButton.isHidden = true
        colorButton.isHidden = true
        
        if (defaults.object(forKey: "EndlessLock") == nil){
            endlessLocked = true
        }
        else if (defaults.bool(forKey: "EndlessLock") == false){
            endlessLocked = false
        }
        
        if (defaults.object(forKey: "TimedLock") == nil){
            timedLocked = true
        }
        else if (defaults.bool(forKey: "TimedLock") == false){
            timedLocked = false
        }
        if (Menu.music) {
            AppDelegate.playMusic()
        }
        
        Logo.center.y  -= view.bounds.height
        Play.center.y += view.bounds.height
        Info.center.y += view.bounds.height
        Shop.center.y += view.bounds.height
        Settings.center.y += view.bounds.height
        
        Back.center.x -= view.bounds.width
        
        pointsIcon.center.x -= view.bounds.width
        pointsLabel.center.x -= view.bounds.width
        
        coinsIcon.center.x -= view.bounds.width
        coinsLabel.center.x -= view.bounds.width
        
        Instructions.center.y -= view.bounds.height
        PointsImage.center.y -= view.bounds.height
        PointsTitle.center.y -= view.bounds.height
        PowerupImage.center.y -= view.bounds.height
        PowerupTitle.center.y -= view.bounds.height
        DangerImage.center.y -= view.bounds.height
        DangerTitle.center.y -= view.bounds.height
        PowerUpsTitle.center.y -= view.bounds.height
        tapEachDetails.center.y -= view.bounds.height
        
        Classic.center.y += view.bounds.height
        Timed.center.y += view.bounds.height
        TimedLock.center.y += view.bounds.height
        
        Endless.center.y += view.bounds.height
        EndlessLock.center.y += view.bounds.height
        
        Multiplayer.center.y += view.bounds.height
        
        unlockPopUp.center.y += view.bounds.height
        xButton.center.y += view.bounds.height
        unlockButton.center.y += view.bounds.height
        costLabel.center.y += view.bounds.height
        blur.alpha = 0.0
        
        authenticateLocalPlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (defaults.value(forKeyPath: "Points") == nil){
            points = 0
        }
        else {
            points = defaults.integer(forKey: "Points")
        }
        
        if (defaults.value(forKeyPath: "Coins") == nil) {
            coins = 0
        }
        else {
            coins = defaults.integer(forKey: "Coins")
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:points))
        
        pointsLabel.text = formattedNumber
        
        coinsLabel.text = "\(coins)"
        
        fadeIn()
        introIn()
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
    override func viewDidDisappear(_ animated: Bool) {
        if (infoScreen){
            //instructionsOut()
        }
        if (playScreen){
            //playOut()
        }
        
        else { //main menu
            /*Logo.center.y  -= view.bounds.height
            Play.center.y += view.bounds.height
            Info.center.y += view.bounds.height
            Shop.center.y += view.bounds.height
            Settings.center.y += view.bounds.height
            
            pointsIcon.center.x -= view.bounds.width
            pointsLabel.center.x -= view.bounds.width
            
            coinsIcon.center.x -= view.bounds.width
            coinsLabel.center.x -= view.bounds.width
            
            if (settings){
                hideSettings()
            }*/
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if (timedLocked) {
            TimedLock.isHidden = false
        }
        else {
            TimedLock.isHidden = true
        }

        if (endlessLocked) {
            EndlessLock.isHidden = false
        }
        else {
            EndlessLock.isHidden = true
        }
        
        var BubbleType = "Bubble"
        
        if (Menu.bundle == "Classic"){
            BG.image = UIImage(named: "BG")
        }
            
        else if (Menu.bundle == "Bubble Tea"){
            BG.image = UIImage(named: "milkBG")
            BubbleType = "Tapioca"
        }
            
        else if (Menu.bundle == "Snowy"){
            BG.image = UIImage(named: "snowBG")
            BubbleType = "Snow"
        }
            
        else if (Menu.bundle == "Greenery"){
            BG.image = UIImage(named: "grassBG")
        }
        
        PointsImage.image = UIImage(named: BubbleType)
        if (Menu.color) {
            PowerupImage.image = UIImage(named: BubbleType + "Y")
            PowerupTitle.textColor = UIColor(red: 0.89, green: 0.84, blue: 0.27, alpha: 1.0) //yellow
            PowerUpsTitle.textColor = UIColor(red: 0.89, green: 0.84, blue: 0.27, alpha: 1.0)
            tapEachDetails.textColor = UIColor(red: 0.89, green: 0.84, blue: 0.27, alpha: 1.0)
        }
        else {
            PowerupImage.image = UIImage(named: BubbleType + "G")
            PowerupTitle.textColor = UIColor(red: 0.32, green: 0.71, blue: 0.38, alpha: 1.0) //green
            PowerUpsTitle.textColor = UIColor(red: 0.32, green: 0.71, blue: 0.38, alpha: 1.0)
            tapEachDetails.textColor = UIColor(red: 0.32, green: 0.71, blue: 0.38, alpha: 1.0)
        }
        if (Menu.bundle != "Bubble Tea") {
            PointsTitle.textColor = UIColor(red: 0.8, green: 0.95, blue: 1.0, alpha: 1.0) //blue
        }
        else {
            PointsTitle.textColor = UIColor(red: 0.38, green: 0.19, blue: 0.02, alpha: 1.0) //tapioca brown
        }
        DangerImage.image = UIImage(named: BubbleType + "R")
   }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func introOut(menu: Int){
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.Logo.center.y -= self.view.bounds.height
                        self.Play.center.y += self.view.bounds.height
                        self.Info.center.y += self.view.bounds.height
                        self.Shop.center.y += self.view.bounds.height
                        self.Settings.center.y += self.view.bounds.height

                        self.pointsIcon.center.x -= self.view.bounds.width
                        self.pointsLabel.center.x -= self.view.bounds.width
                        
                        self.coinsIcon.center.x -= self.view.bounds.width
                        self.coinsLabel.center.x -= self.view.bounds.width
        },
                       completion: { finished in
                        if (menu == 1) {
                            self.instructionsIn()
                        }
                        else if (menu == 2){
                            self.performSegue(withIdentifier: "toShop", sender: self)
                        }
                        else {
                            self.playIn()
                        }
        })
        settings = false
        hideSettings()
    }
    
    func introIn(){
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.Logo.center.y += self.view.bounds.height
        },
                       completion: nil
        )
        
        UIView.animate(withDuration: 0.7, delay: 0.7,
                       options: [.curveEaseOut],
                       animations: {
                        self.Play.center.y -= self.view.bounds.height
                        self.Info.center.y -= self.view.bounds.height
                        self.Shop.center.y -= self.view.bounds.height
                        self.Settings.center.y -= self.view.bounds.height
        },
                       completion: nil
        )
        
        UIView.animate(withDuration: 0.7, delay: 1.4,
                       options: [.curveEaseOut],
                       animations: {
                        self.pointsIcon.center.x += self.view.bounds.width
                        self.pointsLabel.center.x += self.view.bounds.width
                        self.coinsIcon.center.x += self.view.bounds.width
                        self.coinsLabel.center.x += self.view.bounds.width
        },
                       completion: nil
        )
    }
    
    func revealSettings(){
        UIView.animate(withDuration: 1, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.dropdown.isHidden = false
                        self.colorButton.isHidden = false
                        self.soundButton.isHidden = false
                        self.musicButton.isHidden = false
        },
                       completion: nil
        )
    }
    
    func hideSettings(){
        UIView.animate(withDuration: 1, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.dropdown.isHidden = true
                        self.colorButton.isHidden = true
                        self.soundButton.isHidden = true
                        self.musicButton.isHidden = true
        },
                       completion: nil
        )
    }
    
    func instructionsIn(){
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.Instructions.center.y += self.view.bounds.height
                        self.PointsImage.center.y += self.view.bounds.height
                        self.PointsTitle.center.y += self.view.bounds.height
                        self.PowerupImage.center.y += self.view.bounds.height
                        self.PowerupTitle.center.y += self.view.bounds.height
                        self.DangerImage.center.y += self.view.bounds.height
                        self.DangerTitle.center.y += self.view.bounds.height
                        self.PowerUpsTitle.center.y += self.view.bounds.height
                        self.tapEachDetails.center.y += self.view.bounds.height
                        self.Back.center.x += self.view.bounds.width
        },
                       completion: nil
        )
    }
    
    func instructionsOut(){
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.Instructions.center.y -= self.view.bounds.height
                        self.PointsImage.center.y -= self.view.bounds.height
                        self.PointsTitle.center.y -= self.view.bounds.height
                        self.PowerupImage.center.y -= self.view.bounds.height
                        self.PowerupTitle.center.y -= self.view.bounds.height
                        self.DangerImage.center.y -= self.view.bounds.height
                        self.DangerTitle.center.y -= self.view.bounds.height
                        self.PowerUpsTitle.center.y -= self.view.bounds.height
                        self.tapEachDetails.center.y -= self.view.bounds.height
                        self.Back.center.x -= self.view.bounds.width
        },
                       completion: { finished in
                        self.introIn()
        })
    }
    
    func toGame(){
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.Classic.center.y += self.view.bounds.height
                        self.Timed.center.y += self.view.bounds.height
                        self.TimedLock.center.y += self.view.bounds.height
                        self.Endless.center.y += self.view.bounds.height
                        self.EndlessLock.center.y += self.view.bounds.height
                        self.Multiplayer.center.y += self.view.bounds.height
                        self.Back.center.x -= self.view.bounds.width
        },
                       completion: { finished in
                        self.performSegue(withIdentifier: "startPlay", sender: self)
        })
        
        fadeOut()
    }
    
    func playIn(){
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.Classic.center.y -= self.view.bounds.height
                        self.Timed.center.y -= self.view.bounds.height
                        self.TimedLock.center.y -= self.view.bounds.height
                        self.Endless.center.y -= self.view.bounds.height
                        self.EndlessLock.center.y -= self.view.bounds.height
                        self.Multiplayer.center.y -= self.view.bounds.height
                        self.Back.center.x += self.view.bounds.width
        },
                       completion: nil
        )
    }
    
    func playOut(){
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.Classic.center.y += self.view.bounds.height
                        self.Timed.center.y += self.view.bounds.height
                        self.TimedLock.center.y += self.view.bounds.height
                        self.Endless.center.y += self.view.bounds.height
                        self.EndlessLock.center.y += self.view.bounds.height
                        self.Multiplayer.center.y += self.view.bounds.height
                        self.Back.center.x -= self.view.bounds.width
        },
                       completion: { finished in
                        self.introIn()
        })
    }
    
    func unlockIn(){
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.unlockPopUp.center.y -= self.view.bounds.height
                        self.xButton.center.y -= self.view.bounds.height
                        self.unlockButton.center.y -= self.view.bounds.height
                        self.costLabel.center.y -= self.view.bounds.height
                        self.Back.center.x -= self.view.bounds.width
        },
                       completion: nil
        )
        
        UIView.animate(withDuration: 0.7, delay: 0.7,
                       options: [.curveEaseOut],
                       animations: {
                        self.pointsIcon.center.x += self.view.bounds.width
                        self.pointsLabel.center.x += self.view.bounds.width
                        self.coinsIcon.center.x += self.view.bounds.width
                        self.coinsLabel.center.x += self.view.bounds.width
        },
                       completion: nil
        )
        
        // fade in
        UIView.animate(withDuration: 1.0, animations: {
            self.blur.alpha = 0.8
        },
                       completion: nil
        )
        
    }
    func unlockOut(){
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.unlockPopUp.center.y += self.view.bounds.height
                        self.xButton.center.y += self.view.bounds.height
                        self.unlockButton.center.y += self.view.bounds.height
                        self.costLabel.center.y += self.view.bounds.height
                        self.pointsIcon.center.x -= self.view.bounds.width
                        self.pointsLabel.center.x -= self.view.bounds.width
                        self.coinsIcon.center.x -= self.view.bounds.width
                        self.coinsLabel.center.x -= self.view.bounds.width
                        self.Back.center.x += self.view.bounds.width
                        self.blur.alpha = 0.0
        },
                       completion: nil
        )
    }
    
    
    @objc func buttonClicked(_ sender: AnyObject?) {
        
        if sender === Info {
            infoScreen = true
            introOut(menu: 1)
        }
            
        else if sender === Play {
            playScreen = true
            introOut(menu: 3)
        }
            
        else if sender === Back {
            if playScreen {
                playOut()
                playScreen = false
            }
            if infoScreen {
                instructionsOut()
                infoScreen = false
            }
        }
        
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
        infoScreen = false
        playScreen = false
        
        self.viewDidLoad()
        self.viewWillAppear(true)
    }
    
    
    @IBAction func classicPressed(_ sender: Any) {
        gameMode = "Classic"
        toGame()
        //performSegue(withIdentifier: "startPlay", sender: self)
    }
    
    @IBAction func timedPressed(_ sender: Any) {
        if (!timedLocked) {
            gameMode = "Timed"
            toGame()
            //performSegue(withIdentifier: "startPlay", sender: self)
        }
        else {
            if points < timedCost {
                unlockButton.isHidden = true
            }
            else {
                unlockButton.isHidden = false
            }
            timedSelected = true
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:timedCost))
            costLabel.text = formattedNumber
            unlockIn()
        }
    }
    
    @IBAction func endlessPressed(_ sender: Any) {
        if (!endlessLocked) {
            gameMode = "Endless"
            toGame()
            //performSegue(withIdentifier: "startPlay", sender: self)
        }
        else {
            if points < endlessCost {
                unlockButton.isHidden = true
            }
            else {
                unlockButton.isHidden = false
            }
            endlessSelected = true
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:endlessCost))
            costLabel.text = formattedNumber
            unlockIn()
        }
    }
    
    @IBAction func xButtonPressed(_ sender: Any) {
        unlockOut()
        timedSelected = false
        endlessSelected = false
    }
    
    @IBAction func unlockPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        if (endlessSelected && points >= endlessCost){
            points -= endlessCost
            defaults.set(points, forKey: "Points")
            defaults.set(false, forKey: "EndlessLock")
            endlessLocked = false
            EndlessLock.isHidden = true
            unlockOut()
        }
        else if (timedSelected && points >= timedCost){
            points -= timedCost
            defaults.set(points, forKey: "Points")
            defaults.set(false, forKey: "TimedLock")
            timedLocked = false
            TimedLock.isHidden = true
            unlockOut()
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:points))
        
        pointsLabel.text = formattedNumber
    }
    
    @IBAction func multiplayerPressed(_ sender: Any) {
    }
    
    @IBAction func settingsPressed(_ sender: Any) {
        settings = !settings
        if (settings) {
            revealSettings()
        }
        else {
            hideSettings()
        }
    }
    
    @IBAction func musicPressed(_ sender: Any) {
        Menu.music = !Menu.music
        if (!Menu.music){
            musicButton.setImage(UIImage(named: "musicOff"), for: .normal)
            defaults.set("off", forKey: "music")
            AppDelegate.player?.stop()
        }
        else {
            musicButton.setImage(UIImage(named: "musicOn"), for: .normal)
            defaults.set("on", forKey: "music")
            AppDelegate.playMusic()
        }
    }
    
    @IBAction func soundPressed(_ sender: Any) {
        Menu.sound = !Menu.sound
        if (!Menu.sound){
            soundButton.setImage(UIImage(named: "soundOff"), for: .normal)
            defaults.set("off", forKey: "sound")
        }
        else {
            soundButton.setImage(UIImage(named: "soundOn"), for: .normal)
            defaults.set("on", forKey: "sound")
        }
    }
   
    @IBAction func colorPressed(_ sender: Any) {
        Menu.color = !Menu.color
        
        var BubbleType = "Bubble"
        
        if (Menu.bundle == "Bubble Tea"){
            BubbleType = "Tapioca"
        }
        else if (Menu.bundle == "Snowy"){
            BubbleType = "Snow"
        }
        
        if (!Menu.color){
            colorButton.setImage(UIImage(named: "colorOff"), for: .normal)
            defaults.set("off", forKey: "color")
            PowerupImage.image = UIImage(named: BubbleType + "G")
            PowerupTitle.textColor = UIColor(red: 0.32, green: 0.71, blue: 0.38, alpha: 1.0) //green
            PowerUpsTitle.textColor = UIColor(red: 0.32, green: 0.71, blue: 0.38, alpha: 1.0)
            tapEachDetails.textColor = UIColor(red: 0.32, green: 0.71, blue: 0.38, alpha: 1.0)
        }
        else {
            colorButton.setImage(UIImage(named: "colorOn"), for: .normal)
            defaults.set("on", forKey: "color")
            PowerupImage.image = UIImage(named: BubbleType + "Y")
            
            PowerupTitle.textColor = UIColor(red: 0.89, green: 0.84, blue: 0.27, alpha: 1.0) //yellow
            PowerUpsTitle.textColor = UIColor(red: 0.89, green: 0.84, blue: 0.27, alpha: 1.0)
            tapEachDetails.textColor = UIColor(red: 0.89, green: 0.84, blue: 0.27, alpha: 1.0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let yourVC = segue.destination as? GameViewController {
            yourVC.gameMode = gameMode
            gameSegue = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if gameSegue {
            /*if let nav = self.navigationController {
                var stack = nav.viewControllers
                stack.remove(at: 0)
                nav.setViewControllers(stack, animated: true)
            }*/
            gameSegue = false
        }
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
    
    @IBAction func shopPressed(_ sender: Any) {
        introOut(menu: 2)
    }
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}


