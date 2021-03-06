//
//  GameScene.swift
//  Flappy Bird
//
//  Created by fang on 15/12/2.
//  Copyright (c) 2015年 Fang YiXiong. All rights reserved.
//

import SpriteKit

enum photos: CGFloat {
    case background
    case barrier
    case frontground
    case roleOfGame
    case ui
}

enum statusGame {
    case gameMenu
    case gameing
    case teachGame
    case game
    case goDown
    case printMark
    case endGame
}

struct physicsTier {
    static let nothing: UInt32 =      0
    static let roleOfGame: UInt32 = 0b1
    static let barrier: UInt32 =   0b10
    static let front: UInt32 =    0b100
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let urlOfBaidu = "https://www.baidu.com"
    let numOfFront = 2
    let velocityOfFront: CGFloat = -150.0
    let timeAction = 0.3
    
    let gravity: CGFloat = -1500.0
    let upVelocity: CGFloat = 400.0
    var velocity = CGPoint.zero
    let topDistance: CGFloat = 20.0
    let nameFont = "AmericanTypeWriter-Bold"
    var scoreLabel: SKLabelNode!
    var nowScore = 0
    
    var contactFront = false
    var contactBarrier = false
    var nowGameStatus: statusGame = .gameing
    
    let nodeOfWorld = SKNode()
    var starOfGame: CGFloat = 0
    var heightOfGame: CGFloat = 0
    let roleOfGame = SKSpriteNode(imageNamed: "Bird0")
    
    var lastedUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    
    let firstSetBarrierTime: TimeInterval = 1.75
    let resetBarrierTime: TimeInterval = 1.5
    
    // Voice
    let voiceOfDing = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let voiceOfFlappy = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let voiceOfWhack = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let voiceOfHit = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let voiceOfFall = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let voiceOfPop = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let voiceOfCoin = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        //关闭重力
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        //设置碰撞代理
        physicsWorld.contactDelegate = self
        
        
        addChild(nodeOfWorld)
        cutgameMenu()
        
    }
    
    
    
    
    // MARK: 设置的相关方法
    
    func setGameMenu() {
        let logo = SKSpriteNode(imageNamed: "Logo")
        logo.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        logo.name = "gameMenu"
        logo.zPosition = photos.ui.rawValue
        nodeOfWorld.addChild(logo)
        
        let starButton = SKSpriteNode(imageNamed: "Button")
        starButton.position = CGPoint(x: size.width * 0.25, y: size.height * 0.25)
        starButton.name = "gameMenu"
        starButton.zPosition = photos.ui.rawValue
        nodeOfWorld.addChild(starButton)
        
        let palyGame = SKSpriteNode(imageNamed: "Play")
        palyGame.position = CGPoint.zero
        starButton.addChild(palyGame)
        
        let rateButton = SKSpriteNode(imageNamed: "Button")
        rateButton.position = CGPoint(x: size.width * 0.75, y: size.height * 0.25)
        rateButton.zPosition = photos.ui.rawValue
        rateButton.name = "gameMenu"
        nodeOfWorld.addChild(rateButton)
        
        let rate = SKSpriteNode(imageNamed: "Rate")
        rate.position = CGPoint.zero
        rateButton.addChild(rate)
        
        let learnButton = SKSpriteNode(imageNamed: "button_learn")
        learnButton.position = CGPoint(x: size.width * 0.5, y: learnButton.size.height / 2 + topDistance)
        learnButton.name = "gameMenu"
        learnButton.zPosition = photos.ui.rawValue
        nodeOfWorld.addChild(learnButton)
        
        let enlargeAction = SKAction.scale(to: 1.02, duration: 0.75)
        enlargeAction.timingMode = .easeInEaseOut
        
        let reduceAction = SKAction.scale(to: 1.02, duration: 0.75)
        reduceAction.timingMode = .easeInEaseOut
        
        learnButton.run(SKAction.repeatForever(SKAction.sequence([
            enlargeAction, reduceAction
            ])))
        
        
    }
    
    func setTeach() {
        let teachGame = SKSpriteNode(imageNamed: "Tutorial")
        teachGame.position = CGPoint(x: size.width * 0.5, y: heightOfGame * 0.4 + starOfGame)
        teachGame.name = "teachGame"
        teachGame.zPosition = photos.ui.rawValue
        nodeOfWorld.addChild(teachGame)
        
        let readyGame = SKSpriteNode(imageNamed: "Ready")
        readyGame.position = CGPoint(x: size.width * 0.5, y: heightOfGame * 0.7 + starOfGame)
        readyGame.name = "teachGame"//与上面相同
        readyGame.zPosition = photos.ui.rawValue
        nodeOfWorld.addChild(readyGame)
    }
    
    func setBackground() {
        let background = SKSpriteNode(imageNamed: "Background")
        background.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        background.position = CGPoint(x: size.width/2, y: size.height)
        background.zPosition = photos.background.rawValue
        nodeOfWorld.addChild(background)
        
        starOfGame = size.height - background.size.height
        heightOfGame = background.size.height
        
        let zuoxia = CGPoint(x: 0, y: starOfGame)
        let youxia = CGPoint(x: size.width, y: starOfGame)
        
        self.physicsBody = SKPhysicsBody(edgeFrom: zuoxia, to: youxia)
        self.physicsBody?.categoryBitMask = physicsTier.front
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = physicsTier.roleOfGame
        
    }
    
    func setFrontground() {
        for i in 0 ..< numOfFront {
            let frontground = SKSpriteNode(imageNamed: "Ground")
            frontground.anchorPoint = CGPoint(x: 0, y: 1.0)
            frontground.position = CGPoint(x: CGFloat(i) * frontground.size.width, y: starOfGame)
            frontground.zPosition = photos.frontground.rawValue
            frontground.name = "frontground"
            nodeOfWorld.addChild(frontground)
        }
    }
    
    func setRole() {
        roleOfGame.position = CGPoint(x: size.width * 0.2, y: heightOfGame * 0.4 + starOfGame)
        roleOfGame.zPosition = photos.roleOfGame.rawValue
        
        let offsetX = roleOfGame.size.width * roleOfGame.anchorPoint.x
        let offsetY = roleOfGame.size.height * roleOfGame.anchorPoint.y
        
        let path = CGMutablePath()
        
//        CGPathMoveToPoint(path, nil, 1 - offsetX, 15 - offsetY)
//        CGPathAddLineToPoint(path, nil, 8 - offsetX, 18 - offsetY)
//        CGPathAddLineToPoint(path, nil, 11 - offsetX, 21 - offsetY)
//        CGPathAddLineToPoint(path, nil, 18 - offsetX, 23 - offsetY)
//        CGPathAddLineToPoint(path, nil, 20 - offsetX, 28 - offsetY)
//        CGPathAddLineToPoint(path, nil, 26 - offsetX, 29 - offsetY)
//        CGPathAddLineToPoint(path, nil, 34 - offsetX, 29 - offsetY)
//        CGPathAddLineToPoint(path, nil, 38 - offsetX, 25 - offsetY)
//        CGPathAddLineToPoint(path, nil, 38 - offsetX, 20 - offsetY)
//        CGPathAddLineToPoint(path, nil, 38 - offsetX, 12 - offsetY)
//        CGPathAddLineToPoint(path, nil, 38 - offsetX, 7 - offsetY)
//        CGPathAddLineToPoint(path, nil, 35 - offsetX, 4 - offsetY)
//        CGPathAddLineToPoint(path, nil, 33 - offsetX, 2 - offsetY)
//        CGPathAddLineToPoint(path, nil, 29 - offsetX, 2 - offsetY)
//        CGPathAddLineToPoint(path, nil, 23 - offsetX, 3 - offsetY)
//        CGPathAddLineToPoint(path, nil, 22 - offsetX, 1 - offsetY)
//        CGPathAddLineToPoint(path, nil, 20 - offsetX, 0 - offsetY)
//        CGPathAddLineToPoint(path, nil, 17 - offsetX, 0 - offsetY)
//        CGPathAddLineToPoint(path, nil, 5 - offsetX, 1 - offsetY)
        
        path.move(to: CGPoint(x: 1 - offsetX, y: 15 - offsetY))
        path.addLine(to: CGPoint(x: 8 - offsetX, y: 18 - offsetY))
        path.addLine(to: CGPoint(x: 11 - offsetX, y: 21 - offsetY))
        path.addLine(to: CGPoint(x: 18 - offsetX, y: 23 - offsetY))
        path.addLine(to: CGPoint(x: 20 - offsetX, y: 28 - offsetY))
        path.addLine(to: CGPoint(x: 26 - offsetX, y: 29 - offsetY))
        path.addLine(to: CGPoint(x: 34 - offsetX, y: 29 - offsetY))
        path.addLine(to: CGPoint(x: 38 - offsetX, y: 25 - offsetY))
        path.addLine(to: CGPoint(x: 38 - offsetX, y: 20 - offsetY))
        path.addLine(to: CGPoint(x: 38 - offsetX, y: 12 - offsetY))
        path.addLine(to: CGPoint(x: 38 - offsetX, y: 7 - offsetY))
        path.addLine(to: CGPoint(x: 35 - offsetX, y: 4 - offsetY))
        path.addLine(to: CGPoint(x: 33 - offsetX, y: 2 - offsetY))
        path.addLine(to: CGPoint(x: 29 - offsetX, y: 2 - offsetY))
        path.addLine(to: CGPoint(x: 23 - offsetX, y: 3 - offsetY))
        path.addLine(to: CGPoint(x: 22 - offsetX, y: 1 - offsetY))
        path.addLine(to: CGPoint(x: 20 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x: 17 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x: 5 - offsetX, y: 1 - offsetY))
        
        
        
        path.closeSubpath()
        
        roleOfGame.physicsBody = SKPhysicsBody(polygonFrom: path)
        roleOfGame.physicsBody?.categoryBitMask = physicsTier.roleOfGame
        roleOfGame.physicsBody?.collisionBitMask = 0  //关闭碰撞处理
        roleOfGame.physicsBody?.contactTestBitMask = physicsTier.front | physicsTier.barrier
        
        
        nodeOfWorld.addChild(roleOfGame)
    }
    
    func setScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: nameFont)
        scoreLabel.fontColor = SKColor(colorLiteralRed: 101.0 / 255.0, green: 71.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - topDistance)
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.text = "0"
        scoreLabel.zPosition = photos.ui.rawValue
        nodeOfWorld.addChild(scoreLabel)
    }
    
    func setScoreCard() {
        if nowScore > maxScore() {
            setMaxScore(nowScore)
        }
        
        let scoreCard = SKSpriteNode(imageNamed: "ScoreCard")
        scoreCard.position = CGPoint(x: size.width / 2, y: size.height / 2)
        scoreCard.zPosition = photos.ui.rawValue
        nodeOfWorld.addChild(scoreCard)
        
        let nowScoreLabel = SKLabelNode(fontNamed: nameFont)
        nowScoreLabel.fontColor = SKColor(colorLiteralRed: 101.0 / 255.0, green: 71.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
        nowScoreLabel.position = CGPoint(x: -scoreCard.size.width / 4, y: -scoreCard.size.height / 3)
        nowScoreLabel.text = "\(nowScore)"
        nowScoreLabel.zPosition = photos.ui.rawValue
        scoreCard.addChild(nowScoreLabel)
        
        let maxScoreLabel = SKLabelNode(fontNamed: nameFont)
        maxScoreLabel.fontColor = SKColor(colorLiteralRed: 101.0 / 255.0, green: 71.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
        maxScoreLabel.position = CGPoint(x: scoreCard.size.width / 4, y: -scoreCard.size.height / 3)
        maxScoreLabel.text = "\(maxScore())"
        maxScoreLabel.zPosition = photos.ui.rawValue
        scoreCard.addChild(maxScoreLabel)
        
        let gameOver = SKSpriteNode(imageNamed: "GameOver")
        gameOver.position = CGPoint(x: size.width / 2, y: size.height / 2 + scoreCard.size.height / 2 + topDistance + gameOver.size.height / 2)
        gameOver.zPosition = photos.ui.rawValue
        nodeOfWorld.addChild(gameOver)
        
        let okButton = SKSpriteNode(imageNamed: "Button")
        okButton.position = CGPoint(x: size.width / 4, y: size.height / 2 - scoreCard.size.height / 2 - topDistance - okButton.size.height / 2)
        okButton.zPosition = photos.ui.rawValue
        nodeOfWorld.addChild(okButton)
        
        let ok = SKSpriteNode(imageNamed: "OK")
        ok.position = CGPoint.zero
        ok.zPosition = photos.ui.rawValue
        okButton.addChild(ok)
        
        let shareButton = SKSpriteNode(imageNamed: "ButtonRight")
        shareButton.position = CGPoint(x: size.width * 0.75, y: size.height / 2 - scoreCard.size.height / 2 - topDistance - shareButton.size.height / 2)
        shareButton.zPosition = photos.ui.rawValue
        nodeOfWorld.addChild(shareButton)
        
        let share = SKSpriteNode(imageNamed: "Share")
        share.position = CGPoint.zero
        share.zPosition = photos.ui.rawValue
        shareButton.addChild(share)
        
        gameOver.setScale(0)
        gameOver.alpha = 0
        let grounpAction = SKAction.group([
            SKAction.fadeIn(withDuration: timeAction),
            SKAction.scale(to: 1.0, duration: timeAction)
            ])
        grounpAction.timingMode = .easeInEaseOut
        gameOver.run(SKAction.sequence([
            SKAction.wait(forDuration: timeAction),
            grounpAction
            ]))
        
        scoreCard.position = CGPoint(x: size.width / 2, y: -scoreCard.size.height / 2)
        let upAction = SKAction.move(to: CGPoint(x: size.width / 2, y: size.height / 2), duration: timeAction)
        upAction.timingMode = .easeInEaseOut
        scoreCard.run(SKAction.sequence([
            SKAction.wait(forDuration: timeAction * 2),
            upAction
            ]))
        
        okButton.alpha = 0
        shareButton.alpha = 0
        
        let changeAction = SKAction.sequence([
            SKAction.wait(forDuration: timeAction * 3),
            SKAction.fadeIn(withDuration: timeAction)
            ])
        okButton.run(changeAction)
        shareButton.run(changeAction)
        
        let voiceAction = SKAction.sequence([
            SKAction.wait(forDuration: timeAction), voiceOfPop,
            SKAction.wait(forDuration: timeAction), voiceOfPop,
            SKAction.wait(forDuration: timeAction), voiceOfPop,
            SKAction.run(cutEnd)
            ])
        
        run(voiceAction)
     }
    
    
    
    //MARK: 游戏流程
    
    func creatBarrier(_ nameOfImage: String) -> SKSpriteNode {
        let barrier = SKSpriteNode(imageNamed: nameOfImage)
        barrier.zPosition = photos.barrier.rawValue
        barrier.userData = NSMutableDictionary()
        
        let offsetX = barrier.size.width * barrier.anchorPoint.x
        let offsetY = barrier.size.height * barrier.anchorPoint.y
        
        let path = CGMutablePath()
        
//        CGPathMoveToPoint(path, nil, 3 - offsetX, 2 - offsetY)
//        CGPathAddLineToPoint(path, nil, 6 - offsetX, 309 - offsetY)
//        CGPathAddLineToPoint(path, nil, 46 - offsetX, 309 - offsetY)
//        CGPathAddLineToPoint(path, nil, 48 - offsetX, 2 - offsetY)
//        CGPathAddLineToPoint(path, nil, 48 - offsetX, 0 - offsetY)
//        CGPathAddLineToPoint(path, nil, 5 - offsetX, 0 - offsetY)
        path.move(to: CGPoint(x: 3 - offsetX, y: 2 - offsetY))
        path.addLine(to: CGPoint(x: 6 - offsetX, y: 309 - offsetY))
        path.addLine(to: CGPoint(x: 46 - offsetX, y: 309 - offsetY))
        path.addLine(to: CGPoint(x: 48 - offsetX, y: 2 - offsetY))
        path.addLine(to: CGPoint(x: 6 - offsetX, y: 0 - offsetY))
        path.addLine(to: CGPoint(x: 5 - offsetX, y: 0 - offsetY))
        
        path.closeSubpath()
        
        barrier.physicsBody = SKPhysicsBody(polygonFrom: path)
        barrier.physicsBody?.categoryBitMask = physicsTier.barrier
        barrier.physicsBody?.collisionBitMask = 0
        barrier.physicsBody?.contactTestBitMask = physicsTier.roleOfGame
        
        return barrier
    }
    
    func setBarrier() {
        let baseBarrier = creatBarrier("CactusBottom")
        baseBarrier.name = "baseBarrier"
        let starOfX = size.width + baseBarrier.size.width/2
        let minOfY = (starOfGame - baseBarrier.size.height/2) + heightOfGame * 0.1
        let maxOfY = (starOfGame - baseBarrier.size.height/2) + heightOfGame * 0.6
        baseBarrier.position = CGPoint(x: starOfX, y: CGFloat.random(min: minOfY, max: maxOfY))
        nodeOfWorld.addChild(baseBarrier)
        
        let topBarrier = creatBarrier("CactusTop")
        topBarrier.name = "topBarrier"
        topBarrier.zRotation = CGFloat(180).degreesToRadians()
        topBarrier.position = CGPoint(x: starOfX, y: baseBarrier.position.y + baseBarrier.size.height / 2 + topBarrier.size.height / 2 + roleOfGame.size.height * 3.5)
        nodeOfWorld.addChild(topBarrier)
        
        let moveDistanceOfX = -(size.width + baseBarrier.size.width)
        let moveTimeOfX = moveDistanceOfX / velocityOfFront
        let moveAction = SKAction.sequence([SKAction.moveBy(x: moveDistanceOfX, y: 0, duration: TimeInterval(moveTimeOfX)), SKAction.removeFromParent()
            ])
        
        baseBarrier.run(moveAction)
        topBarrier.run(moveAction)
    }
    
    
    func boundlessResetBarrier() {
        let firstSetTime = SKAction.wait(forDuration: firstSetBarrierTime)
        let resetBarrier = SKAction.run(setBarrier)
        let resetTime = SKAction.wait(forDuration: resetBarrierTime)
        let resetAction = SKAction.sequence([resetBarrier, resetTime])
        let boundlessReset = SKAction.repeatForever(resetAction)
        let allAction = SKAction.sequence([firstSetTime, boundlessReset])
        run(allAction, withKey: "reset")
    }
    
    func stopReset() {
        removeAction(forKey: "reset")
        
        nodeOfWorld.enumerateChildNodes(withName: "baseBarrier", using: {
            nodeMarry, _ in nodeMarry.removeAllActions()
            })
        nodeOfWorld.enumerateChildNodes(withName: "topBarrier", using: {
            nodeMarry, _ in nodeMarry.removeAllActions()
        })
        
    }
    
    func fly() {
        velocity = CGPoint(x: 0, y: upVelocity)
        run(voiceOfFlappy)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        switch nowGameStatus {
        case .gameMenu:
            if touchLocation.y < size.height * 0.15 {
                toLearn()
            } else if touchLocation.x < size.width / 2 {
                cutTeach()
            } else {
                toRate()
            }
            break
        case .gameing:
            fly()
            break
        case .teachGame:
            cutGame()
            break
        case .goDown:
            break
        case .printMark:
            break
        case .endGame:
            cutNewGame()
            break
        default:
            break
        }
    } 
    
    //MARK: 更新
    override func update(_ currentTime: TimeInterval) {
        if lastedUpdateTime > 0 {
            dt = currentTime - lastedUpdateTime
        } else {
            dt = 0
        }
        lastedUpdateTime = currentTime
        
        switch nowGameStatus {
        case .gameMenu:
            break
        case .gameing:
            updateFront()
            updateRole()
            testContactBarrier()
            testContactFront()
            updateScore()
            break
        case .teachGame:
            break
        case .goDown:
            updateRole()
            testContactFront()
            break
        case .printMark:
            break
        case .endGame:
            break
        default:
            break
        }
    }
    
    func updateRole() {
        let acceleration = CGPoint(x: 0, y: gravity)
        velocity = velocity + acceleration * CGFloat(dt)
        roleOfGame.position = roleOfGame.position + velocity * CGFloat(dt)
        
        if roleOfGame.position.y - roleOfGame.size.height / 2 < starOfGame {
            roleOfGame.position = CGPoint(x: roleOfGame.position.x, y: starOfGame + roleOfGame.size.height / 2)
        }
    }
    
    func updateFront() {
        nodeOfWorld.enumerateChildNodes(withName: "frontground", using: { nodeOfMatch, _ in
            if let frontground = nodeOfMatch as? SKSpriteNode {
                let velocityOfFront = CGPoint(x: self.velocityOfFront, y: 0)
                frontground.position += velocityOfFront * CGFloat(self.dt)
                
                if frontground.position.x < -frontground.size.width {
                    frontground.position += CGPoint(x: frontground.size.width * CGFloat(self.numOfFront), y: 0)
                }
            }
        })
    }
    
    func testContactBarrier() {
        if contactBarrier {
            contactBarrier = false
            cutGodown()
        }
    }
    
    func testContactFront() {
        if contactFront {
            contactFront = false
            velocity = CGPoint.zero
            roleOfGame.zRotation = CGFloat(-90).degreesToRadians()
            roleOfGame.position = CGPoint(x: roleOfGame.position.x, y: starOfGame + roleOfGame.size.width / 2)
            run(voiceOfHit)
            cutPrintMark()
        }
    }
    
    func updateScore() {
        nodeOfWorld.enumerateChildNodes(withName: "topBarrier", using: {
            nodeMarry, _ in
            if let barrier = nodeMarry as? SKSpriteNode {
                if let passed = barrier.userData?["passed"] as? NSNumber {
                    if passed.boolValue {
                        return
                    }
                }
                if self.roleOfGame.position.x > barrier.position.x + barrier.size.width / 2 {
                    self.nowScore += 1
                    self.scoreLabel.text = "\(self.nowScore)"
                    self.run(self.voiceOfCoin)
                    barrier.userData?["passed"] = NSNumber(value: true as Bool)
                    //userData字典装不进bool值，所以只能将bool封装进NSNumber使用
                }
            }
        })
    }
    
    //MARK: 游戏状态
    
    func cutgameMenu() {
        nowGameStatus = .gameMenu
        setBackground()
        setFrontground()
        setRole()
        setGameMenu()
    }
    
    func cutTeach() {
        nowGameStatus = .teachGame
        nodeOfWorld.enumerateChildNodes(withName: "gameMenu") { nodeMarry, _ in nodeMarry.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.05),
            SKAction.removeFromParent()
            ]))
        }
        setScoreLabel()
        setTeach()
    }
    
    func cutGame() {
        nowGameStatus = .gameing
        
        nodeOfWorld.enumerateChildNodes(withName: "teachGame") { nodeMarry, _ in nodeMarry.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.05),
            SKAction.removeFromParent()
            ]))
        }
        
        boundlessResetBarrier()
        fly()
    }
    
    func cutGodown() {
        nowGameStatus = .goDown
        run(SKAction.sequence([
            voiceOfWhack,
            SKAction.wait(forDuration: 0.1),
            voiceOfFall
            ]))
        
        roleOfGame.removeAllActions()
        stopReset()
    }
    
    func cutPrintMark() {
        nowGameStatus = .printMark
        roleOfGame.removeAllActions()
        stopReset()
        setScoreCard()
    }
    
    func cutNewGame() {
        
        run(voiceOfPop)
        let newScene = GameScene(size: size)
        let transition = SKTransition.fade(with: SKColor.white, duration: 0.5)
        view?.presentScene(newScene, transition: transition)
        
    }
    
    func cutEnd() {
        nowGameStatus = .endGame
    }
    
    //MARK: 分数
    func maxScore() -> Int {
        return UserDefaults.standard.integer(forKey: "maxScore")
    }
    
    func setMaxScore(_ maxScore: Int) {
        UserDefaults.standard.set(maxScore, forKey: "maxScore")
        UserDefaults.standard.synchronize()
    }
    //MARK: 碰撞引擎
    
    func didBegin(_ contact: SKPhysicsContact) {
        let beContact = contact.bodyA.categoryBitMask == physicsTier.roleOfGame ? contact.bodyB : contact.bodyA
        
        if beContact.categoryBitMask == physicsTier.front {
            contactFront = true
        }
        if beContact.categoryBitMask == physicsTier.barrier {
            contactBarrier = true
        }
    }
    
    //MARK: 其他
    func toLearn() {
        let URLOfBaidu = URL(string: urlOfBaidu)
        UIApplication.shared.openURL(URLOfBaidu!)
    }
    
    func toRate() {
        let URLOfBaidu = URL(string: urlOfBaidu)
        UIApplication.shared.openURL(URLOfBaidu!)
    }
    
}







