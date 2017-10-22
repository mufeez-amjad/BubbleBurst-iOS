//
//  Menu.swift
//  BubbleBurst iOS
//
//  Created by Mufeez Amjad on 2017-10-05.
//  Copyright © 2017 Mufeez Amjad. All rights reserved.
//

import UIKit
import GoogleMobileAds

var infoScreen = false
var playScreen = false
var endlessLocked = true
var timedLocked = true

class Menu: UIViewController, GADBannerViewDelegate {
    
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
    
    var endlessSelected = false
    var timedSelected = false
    
    var endlessCost = 75000
    var timedCost = 50000

    @IBOutlet weak var TimedLock: UIImageView!
    @IBOutlet weak var EndlessLock: UIImageView!
    
    @IBOutlet weak var bannerAd: GADBannerView!
    @IBOutlet weak var Instructions: UIImageView!
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var pointsIcon: UIImageView!
    
    var gameMode = "Classic"
    var points = 0
    
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
        
        // Do any additional setup after loading the view, typically from a nib.
        Play.setImage(UIImage(named: "play"), for: .normal)
        Info.setImage(UIImage(named: "info"), for: .normal)
        Back.setImage(UIImage(named: "back"), for: .normal)
        Shop.setImage(UIImage(named: "shop"), for: .normal)
        xButton.setImage(UIImage(named: "xButton"), for: .normal)
        unlockButton.setImage(UIImage(named: "unlockButton"), for: .normal)
        
        Classic.setImage(UIImage(named: "classic"), for: .normal)
        Timed.setImage(UIImage(named: "timed"), for: .normal)
        Endless.setImage(UIImage(named: "endless"), for: .normal)
        
        Multiplayer.setImage(UIImage(named: "multiplayersoon"), for: .normal)
        
        Play.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        Info.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        Back.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        Classic.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        
        self.Instructions.image = UIImage(named: "instructions")
        
        let defaults = UserDefaults.standard
        defaults.set(125000, forKey: "Points")
        if (defaults.value(forKeyPath: "Points") == nil){
            points = 0
        }
        else {
            points = defaults.integer(forKey: "Points")
        }
        
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:points))
        
        pointsLabel.text = formattedNumber
        
        if (defaults.object(forKey: "EndlessLock") == nil){
            endlessLocked = true
        }
        else if (defaults.bool(forKey: "EndlessLock") == false){
            //endlessLocked = false
        }
        
        if (defaults.object(forKey: "TimedLock") == nil){
            timedLocked = true
        }
        else if (defaults.bool(forKey: "TimedLock") == false){
            //timedLocked = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Logo.center.y  -= view.bounds.height
        Play.center.y += view.bounds.height
        Info.center.y += view.bounds.height
        Shop.center.y += view.bounds.height

        Back.center.x -= view.bounds.width
        
        pointsIcon.center.x -= view.bounds.width
        pointsLabel.center.x -= view.bounds.width
        
        Instructions.center.y -= view.bounds.height
        
        Classic.center.y += view.bounds.height
        Timed.center.y += view.bounds.height
        TimedLock.center.y += view.bounds.height
        if (timedLocked) {
            TimedLock.isHidden = false
        }
        else {
            TimedLock.isHidden = true
        }

        Endless.center.y += view.bounds.height
        EndlessLock.center.y += view.bounds.height
        if (endlessLocked) {
            EndlessLock.isHidden = false
        }
        else {
            EndlessLock.isHidden = true
        }

        Multiplayer.center.y += view.bounds.height

        unlockPopUp.center.y += view.bounds.height
        xButton.center.y += view.bounds.height
        unlockButton.center.y += view.bounds.height
        costLabel.center.y += view.bounds.height
        blur.alpha = 0.0
        introIn()
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

                        self.pointsIcon.center.x -= self.view.bounds.width
                        self.pointsLabel.center.x -= self.view.bounds.width
        },
                       completion: { finished in
                        if (menu == 1) {
                            self.instructionsIn()
                        }
                        else {
                            self.playIn()
                        }
        })
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

        },
                       completion: nil
        )
        
        UIView.animate(withDuration: 0.7, delay: 1.4,
                       options: [.curveEaseOut],
                       animations: {
                        self.pointsIcon.center.x += self.view.bounds.width
                        self.pointsLabel.center.x += self.view.bounds.width
        },
                       completion: nil
        )
    }
    
    func instructionsIn(){
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        self.Instructions.center.y += self.view.bounds.height
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
                        self.Back.center.x -= self.view.bounds.width
        },
                       completion: { finished in
                        self.introIn()
        })
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
            introOut(menu: 2)
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
        performSegue(withIdentifier: "startPlay", sender: self)
    }
    
    @IBAction func timedPressed(_ sender: Any) {
        if (!timedLocked) {
            gameMode = "Timed"
            performSegue(withIdentifier: "startPlay", sender: self)
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
            performSegue(withIdentifier: "startPlay", sender: self)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let yourVC = segue.destination as? GameViewController {
            yourVC.gameMode = gameMode
        }
    }
}


