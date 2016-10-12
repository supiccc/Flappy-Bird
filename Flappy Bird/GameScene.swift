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
    
    let numOfFront = 2
    let velocityOfFront: CGFloat = -150.0
    
    let gravity: CGFloat = -1500.0
    let upVelocity: CGFloat = 400.0
    var velocity = CGPoint.zero
    
    var contactFront = false
    var contactBarrier = false
    var nowGameStatus: statusGame = .gameing
    
    let nodeOfWorld = SKNode()
    var starOfGame: CGFloat = 0
    var heightOfGame: CGFloat = 0
    let roleOfGame = SKSpriteNode(imageNamed: "Bird0")
    
    var lastedUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    let firstSetBarrierTime: NSTimeInterval = 1.75
    let resetBarrierTime: NSTimeInterval = 1.5
    
    // Voice
    let voiceOfDing = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let voiceOfFlappy = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let voiceOfWhack = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let voiceOfHit = SKAction.playSoundFileNamed("hitGround.wav", waitForCompletion: false)
    let voiceOfFall = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let voiceOfPop = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let voiceOfCoin = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    override func didMoveToView(view: SKView) {
        
        //关闭重力
        physicsWorld.gravity = CGVectorMake(0, 0)
        
        //设置碰撞代理
        physicsWorld.contactDelegate = self
        
        
        addChild(nodeOfWorld)
        setBackground()
        setFrontground()
        setRole()
        boundlessResetBarrier()
    }
    
    
    
    
    // MARK: 设置的相关方法
    
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
        
        self.physicsBody = SKPhysicsBody(edgeFromPoint: zuoxia, toPoint: youxia)
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
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 1 - offsetX, 15 - offsetY)
        CGPathAddLineToPoint(path, nil, 8 - offsetX, 18 - offsetY)
        CGPathAddLineToPoint(path, nil, 11 - offsetX, 21 - offsetY)
        CGPathAddLineToPoint(path, nil, 18 - offsetX, 23 - offsetY)
        CGPathAddLineToPoint(path, nil, 20 - offsetX, 28 - offsetY)
        CGPathAddLineToPoint(path, nil, 26 - offsetX, 29 - offsetY)
        CGPathAddLineToPoint(path, nil, 34 - offsetX, 29 - offsetY)
        CGPathAddLineToPoint(path, nil, 38 - offsetX, 25 - offsetY)
        CGPathAddLineToPoint(path, nil, 38 - offsetX, 20 - offsetY)
        CGPathAddLineToPoint(path, nil, 38 - offsetX, 12 - offsetY)
        CGPathAddLineToPoint(path, nil, 38 - offsetX, 7 - offsetY)
        CGPathAddLineToPoint(path, nil, 35 - offsetX, 4 - offsetY)
        CGPathAddLineToPoint(path, nil, 33 - offsetX, 2 - offsetY)
        CGPathAddLineToPoint(path, nil, 29 - offsetX, 2 - offsetY)
        CGPathAddLineToPoint(path, nil, 23 - offsetX, 3 - offsetY)
        CGPathAddLineToPoint(path, nil, 22 - offsetX, 1 - offsetY)
        CGPathAddLineToPoint(path, nil, 20 - offsetX, 0 - offsetY)
        CGPathAddLineToPoint(path, nil, 17 - offsetX, 0 - offsetY)
        CGPathAddLineToPoint(path, nil, 5 - offsetX, 1 - offsetY)
        
        CGPathCloseSubpath(path)
        
        roleOfGame.physicsBody = SKPhysicsBody(polygonFromPath: path)
        roleOfGame.physicsBody?.categoryBitMask = physicsTier.roleOfGame
        roleOfGame.physicsBody?.collisionBitMask = 0  //关闭碰撞处理
        roleOfGame.physicsBody?.contactTestBitMask = physicsTier.front | physicsTier.barrier
        
        
        nodeOfWorld.addChild(roleOfGame)
    }
    
    
    
    
    //MARK: 游戏流程
    
    func creatBarrier(nameOfImage: String) -> SKSpriteNode {
        let barrier = SKSpriteNode(imageNamed: nameOfImage)
        barrier.zPosition = photos.barrier.rawValue
        let offsetX = barrier.size.width * barrier.anchorPoint.x
        let offsetY = barrier.size.height * barrier.anchorPoint.y
        
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 3 - offsetX, 2 - offsetY)
        CGPathAddLineToPoint(path, nil, 6 - offsetX, 309 - offsetY)
        CGPathAddLineToPoint(path, nil, 46 - offsetX, 309 - offsetY)
        CGPathAddLineToPoint(path, nil, 48 - offsetX, 2 - offsetY)
        CGPathAddLineToPoint(path, nil, 48 - offsetX, 0 - offsetY)
        CGPathAddLineToPoint(path, nil, 5 - offsetX, 0 - offsetY)
        
        CGPathCloseSubpath(path)
        
        barrier.physicsBody = SKPhysicsBody(polygonFromPath: path)
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
        baseBarrier.position = CGPointMake(starOfX, CGFloat.random(min: minOfY, max: maxOfY))
        nodeOfWorld.addChild(baseBarrier)
        
        let topBarrier = creatBarrier("CactusTop")
        topBarrier.name = "topBarrier"
        topBarrier.zRotation = CGFloat(180).degreesToRadians()
        topBarrier.position = CGPoint(x: starOfX, y: baseBarrier.position.y + baseBarrier.size.height / 2 + topBarrier.size.height / 2 + roleOfGame.size.height * 3.5)
        nodeOfWorld.addChild(topBarrier)
        
        let moveDistanceOfX = -(size.width + baseBarrier.size.width)
        let moveTimeOfX = moveDistanceOfX / velocityOfFront
        let moveAction = SKAction.sequence([SKAction.moveByX(moveDistanceOfX, y: 0, duration: NSTimeInterval(moveTimeOfX)), SKAction.removeFromParent()
            ])
        
        baseBarrier.runAction(moveAction)
        topBarrier.runAction(moveAction)
    }
    
    
    func boundlessResetBarrier() {
        let firstSetTime = SKAction.waitForDuration(firstSetBarrierTime)
        let resetBarrier = SKAction.runBlock(setBarrier)
        let resetTime = SKAction.waitForDuration(resetBarrierTime)
        let resetAction = SKAction.sequence([resetBarrier, resetTime])
        let boundlessReset = SKAction.repeatActionForever(resetAction)
        let allAction = SKAction.sequence([firstSetTime, boundlessReset])
        runAction(allAction, withKey: "reset")
    }
    
    func stopReset() {
        removeActionForKey("reset")
        
        nodeOfWorld.enumerateChildNodesWithName("baseBarrier", usingBlock: {
            nodeMarry, _ in nodeMarry.removeAllActions()
            })
        nodeOfWorld.enumerateChildNodesWithName("topBarrier", usingBlock: {
            nodeMarry, _ in nodeMarry.removeAllActions()
        })
        
    }
    
    func fly() {
        velocity = CGPoint(x: 0, y: upVelocity)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        runAction(voiceOfFlappy)
        
        switch nowGameStatus {
        case .gameMenu:
            break
        case .gameing:
            fly()
            break
        case .teachGame:
            break
        case .goDown:
            break
        case .printMark:
            break
        case .endGame:
            break
        default:
            break
        }
    } 
    
    //MARK: 更新
    override func update(currentTime: CFTimeInterval) {
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
        nodeOfWorld.enumerateChildNodesWithName("frontground", usingBlock: { nodeOfMatch, _ in
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
            runAction(voiceOfHit)
            cutPrintMark()
        }
    }
    
    //MARK: 游戏状态
    
    func cutGodown() {
        nowGameStatus = .goDown
        runAction(SKAction.sequence([
            voiceOfWhack,
            SKAction.waitForDuration(0.1),
            voiceOfFall
            ]))
        
        roleOfGame.removeAllActions()
        stopReset()
    }
    
    func cutPrintMark() {
        nowGameStatus = .printMark
        roleOfGame.removeAllActions()
        stopReset()
    }
    
    //MARK: 碰撞引擎
    
    func didBeginContact(contact: SKPhysicsContact) {
        let beContact = contact.bodyA.categoryBitMask == physicsTier.roleOfGame ? contact.bodyB : contact.bodyA
        
        if beContact.categoryBitMask == physicsTier.front {
            contactFront = true
        }
        if beContact.categoryBitMask == physicsTier.barrier {
            contactBarrier = true
        }
    }
}







