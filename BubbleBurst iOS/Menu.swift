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

class Menu: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet var Logo: UIImageView!
    @IBOutlet var Play: UIButton!
    @IBOutlet var Info: UIButton!
    @IBOutlet var Back: UIButton!
    
    @IBOutlet var Classic: UIButton!
    @IBOutlet var Timed: UIButton!
    @IBOutlet var Endless: UIButton!
    
    @IBOutlet var EndlessLock: UIImageView!
    @IBOutlet var TimedLock: UIImageView!
    
    @IBOutlet var bannerAd: GADBannerView!
    @IBOutlet var Instructions: UIImageView!
    
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var pointsIcon: UIImageView!
    
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
        
        Classic.setImage(UIImage(named: "classic"), for: .normal)
        Timed.setImage(UIImage(named: "timed"), for: .normal)
        Endless.setImage(UIImage(named: "endless"), for: .normal)
        
        Play.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        Info.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        Back.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        Classic.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        
        self.Instructions.image = UIImage(named: "instructions")
        
        let defaults = UserDefaults.standard
        
        if (defaults.value(forKeyPath: "Points") == nil){
            points = 0
        }
        else {
            points = defaults.integer(forKey: "Points")
        }
        pointsLabel.text = "\(points)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Logo.center.y  -= view.bounds.height
        Play.center.y += view.bounds.height
        Info.center.y += view.bounds.height
        Back.center.x -= view.bounds.width
        pointsIcon.center.x -= view.bounds.width
        pointsLabel.center.x -= view.bounds.width
        
        Instructions.center.y -= view.bounds.height
        
        Classic.center.y += view.bounds.height
        Timed.center.y += view.bounds.height
        TimedLock.center.y += view.bounds.height
        Endless.center.y += view.bounds.height
        EndlessLock.center.y += view.bounds.height
        
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
                        self.Back.center.x -= self.view.bounds.width
        },
                       completion: { finished in
                        self.introIn()
        })
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
        gameMode = "Timed"
        performSegue(withIdentifier: "startPlay", sender: self)
    }
    @IBAction func endlessPressed(_ sender: Any) {
        gameMode = "Endless"
        performSegue(withIdentifier: "startPlay", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let yourVC = segue.destination as? GameViewController {
            yourVC.gameMode = gameMode
        }
    }
}


