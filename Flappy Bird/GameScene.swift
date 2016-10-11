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


class GameScene: SKScene {
    
    let numOfFront = 2
    let velocityOfFront: CGFloat = -150.0
    
    let gravity: CGFloat = -1500.0
    let upVelocity: CGFloat = 400.0
    var velocity = CGPoint.zero
    
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
        nodeOfWorld.addChild(roleOfGame)
    }
    
    
    
    
    //MARK: 游戏流程
    
    func creatBarrier(nameOfImage: String) -> SKSpriteNode {
        let barrier = SKSpriteNode(imageNamed: nameOfImage)
        barrier.zPosition = photos.barrier.rawValue
        return barrier
    }
    
    func setBarrier() {
        let baseBarrier = creatBarrier("CactusBottom")
        let starOfX = size.width + baseBarrier.size.width/2
        let minOfY = (starOfGame - baseBarrier.size.height/2) + heightOfGame * 0.1
        let maxOfY = (starOfGame - baseBarrier.size.height/2) + heightOfGame * 0.6
        baseBarrier.position = CGPointMake(starOfX, CGFloat.random(min: minOfY, max: maxOfY))
        nodeOfWorld.addChild(baseBarrier)
        
        let topBarrier = creatBarrier("CactusTop")
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
        runAction(allAction)
    }
    
    func fly() {
        velocity = CGPoint(x: 0, y: upVelocity)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        runAction(voiceOfFlappy)
        
        fly()
    }
    
    //MARK: 更新
    override func update(currentTime: CFTimeInterval) {
        if lastedUpdateTime > 0 {
            dt = currentTime - lastedUpdateTime
        } else {
            dt = 0
        }
        lastedUpdateTime = currentTime
        
        updateRole()
        
        updateFront()
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
}







