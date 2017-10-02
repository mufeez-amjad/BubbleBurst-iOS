//
//  GameScene.swift
//  BubbleBurst iOS
//
//  Created by Mufeez Amjad on 2017-09-30.
//  Copyright © 2017 Mufeez Amjad. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var bubbles = [Bubble]()
    var gameTimer:Timer!
    var score = 0
    var lives = 10
    var gameOver = false
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var oneUpTimer: Timer!
    var slowMoTimer: Timer!
    var freezeTimer: Timer!
    var superPopTimer: Timer!
    var oneUp = 3
    var slowMo = 3
    var freeze = 3
    var superPop = 3
    
    var isOneUp = false
    var isSlowMo = false
    var isFreeze = false
    var isSuperPop = false
    var beforeFreezeSpeed: Double = 0.0
    
    var oneUpIcon: SKSpriteNode!
    var slowMoIcon: SKSpriteNode!
    var freezeIcon: SKSpriteNode!
    var superPopIcon: SKSpriteNode!
    
    var pathEmitter: SKEmitterNode?
    
    override func sceneDidLoad() {
        
         oneUpIcon = SKSpriteNode(imageNamed: "1Up")
         slowMoIcon = SKSpriteNode(imageNamed: "slowMo")
         freezeIcon = SKSpriteNode(imageNamed: "freeze")
         superPopIcon = SKSpriteNode(imageNamed: "superPop")
        pathEmitter = SKEmitterNode(fileNamed: "MyParticle")
        
        slowMoIcon.position = CGPoint(x: 380,y: self.frame.height - 100)
        slowMoIcon.xScale = 0.07
        slowMoIcon.yScale = 0.07
        slowMoIcon.isHidden = true
        self.addChild(slowMoIcon)
        
        
        oneUpIcon.position = CGPoint(x: 380 + slowMoIcon.size.width * 1.25,y: self.frame.height - 100)
        oneUpIcon.xScale = 0.07
        oneUpIcon.yScale = 0.07
        oneUpIcon.isHidden = true
        self.addChild(oneUpIcon)
        
        freezeIcon.position = CGPoint(x: 380 + slowMoIcon.size.width * 1.25 + oneUpIcon.size.width * 1.25,y: self.frame.height - 100)
        freezeIcon.xScale = 0.07
        freezeIcon.yScale = 0.07
        freezeIcon.isHidden = true
        self.addChild(freezeIcon)
        
        superPopIcon.position = CGPoint(x: 380 + slowMoIcon.size.width * 1.25 + oneUpIcon.size.width * 1.25 + freezeIcon.size.width * 1.25,y: self.frame.height - 100)
        superPopIcon.xScale = 0.07
        superPopIcon.yScale = 0.07
        superPopIcon.isHidden = true
        self.addChild(superPopIcon)
    }
    
    override func didMove(to view: SKView) {
        gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addBubble), userInfo: nil, repeats: true)
    
        scoreLabel = SKLabelNode(fontNamed: "Bubblegum")
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 40
        scoreLabel.position = CGPoint(x: 150,y: self.frame.height - 100)
        self.addChild(scoreLabel)
        
        livesLabel = SKLabelNode(fontNamed: "Bubblegum")
        livesLabel.text = "\(lives)"
        livesLabel.fontSize = 40
        livesLabel.position = CGPoint(x: 150,y: self.frame.height - 200)
        
        self.addChild(livesLabel)
        
        pathEmitter?.position = CGPoint(x:-100,y: -100)
        self.addChild(pathEmitter!)
        pathEmitter?.targetNode = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first as! UITouch
        let touchLocation = touch.location(in: self)
        pathEmitter?.position = touchLocation
        
        if let touch = touches.first {
            
            let touch = touches.first!
            for (i,bubble) in bubbles.enumerated().reversed() {
                if bubble.contains(touch.location(in: self)) {
                    
                    bubbles.remove(at: i)
                    bubble.removeFromParent()
                    
                }
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        pathEmitter?.position = CGPoint(x:-100,y: -100)
    }
    
    @objc func countdown() {
        if isOneUp {
            oneUp -= 1
        }
        if (oneUp == 0) {
            isOneUp = false
            oneUp = 3
            oneUpIcon.isHidden = true
        }
        if isSlowMo {
            slowMo -= 1
        }
        if (slowMo == 0) {
            isSlowMo = false
            slowMo = 3
            slowMoIcon.isHidden = true
        }
        if isFreeze {
            freeze -= 1
        }
        if (freeze == 0) {
            isFreeze = false
            Bubble.frozen = false
            Bubble.riseSpeed = beforeFreezeSpeed / 2
            gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addBubble), userInfo: nil, repeats: true)
            freeze = 3
            freezeIcon.isHidden = true

        }
        if isSuperPop {
            superPop -= 1
        }
        if (superPop == 0) {
            isSuperPop = false
            superPop = 3
            superPopIcon.isHidden = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first as! UITouch
        let touchLocation = touch.location(in: self)
        pathEmitter?.position = touchLocation
        
        for touch in touches {
            let position = touch.location(in: view)
            for (i,bubble) in bubbles.enumerated().reversed() {
                if bubble.contains(touch.location(in: self)) {
                    if bubble.ifGreen() {
                        if (Bubble.riseSpeed > 5){
                            let powerUp = Int(arc4random_uniform(30))
                            if powerUp <= 3 {
                                lives += 1
                                oneUpTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
                                isOneUp = true
                                oneUpIcon.isHidden = false
                            }
                            else if powerUp < 10 {
                                slowMoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
                                isSlowMo = true
                                Bubble.riseSpeed = Bubble.riseSpeed / 2.0
                                slowMoIcon.isHidden = false
                            }
                            else if powerUp < 20 {
                                if (Bubble.riseSpeed > 15){
                                    freezeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
                                    isFreeze = true
                                    gameTimer.invalidate()
                                    Bubble.frozen = true
                                    beforeFreezeSpeed = Bubble.riseSpeed
                                    Bubble.riseSpeed = 0.0
                                    freezeIcon.isHidden = false
                                }
                                else {
                                    slowMoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
                                    isSlowMo = true
                                    Bubble.riseSpeed = Bubble.riseSpeed / 2.0
                                    slowMoIcon.isHidden = false
                                }
                            }
                            else if powerUp <= 30 {
                                superPopTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
                                isSuperPop = true
                                score += bubbles.capacity
                                for bubble in bubbles {
                                    bubble.removeFromParent()
                                }
                                bubbles.removeAll()
                                superPopIcon.isHidden = false
                                break
                            }
                        }
                        else {
                            let powerUp = Int(arc4random_uniform(10))
                            if powerUp == 0 {
                                lives += 1
                                oneUpIcon.isHidden = false
                            }
                            else if powerUp <= 10 {
                                score += bubbles.capacity - 1
                                for bubble in bubbles {
                                    bubble.removeFromParent()
                                }
                                bubbles.removeAll()
                                superPopIcon.isHidden = false
                                break
                            }
                        }
                        
                    }
                    
                    if bubble.ifRed() {
                        gameOver = true
                    }
                    bubble.removeFromParent()
                    bubbles.remove(at: i)
                    score += 1
                }
            }
        }
    }
    
    
    
    @objc func addBubble() {
        let bubble = Bubble()
        bubbles.append(bubble)
        bubble.name = "bubble"
        bubble.isUserInteractionEnabled = false
        self.addChild(bubble)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        for (i,bubble) in bubbles.enumerated().reversed() {
            bubble.update()
            
            if (bubble.getY() > 1400){
                bubbles.remove(at: i)
                bubble.removeFromParent()
                //print("Removed")
                if lives > 0 && bubble.ifBlue(){
                    lives -= 1
                }
                
            }
        }
        if lives <= 0 {
            gameOver = true
        }
        
        if (gameOver) {
            gameTimer.invalidate()
        }
        livesLabel.text = "\(lives)"
        scoreLabel.text = "\(score)"
    }
}

class Bubble: SKSpriteNode {
    var bubbleSize: Int
    var type: Int
    var x: Int
    var y = 0
    static var riseSpeed = 6.0
    static var frozen = false
    
    var red = false
    var green = false
    
    init() {
        bubbleSize = Int(arc4random_uniform(3))
        type = Int(arc4random_uniform(100))
        //let randomSpeed = GKRandomDistribution(lowestValue:5, highestValue: 20)
        //riseSpeed = randomSpeed.nextInt()
        var texture = SKTexture(imageNamed: "Bubble")
        
        if (type < 70){
            if (bubbleSize == 1) {
                texture = SKTexture(imageNamed: "Bubble2")
            }
                
            else if (bubbleSize == 2) {
                texture = SKTexture(imageNamed: "Bubble3")
            }
                
            else if (bubbleSize == 3) {
                texture = SKTexture(imageNamed: "Bubble4")
            }
        }
        
        else if (type < 95) {
            red = true
            if (bubbleSize == 0) {
                texture = SKTexture(imageNamed: "BubbleR")
            }
                
            else if (bubbleSize == 1) {
                texture = SKTexture(imageNamed: "BubbleR2")
            }
                
            else if (bubbleSize == 2) {
                texture = SKTexture(imageNamed: "BubbleR3")
            }
            
            else if (bubbleSize == 3) {
                texture = SKTexture(imageNamed: "BubbleR4")
            }
        }
        
        else if (type <= 100) {
            green = true
            if (bubbleSize == 0) {
                texture = SKTexture(imageNamed: "BubbleG")
            }
                
            else if (bubbleSize == 1) {
                texture = SKTexture(imageNamed: "BubbleG2")
            }
                
            else if (bubbleSize == 2) {
                texture = SKTexture(imageNamed: "BubbleG3")
            }
                
            else if (bubbleSize == 3) {
                texture = SKTexture(imageNamed: "BubbleG4")
            }
        }
        
        
        let randomBubbleX = GKRandomDistribution(lowestValue:Int(texture.size().width/2), highestValue: 750 - Int(texture.size().width/2))
        x = randomBubbleX.nextInt()
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        //self.isHidden = true
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
        if Bubble.frozen == true {
            Bubble.riseSpeed = 0.0
        }
        else if (Bubble.riseSpeed < 20) {
            Bubble.riseSpeed += 0.01
        }
        y += Int(Bubble.riseSpeed)
        self.position = CGPoint(x: x, y: y)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
