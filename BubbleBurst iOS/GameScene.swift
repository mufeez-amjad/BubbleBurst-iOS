//
//  GameScene.swift
//  BubbleBurst iOS
//
//  Created by Mufeez Amjad on 2017-09-30.
//  Copyright © 2017 Mufeez Amjad. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    let defaults = UserDefaults.standard
    
    static var gamePaused = false
    var fingerDown = false
    var gameStarted = false
    
    var viewController: GameViewController!
    var timesPaused = 0
    
    var bubbles = [Bubble]()
    var bubbleTimer:Timer!
    
    var coins = [Coin]()
    var coinTimer:Timer!
    
    var gameTimer:Timer!
    
    var score = 0
    var coinCount = 0
    var lives = 10
    var time = 0
    var gameOver = false
    var gameEnded = false
    
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var coinsLabel: SKLabelNode!
    
    var timerLabel: SKLabelNode!
    var timeLabel: SKLabelNode!
    
    var powerUpLabel: SKLabelNode!
    
    var oneUpTimer: Timer!
    var slowMoTimer: Timer!
    var freezeTimer: Timer!
    var superPopTimer: Timer!
    var autoPopTimer: Timer!
    
    var countdownTimer: Timer!
    
    var oneUp = 3
    var slowMo = 3
    var freeze = 5
    var superPop = 3
    var autoPop = 5
    
    var autoPopLine: SKSpriteNode!
    
    var isOneUp = false
    var isSlowMo = false
    var isFreeze = false
    var isSuperPop = false
    var isAutoPop = false
    var beforeFreezeSpeed: Double = 0.0
    
    var oneUpIcon: SKSpriteNode!
    var slowMoIcon: SKSpriteNode!
    var freezeIcon: SKSpriteNode!
    var superPopIcon: SKSpriteNode!
    var autoPopIcon: SKSpriteNode!
    
    var inactiveOneUp: SKSpriteNode!
    var inactiveSlowMo: SKSpriteNode!
    var inactiveFreeze: SKSpriteNode!
    var inactiveSuperPop: SKSpriteNode!
    var inactiveAutoPop: SKSpriteNode!
    
    var timerIcon: SKSpriteNode!
    
    var pathEmitter: SKEmitterNode?
    
    let sizeUp = SKAction.scale(to: 1, duration: 1)
    let wait = SKAction.wait(forDuration: 2)
    let sizeDown = SKAction.scale(to: 0, duration: 1)
    
    let disappear = SKAction.scale(to: 1, duration: 0)
    
    var reveal: SKAction!
    
    var countdownAction: SKAction!
    
    
    var startsIn = 3
    var gameMode: String!
    
    var previousLocation = CGPoint(x:-100,y: -100)
    
    var bubblePlayer: AVAudioPlayer?
    var coinPlayer: AVAudioPlayer?
    
    var autoLevel = 0
    var slowLevel = 1
    var lifeLevel = 1
    
    var unpaused = false
    
    override func sceneDidLoad() {
        if !(defaults.object(forKey: "AutoPop") == nil){
            autoLevel = defaults.integer(forKey: "AutoPop")
        }
        
        if !(defaults.object(forKey: "SlowMo") == nil){
            slowLevel = defaults.integer(forKey: "SlowMo")
        }
        
        if !(defaults.object(forKey: "Life") == nil){
            lifeLevel = defaults.integer(forKey: "Life")
        }
        
        var bg: SKSpriteNode!
        
        if (Menu.bundle == "Classic"){
            bg = SKSpriteNode(imageNamed: "BGGame")
        }
            
        else if (Menu.bundle == "Bubble Tea"){
            bg = SKSpriteNode(imageNamed: "milkGame")
        }
            
        else if (Menu.bundle == "Snowy"){
            bg = SKSpriteNode(imageNamed: "snowGame")
        }
            
        else if (Menu.bundle == "Greenery"){
            bg = SKSpriteNode(imageNamed: "grassGame")
        }
        
        bg.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        bg.zPosition = -1
        self.addChild(bg)
        
        autoPopLine = SKSpriteNode(imageNamed: "dashedLine")
        autoPopLine.position = CGPoint(x: autoPopLine.frame.width / 2, y: self.frame.height / 2 - autoPopLine.frame.height / 2)
        autoPopLine.isHidden = true
        self.addChild(autoPopLine)
        
        oneUpIcon = SKSpriteNode(imageNamed: "1Up")
        slowMoIcon = SKSpriteNode(imageNamed: "slowMo")
        freezeIcon = SKSpriteNode(imageNamed: "freeze")
        superPopIcon = SKSpriteNode(imageNamed: "superPop")
        autoPopIcon = SKSpriteNode(imageNamed: "auto")
        timerIcon = SKSpriteNode(imageNamed: "stopwatch")
        
        inactiveOneUp = SKSpriteNode(imageNamed: "1Up2")
        inactiveSlowMo = SKSpriteNode(imageNamed: "slowMo2")
        inactiveFreeze = SKSpriteNode(imageNamed: "freeze2")
        inactiveSuperPop = SKSpriteNode(imageNamed: "superPop2")
        inactiveAutoPop = SKSpriteNode(imageNamed: "auto2")
        
        pathEmitter = SKEmitterNode(fileNamed: "MyParticle")
        timerIcon.position = CGPoint(x: 250,y: self.frame.height - 100)
        timerIcon.xScale = 0.07
        timerIcon.yScale = 0.07
        self.addChild(timerIcon)
        
        autoPopIcon.position = CGPoint(x: timerIcon.position.x + 100,y: self.frame.height - 100)
        autoPopIcon.xScale = 0.07
        autoPopIcon.yScale = 0.07
        self.addChild(autoPopIcon)
        
        inactiveAutoPop.position = CGPoint(x: timerIcon.position.x + 100,y: self.frame.height - 100)
        inactiveAutoPop.xScale = 0.07
        inactiveAutoPop.yScale = 0.07
        self.addChild(inactiveAutoPop)
        
        slowMoIcon.position = CGPoint(x: autoPopIcon.position.x + autoPopIcon.size.width * 1.1,y: self.frame.height - 100)
        slowMoIcon.xScale = 0.07
        slowMoIcon.yScale = 0.07
        self.addChild(slowMoIcon)
        
        inactiveSlowMo.position = CGPoint(x: autoPopIcon.position.x + autoPopIcon.size.width * 1.1,y: self.frame.height - 100)
        inactiveSlowMo.xScale = 0.07
        inactiveSlowMo.yScale = 0.07
        self.addChild(inactiveSlowMo)
        
        oneUpIcon.position = CGPoint(x: slowMoIcon.position.x + slowMoIcon.size.width * 1.1,y: self.frame.height - 100)
        oneUpIcon.xScale = 0.07
        oneUpIcon.yScale = 0.07
        self.addChild(oneUpIcon)
        
        inactiveOneUp.position = CGPoint(x: slowMoIcon.position.x + slowMoIcon.size.width * 1.1,y: self.frame.height - 100)
        inactiveOneUp.xScale = 0.07
        inactiveOneUp.yScale = 0.07
        self.addChild(inactiveOneUp)
        
        freezeIcon.position = CGPoint(x: oneUpIcon.position.x + oneUpIcon.size.width * 1.1,y: self.frame.height - 100)
        freezeIcon.xScale = 0.07
        freezeIcon.yScale = 0.07
        self.addChild(freezeIcon)
        
        inactiveFreeze.position = CGPoint(x: oneUpIcon.position.x + oneUpIcon.size.width * 1.1,y: self.frame.height - 100)
        inactiveFreeze.xScale = 0.07
        inactiveFreeze.yScale = 0.07
        self.addChild(inactiveFreeze)
        
        superPopIcon.position = CGPoint(x: freezeIcon.position.x + freezeIcon.size.width * 1.1,y: self.frame.height - 100)
        superPopIcon.xScale = 0.07
        superPopIcon.yScale = 0.07
        self.addChild(superPopIcon)
        
        inactiveSuperPop.position = CGPoint(x: freezeIcon.position.x + freezeIcon.size.width * 1.1,y: self.frame.height - 100)
        inactiveSuperPop.xScale = 0.07
        inactiveSuperPop.yScale = 0.07
        self.addChild(inactiveSuperPop)
        
        
        reveal = SKAction.sequence([sizeUp, wait, sizeDown])
        countdownAction = SKAction.sequence([sizeUp, wait, disappear])
        
    }
    
    override func didMove(to view: SKView) {
        Bubble.gameMode = gameMode
        
        
        scoreLabel = SKLabelNode(fontNamed: "Bubblegum")
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: 150,y: self.frame.height - 100)
        self.addChild(scoreLabel)
        
        livesLabel = SKLabelNode(fontNamed: "Bubblegum")
        livesLabel.text = "\(lives)"
        livesLabel.fontSize = 40
        livesLabel.position = CGPoint(x: 150,y: self.frame.height - 200)
        livesLabel.zPosition = 1
        if (gameMode == "Classic") {
            self.addChild(livesLabel)
        }
        
        coinsLabel = SKLabelNode(fontNamed: "Bubblegum")
        coinsLabel.text = "\(coinCount)"
        coinsLabel.fontSize = 40
        coinsLabel.zPosition = 1
        if (gameMode != "Endless") {
            coinsLabel.position = CGPoint(x: 150,y: self.frame.height - 300)
        }
        else {
            coinsLabel.position = CGPoint(x: 150,y: self.frame.height - 200)
        }
        self.addChild(coinsLabel)
        
        
        
        timeLabel = SKLabelNode(fontNamed: "Bubblegum")
        timeLabel.text = "\(time)"
        timeLabel.fontSize = 40
        timeLabel.position = CGPoint(x: 150,y: self.frame.height - 200)
        timeLabel.zPosition = 1
        if (gameMode == "Timed"){
            self.addChild(timeLabel)
        }
        
        timerLabel = SKLabelNode(fontNamed: "Bubblegum")
        timerLabel.text = "10"
        timerLabel.fontSize = 25
        timerLabel.position = CGPoint(x: 250,y: self.frame.height - 115)
        self.addChild(timerLabel)
        
        powerUpLabel = SKLabelNode(fontNamed: "Bubblegum")
        powerUpLabel.text = "SLOW-MO"
        powerUpLabel.fontSize = 60
        powerUpLabel.position = CGPoint(x: self.frame.width / 2,y: self.frame.height / 2)
        powerUpLabel.setScale(0)
        powerUpLabel.alpha = 60
        powerUpLabel.zPosition = 1
        self.addChild(powerUpLabel)
        if (gameMode == "Timed"){
            
        }
        else {
            startCountdown()
        }
        
        pathEmitter?.position = CGPoint(x:-100,y: -100)
        self.addChild(pathEmitter!)
        pathEmitter?.targetNode = self
        
        livesLabel.isHidden = true
        coinsLabel.isHidden = true
        scoreLabel.isHidden = true
        timeLabel.isHidden = true
    }
    
    func playPop() {
        
        guard let url = Bundle.main.url(forResource: "pop", withExtension: "wav") else {
            print("url not found")
            return
        }
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            bubblePlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            guard let bubblePlayer = bubblePlayer else { return }
            
            bubblePlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playCoin() {
        
        guard let url = Bundle.main.url(forResource: "coin", withExtension: "mp3") else {
            print("url not found")
            return
        }
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            coinPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let coinPlayer = coinPlayer else { return }
            
            coinPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func startCountdown(){
        if startsIn >= 0 {
            powerUpLabel.text = "\(startsIn)"
            if (startsIn == 0){
                powerUpLabel.text = "START!"
            }
            powerUpLabel.run(countdownAction)
            startsIn -= 1
            let when = DispatchTime.now() + 1
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.startCountdown()
            }
        }
        else if !(GameScene.gamePaused){
            powerUpLabel.text = ""
            powerUpLabel.setScale(0)
            startBubbles()
            gameStarted = true
            if (gameMode == "Timed") {
                if gameTimer == nil {
                    gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stopWatch), userInfo: nil, repeats: true)
                }
            }
        }
        
    }
    
    @objc func stopWatch(){
        time += 1
        viewController.livesTimeLabel.text = "\(time)"
        //timeLabel.text = "\(time)"
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fingerDown = true
        if (GameScene.gamePaused) {
            unPause()
        }
        
        let touch = touches.first as! UITouch
        let touchLocation = touch.location(in: self)
        previousLocation = touchLocation
        pathEmitter?.position = touchLocation
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.location(in: self)
        previousLocation = touchLocation
        pathEmitter?.position = touchLocation
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fingerDown = false
        if (gameMode == "Timed"){
            if (startsIn < 0) {
                if (timesPaused <= 2) {
                    pause()
                }
                else {
                    gameOver = true
                }
            }
        }
        previousLocation = CGPoint(x: -100,y: -100)
        pathEmitter?.position = CGPoint(x:-100,y: -100)
    }
    
    func endlessPowerUp(bubble: Bubble){
        var powerUp: Int!
        if (Bubble.riseSpeed > 5){
            powerUp = Int(arc4random_uniform(30))
            if (autoLevel == 0) {
                powerUp = Int(arc4random_uniform(27)) + 3
            }
            if powerUp <= 3 {
                isAutoPop = true
                if (autoLevel == 1){
                    autoPop = 5
                }
                else if (autoLevel == 2){
                    autoPop = 10
                }
                else if (autoLevel == 3){
                    autoPop = 15
                }
                autoPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(autoPopCountdown), userInfo: nil, repeats: true)
                powerUpLabel.text = "Auto Pop"
                powerUpLabel.run(reveal)
                autoPopLine.isHidden = false
            }
                
            else if powerUp < 10 {
                if (Bubble.riseSpeed > 15){
                    freezeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(freezeCountdown), userInfo: nil, repeats: true)
                    isFreeze = true
                    Bubble.frozen = true
                    beforeFreezeSpeed = Bubble.riseSpeed
                    Bubble.riseSpeed = 0.0
                    powerUpLabel.text = "Freeze"
                    powerUpLabel.run(reveal)
                }
                else {
                    slowMoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(slowMoCountdown), userInfo: nil, repeats: true)
                    isSlowMo = true
                    var amount = 2.0
                    if (slowLevel == 2) {
                        amount = 2.25
                    }
                    else if (slowLevel == 3) {
                        amount = 2.5
                    }
                    else if (slowLevel == 4) {
                        amount = 2.75
                    }
                    else if (slowLevel == 5) {
                        amount = 3
                    }
                    Bubble.riseSpeed = Bubble.riseSpeed / amount
                    powerUpLabel.text = "Slow-mo"
                    powerUpLabel.run(reveal)
                }
            }
            else if powerUp < 20 {
                superPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(superPopCountdown), userInfo: nil, repeats: true)
                isSuperPop = true
                score += bubbles.capacity
                for bubble in bubbles {
                    bubble.removeFromParent()
                }
                bubbles.removeAll()
                powerUpLabel.text = "Super Pop"
                powerUpLabel.run(reveal)
            }
                
            else if powerUp <= 30 {
                slowMoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(slowMoCountdown), userInfo: nil, repeats: true)
                isSlowMo = true
                var amount = 2.0
                if (slowLevel == 2) {
                    amount = 2.25
                }
                else if (slowLevel == 3) {
                    amount = 2.5
                }
                else if (slowLevel == 4) {
                    amount = 2.75
                }
                else if (slowLevel == 5) {
                    amount = 3
                }
                Bubble.riseSpeed = Bubble.riseSpeed / amount
                powerUpLabel.text = "Slow-mo"
                powerUpLabel.run(reveal)
            }
        }
            
        else {
            
            superPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(superPopCountdown), userInfo: nil, repeats: true)
            isSuperPop = true
            score += bubbles.capacity
            for bubble in bubbles {
                bubble.removeFromParent()
            }
            bubbles.removeAll()
            powerUpLabel.text = "Super Pop"
            powerUpLabel.run(reveal)
        }
    }
    
    func powerUp(bubble: Bubble){
        var powerUp: Int!
        if (Bubble.riseSpeed > 7){
            powerUp = Int(arc4random_uniform(33))
            if (autoLevel == 0) {
                powerUp = Int(arc4random_uniform(30)) + 3
            }
            if powerUp <= 3 {
                isAutoPop = true
                if (autoLevel == 1){
                    autoPop = 5
                }
                else if (autoLevel == 2){
                    autoPop = 10
                }
                else if (autoLevel == 3){
                    autoPop = 15
                }
                autoPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(autoPopCountdown), userInfo: nil, repeats: true)
                powerUpLabel.text = "Auto Pop"
                powerUpLabel.run(reveal)
                autoPopLine.isHidden = false
            }
                
            else if powerUp < 10 {
                freezeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(freezeCountdown), userInfo: nil, repeats: true)
                isFreeze = true
                Bubble.frozen = true
                beforeFreezeSpeed = Bubble.riseSpeed
                Bubble.riseSpeed = 0.0
                powerUpLabel.text = "Freeze"
                powerUpLabel.run(reveal)
                
            }
            else if powerUp < 20 {
                superPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(superPopCountdown), userInfo: nil, repeats: true)
                isSuperPop = true
                score += bubbles.capacity
                for bubble in bubbles {
                    bubble.removeFromParent()
                }
                bubbles.removeAll()
                powerUpLabel.text = "Super Pop"
                powerUpLabel.run(reveal)
            }
                
            else if powerUp < 30 {
                slowMoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(slowMoCountdown), userInfo: nil, repeats: true)
                isSlowMo = true
                var amount = 1.5
                if (slowLevel == 2) {
                    amount = 1.75
                }
                else if (slowLevel == 3) {
                    amount = 2.0
                }
                else if (slowLevel == 4) {
                    amount = 2.25
                }
                else if (slowLevel == 5) {
                    amount = 2.5
                }
                Bubble.riseSpeed = Bubble.riseSpeed / amount
                powerUpLabel.text = "Slow-mo"
                powerUpLabel.run(reveal)
            }
                
            else if powerUp <= 33 {
                lives += lifeLevel
                oneUpTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(oneUpCountdown), userInfo: nil, repeats: true)
                isOneUp = true
                if (lifeLevel > 1){
                    powerUpLabel.text = "\(lifeLevel) Lives"
                }
                else {
                    powerUpLabel.text = "Life"
                }
                powerUpLabel.run(reveal)
            }
        }
            
        else {
            let powerUp = Int(arc4random_uniform(10))
            if powerUp == 0 {
                lives += lifeLevel
                oneUpTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(oneUpCountdown), userInfo: nil, repeats: true)
                isOneUp = true
                if (lifeLevel > 1){
                    powerUpLabel.text = "\(lifeLevel) Lives"
                }
                else {
                    powerUpLabel.text = "1 Life"
                }
                powerUpLabel.run(reveal)
            }
            else if powerUp <= 10 {
                superPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(superPopCountdown), userInfo: nil, repeats: true)
                isSuperPop = true
                score += bubbles.capacity
                for bubble in bubbles {
                    bubble.removeFromParent()
                }
                bubbles.removeAll()
                powerUpLabel.text = "Super Pop"
                powerUpLabel.run(reveal)
            }
        }
    }
    
    @objc func oneUpCountdown(){
        if isOneUp {
            oneUp -= 1
        }
        if (oneUp == 0) {
            isOneUp = false
            oneUp = 3
            if (oneUpTimer != nil){
                oneUpTimer.invalidate()
                oneUpTimer = nil
            }
        }
    }
    
    @objc func slowMoCountdown(){
        if isSlowMo {
            slowMo -= 1
        }
        if (slowMo == 0) {
            isSlowMo = false
            slowMo = 3
            if (slowMoTimer != nil){
                slowMoTimer.invalidate()
                slowMoTimer = nil
            }
        }
    }
    
    @objc func freezeCountdown(){
        if isFreeze {
            freeze -= 1
        }
        if (freeze == 0) {
            isFreeze = false
            Bubble.frozen = false
            Bubble.riseSpeed = beforeFreezeSpeed / 2
            startBubbles()
            freeze = 5
            if (freezeTimer != nil){
                freezeTimer.invalidate()
                freezeTimer = nil
            }
            if (gameMode == "Timed") {
                gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stopWatch), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func superPopCountdown(){
        if isSuperPop {
            superPop -= 1
        }
        if (superPop == 0) {
            isSuperPop = false
            superPop = 3
            if (superPopTimer != nil){
                if superPopTimer.isValid {
                    superPopTimer.invalidate()
                    superPopTimer = nil
                }
            }
        }
    }
    
    @objc func autoPopCountdown() {
        if isAutoPop {
            autoPop -= 1
        }
        
        if (autoPop == 0) {
            isAutoPop = false
            autoPopLine.isHidden = true
            if (autoLevel == 1){
                autoPop = 5
            }
            else if (autoLevel == 2){
                autoPop = 10
            }
            else if (autoLevel == 3){
                autoPop = 15
            }
            if (autoPopTimer != nil){
                autoPopTimer.invalidate()
                autoPopTimer = nil
            }
        }
    }
    
    func playAgain(){
        fingerDown = false
        GameScene.gamePaused = false
        
        if (bubbleTimer != nil) {
            bubbleTimer.invalidate()
            bubbleTimer = nil
        }
        
        if (coinTimer != nil) {
            coinTimer.invalidate()
            coinTimer = nil
        }
        
        startsIn = 3
        
        scoreLabel.text = ""
        coinsLabel.text = ""
        livesLabel.text = "10"
        timeLabel.text = "0"
        timesPaused = 0
        viewController.pausesLeft.text = "Pauses Left: 3"
        startCountdown()
        for (i,bubble) in bubbles.enumerated().reversed() {
            bubbles.remove(at: i)
            bubble.removeFromParent()
        }
        
        for (i,coin) in coins.enumerated().reversed() {
            coins.remove(at: i)
            coin.removeFromParent()
        }
        pathEmitter?.position = CGPoint(x:-100,y: -100)
        Bubble.riseSpeed = 4.0
        Bubble.frozen = false
        gameEnded = false
        gameOver = false
        
        isOneUp = false
        isSlowMo = false
        isFreeze = false
        isSuperPop = false
        isAutoPop = false
        
        oneUp = 3
        slowMo = 3
        freeze = 5
        superPop = 3
        autoPop = 10
    }
    
    func gameEnd(){
        pathEmitter?.position = CGPoint(x:-100,y: -100)
        lives = 10
        score = 0
        time = 0
        coinCount = 0
        
        
        for (i,bubble) in bubbles.enumerated().reversed() {
            bubbles.remove(at: i)
            bubble.removeFromParent()
        }
        for (i,coin) in coins.enumerated().reversed() {
            coins.remove(at: i)
            coin.removeFromParent()
        }
    }
    
    func oneLife(){
        lives = 1
        var prevScore = score
        playAgain()
        score = prevScore
    }
    
    func endGame(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "seguetoGameOver"), object: nil)
    }
    
    @objc func addBubble() {
        if (!(isFreeze || gameOver)) {
            let bubble = Bubble()
            bubbles.append(bubble)
            bubble.name = "bubble"
            bubble.isUserInteractionEnabled = false
            self.addChild(bubble)
        }
    }
    
    @objc func addCoin() {
        let coin = Coin()
        coins.append(coin)
        self.addChild(coin)
    }
    
    func startBubbles(){
        var timeInterval: Double!
        
        if gameMode == "Timed" {
            timeInterval = 0.25
        }
        else {
            timeInterval = 0.5
        }
        if (bubbleTimer != nil) {
            if (!bubbleTimer.isValid) {
                bubbleTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addBubble), userInfo: nil, repeats: true)
            }
        }
        else {
            bubbleTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addBubble), userInfo: nil, repeats: true)
        }
        
        if (coinTimer != nil) {
            if (!coinTimer.isValid) {
                coinTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(addCoin), userInfo: nil, repeats: true)
            }
        }
        else {
            coinTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(addCoin), userInfo: nil, repeats: true)
        }
        
    }
    
    func pause(){
        if (gameMode == "Timed"){
            GameScene.gamePaused = true
            timesPaused += 1
            viewController.pausesLeft.text = "Pauses left: \(3 - timesPaused)"
            viewController.showPause()
            if (bubbleTimer != nil){
                bubbleTimer.invalidate()
                bubbleTimer = nil
            }
            if (gameTimer != nil){
                gameTimer.invalidate()
                gameTimer = nil
            }
            if (coinTimer != nil){
                coinTimer.invalidate()
                coinTimer = nil
            }
        }
    }
    
    func unPause(){
        GameScene.gamePaused = false
        viewController.hidePause()
        startCountdown()
        if !(gameStarted){
            powerUpLabel.text = ""
            powerUpLabel.setScale(0)
            startBubbles()
            if (gameMode == "Timed") {
                if gameTimer == nil {
                    gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stopWatch), userInfo: nil, repeats: true)
                }
            }
            gameStarted = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimers), name: NSNotification.Name(rawValue: "inactive"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(unpauseTimers), name: NSNotification.Name(rawValue: "active"), object: nil)
        
        if (!fingerDown && startsIn < 0 && gameMode == "Timed" && !GameScene.gamePaused){
            timesPaused -= 1
            pause()
        }
        for (i,coin) in coins.enumerated().reversed() {
            if coin.contains(previousLocation) {
                if (Menu.sound) {
                    playCoin()
                }
                coin.removeFromParent()
                coins.remove(at: i)
                coinCount += 1
            }
        }
        
        for (i,bubble) in bubbles.enumerated().reversed() {
            if bubble.contains(previousLocation) {
                if (Menu.sound) {
                    playPop()
                    /*if #available(iOS 10.0, *) {
                     let generator = UINotificationFeedbackGenerator()
                     generator.notificationOccurred(.error)
                     } else {
                     // Fallback on earlier versions
                     }*/
                }
                
                if bubble.ifGreen() {
                    if (gameMode == "Classic"){
                        powerUp(bubble: bubble)
                    }
                    else if (gameMode == "Endless"){
                        endlessPowerUp(bubble: bubble)
                    }
                    if bubbles.count == 0 {
                        break
                    }
                }
                
                if bubble.ifRed() {
                    if (gameMode == "Classic") {
                        score -= 1
                        lives = 0
                        gameOver = true
                    }
                    else if (gameMode == "Timed"){
                        gameOver = true
                        if (gameTimer != nil){
                            gameTimer.invalidate()
                            gameTimer = nil
                        }
                    }
                    else if (gameMode == "Endless"){
                        if (score > 5){
                            score -= 6
                        }
                        else {
                            score = 0
                            gameOver = true
                        }
                    }
                }
                bubble.removeFromParent()
                bubbles.remove(at: i)
                score += 1
                
            }
        }
        
        if (gameMode == "Classic"){
            if (isOneUp){
                inactiveOneUp.isHidden = true
                oneUpIcon.isHidden = false
            }
            else {
                inactiveOneUp.isHidden = false
                oneUpIcon.isHidden = true
            }
        }
        else {
            inactiveOneUp.isHidden = true
            oneUpIcon.isHidden = true
        }
        
        if (gameMode != "Timed"){
            if (isSlowMo){
                inactiveSlowMo.isHidden = true
                slowMoIcon.isHidden = false
            }
            else {
                inactiveSlowMo.isHidden = false
                slowMoIcon.isHidden = true
            }
        }
        else {
            inactiveSlowMo.isHidden = true
            slowMoIcon.isHidden = true
        }
        
        if (isFreeze){
            inactiveFreeze.isHidden = true
            freezeIcon.isHidden = false
        }
        else {
            inactiveFreeze.isHidden = false
            freezeIcon.isHidden = true
        }
        
        if (isSuperPop){
            inactiveSuperPop.isHidden = true
            superPopIcon.isHidden = false
        }
        else {
            inactiveSuperPop.isHidden = false
            superPopIcon.isHidden = true
        }
        if (isAutoPop){
            inactiveAutoPop.isHidden = true
            autoPopIcon.isHidden = false
            timerIcon.isHidden = false
        }
        else {
            inactiveAutoPop.isHidden = false
            autoPopIcon.isHidden = true
            timerIcon.isHidden = true
        }
        if (gameMode == "Timed"){
            
            inactiveOneUp.isHidden = true
            inactiveFreeze.isHidden = true
            inactiveSlowMo.isHidden = true
            inactiveAutoPop.isHidden = true
            inactiveSuperPop.isHidden = true
        }
        
        if (gameOver && !gameEnded) {
            endGame()
            gameEnded = true
        }
            
        else {
            if (viewController.pauseShowing && unpaused){
                viewController.hidePause()
            }
        }
        for (i,bubble) in bubbles.enumerated().reversed() {
            bubble.update()
            if (gameMode == "Classic") {
                if (Menu.bundle == "Classic" || Menu.bundle == "Greenery") {
                    if (bubble.getY() > 1400){
                        bubbles.remove(at: i)
                        bubble.removeFromParent()
                        if lives > 0 && bubble.ifBlue(){
                            lives -= 1
                        }
                    }
                }
                else {
                    if (bubble.getY() < 0){
                        bubbles.remove(at: i)
                        bubble.removeFromParent()
                        if lives > 0 && bubble.ifBlue(){
                            lives -= 1
                        }
                    }
                }
                if lives <= 0 {
                    gameOver = true
                }
            }
            if (gameMode == "Timed"){
                if (Menu.bundle == "Classic" || Menu.bundle == "Greenery") {
                    if (bubble.getY() > 1400){
                        bubbles.remove(at: i)
                        bubble.removeFromParent()
                        score += 1
                    }
                }
                else {
                    if (bubble.getY() < 0){
                        bubbles.remove(at: i)
                        bubble.removeFromParent()
                        score += 1
                    }
                }
            }
            
        }
        for (i,coin) in coins.enumerated().reversed() {
            coin.update()
            if (Menu.bundle == "Classic" || Menu.bundle == "Greenery") {
                if (coin.getY() > 1400){
                    coins.remove(at: i)
                    coin.removeFromParent()
                }
            }
            else {
                if (coin.getY() < 0){
                    coins.remove(at: i)
                    coin.removeFromParent()
                }
            }
        }
        
        if (gameMode == "Timed"){
            viewController.livesTimeLabel.text = "\(time)"
        }
        else if (gameMode == "Classic") {
            viewController.livesTimeLabel.text = "\(lives)"
        }
        
        viewController.scoreLabel.text = "\(score)"
        viewController.coinsLabel.text = "\(coinCount)"
        
        if (isAutoPop) {
            timerLabel.text = "\(autoPop)"
            for (i,bubble) in bubbles.enumerated().reversed() {
                if (Menu.bundle == "Classic" || Menu.bundle == "Greenery") {
                    if (bubble.getY() >= self.frame.height / 2 && bubble.ifBlue()){
                        if (Menu.sound) {
                            playPop()
                        }
                        bubbles.remove(at: i)
                        bubble.removeFromParent()
                        score += 1
                    }
                }
                else {
                    if (bubble.getY() <= self.frame.height / 2 && bubble.ifBlue()){
                        if (Menu.sound) {
                            playPop()
                        }
                        bubbles.remove(at: i)
                        bubble.removeFromParent()
                        score += 1
                    }
                }
            }
        }
        else {
            timerLabel.text = ""
        }
    }
    
    @objc func pauseTimers(){
        if (gameMode != "Timed"){
            if (bubbleTimer != nil){
                bubbleTimer.invalidate()
                bubbleTimer = nil
            }
            if (gameTimer != nil){
                gameTimer.invalidate()
                gameTimer = nil
            }
            if (coinTimer != nil){
                coinTimer.invalidate()
                coinTimer = nil
            }
        }
    }
    
    @objc func unpauseTimers(){
        if (gameMode != "Timed"){
            startCountdown()
        }
    }
    
    class Bubble: SKSpriteNode {
        var bubbleSize: Int
        var type: Int
        var x: Int
        var y = 0
        static var riseSpeed = 4.0
        static var frozen = false
        static var gameMode: String!
        
        var red = false
        var green = false
        
        var bubbleImage = "Bubble"
        
        init() {
            if (Menu.bundle == "Snowy"){
                bubbleImage = "Snow"
                y = 1400
            }
            else if (Menu.bundle == "Bubble Tea"){
                bubbleImage = "Tapioca"
                y = 1400
            }
            
            bubbleSize = Int(arc4random_uniform(3))
            if (Bubble.gameMode != "Timed") {
                type = Int(arc4random_uniform(100))
            }
            else {
                type = 95 //forced red bubble
                //Bubble.riseSpeed = 17
            }
            
            var texture = SKTexture(imageNamed: bubbleImage)
            
            if (type < 85){
                if (bubbleSize == 1) {
                    texture = SKTexture(imageNamed: bubbleImage + "2")
                }
                    
                else if (bubbleSize == 2) {
                    texture = SKTexture(imageNamed: bubbleImage + "3")
                }
                    
                else if (bubbleSize == 3) {
                    texture = SKTexture(imageNamed: bubbleImage + "4")
                }
            }
                
            else if (type <= 90) {
                green = true
                if (bubbleSize == 0) {
                    if (!Menu.color) {
                        texture = SKTexture(imageNamed: bubbleImage + "G")
                    }
                    else {
                        texture = SKTexture(imageNamed: bubbleImage + "Y")
                    }
                }
                    
                else if (bubbleSize == 1) {
                    if (!Menu.color) {
                        texture = SKTexture(imageNamed: bubbleImage + "G2")
                    }
                    else {
                        texture = SKTexture(imageNamed: bubbleImage + "Y2")
                    }
                }
                    
                else if (bubbleSize == 2) {
                    if (!Menu.color) {
                        texture = SKTexture(imageNamed: bubbleImage + "G3")
                    }
                    else {
                        texture = SKTexture(imageNamed: bubbleImage + "Y3")
                    }
                }
                    
                else if (bubbleSize == 3) {
                    if (!Menu.color) {
                        texture = SKTexture(imageNamed: bubbleImage + "G4")
                    }
                    else {
                        texture = SKTexture(imageNamed: bubbleImage + "Y4")
                    }
                }
            }
                
            else if (type < 100) {
                red = true
                if (bubbleSize == 0) {
                    texture = SKTexture(imageNamed: bubbleImage + "R")
                }
                    
                else if (bubbleSize == 1) {
                    texture = SKTexture(imageNamed: bubbleImage + "R2")
                }
                    
                else if (bubbleSize == 2) {
                    texture = SKTexture(imageNamed: bubbleImage + "R3")
                }
                    
                else if (bubbleSize == 3) {
                    texture = SKTexture(imageNamed: bubbleImage + "R4")
                }
            }
            
            let randomBubbleX = GKRandomDistribution(lowestValue: 0, highestValue: 750 - Int(texture.size().width)/4)
            x = randomBubbleX.nextInt()
            super.init(texture: texture, color: UIColor.clear, size: texture.size())
        }
        
        func ifBlue() -> Bool {
            return !(red || green)
        }
        func ifRed() -> Bool {
            return red
        }
        
        func ifGreen() -> Bool {
            return green
        }
        func getX() -> CGFloat {
            return CGFloat(x)
        }
        
        func getY() -> CGFloat {
            return CGFloat(y)
        }
        func getBubbleSize() -> CGSize {
            return self.frame.size
        }
        func update(){
            if !(GameScene.gamePaused){
                if Bubble.frozen {
                    Bubble.riseSpeed = 0.0
                }
                if (Bubble.gameMode != "Timed") {
                    if (Bubble.riseSpeed < 30) {
                        Bubble.riseSpeed *= 1.001
                    }
                }
                else {
                    if (Bubble.riseSpeed < 15) {
                        Bubble.riseSpeed *= 1.0005
                    }
                    else if (Bubble.riseSpeed < 20){
                        Bubble.riseSpeed *= 1.0015
                    }
                    else if (Bubble.riseSpeed < 25){
                        Bubble.riseSpeed *= 1.001
                    }
                    else if (Bubble.riseSpeed < 30){
                        Bubble.riseSpeed *= 1.005
                    }
                }
                if (Menu.bundle == "Classic" || Menu.bundle == "Greenery") {
                    y += Int(Bubble.riseSpeed)
                }
                else {
                    y -= Int(Bubble.riseSpeed)
                }
                
                self.position = CGPoint(x: x, y: y)
            }
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class Coin: SKSpriteNode {
        var x: Int
        var y = 0
        var riseSpeed = 6
        
        
        init() {
            
            if (Menu.bundle == "Snowy" || Menu.bundle == "Bubble Tea") {
                y = 1400
            }
            
            var texture = SKTexture(imageNamed: "coin1")
            
            let f0 = SKTexture.init(imageNamed: "coin1")
            let f1 = SKTexture.init(imageNamed: "coin2")
            let f2 = SKTexture.init(imageNamed: "coin3")
            let f3 = SKTexture.init(imageNamed: "coin4")
            let f4 = SKTexture.init(imageNamed: "coin5")
            let f5 = SKTexture.init(imageNamed: "coin6")
            
            let frames: [SKTexture] = [f0, f1, f2, f3, f4, f5]
            
            let animation = SKAction.animate(with: frames, timePerFrame: 0.2, resize: false, restore: true)
            
            let randomX = GKRandomDistribution(lowestValue:Int(f5.size().width/2), highestValue: 750 - Int(f5.size().width/2))
            x = randomX.nextInt()
            
            super.init(texture: texture, color: UIColor.clear, size: texture.size())
            run(SKAction.repeatForever(animation))
            position = CGPoint(x: x, y: y)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func getY() -> CGFloat {
            return CGFloat(y)
        }
        
        func update(){
            if !(GameScene.gamePaused){
                if (Menu.bundle == "Classic" || Menu.bundle == "Greenery"){
                    y += riseSpeed
                }
                else {
                    y -= riseSpeed
                }
                self.position = CGPoint(x: x, y: y)
            }
            
        }
    }
}
