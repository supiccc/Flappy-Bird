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
    case frontground
    case roleOfGame
}


class GameScene: SKScene {
    
    let gravity: CGFloat = -1500.0
    let upVelocity: CGFloat = 400.0
    var velocity = CGPoint.zero
    let nodeOfWorld = SKNode()
    var starOfGame: CGFloat = 0
    var heightOfGame: CGFloat = 0
    let roleOfGame = SKSpriteNode(imageNamed: "Bird0")
    var lastedUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    
    // Voice
    let voiceOfDing = SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)
    let voiceOfFlappy = SKAction.playSoundFileNamed("flapping.wav", waitForCompletion: false)
    let voiceOfWhack = SKAction.playSoundFileNamed("whack.wav", waitForCompletion: false)
    let voiceOfHit = SKAction.playSoundFileNamed("hitground.wav", waitForCompletion: false)
    let voiceOfFall = SKAction.playSoundFileNamed("falling.wav", waitForCompletion: false)
    let voiceOfPop = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let voiceOfCoin = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false)
    
    override func didMoveToView(view: SKView) {
        addChild(nodeOfWorld)
        setBackground()
        setFrontground()
        setRole()
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
        let frontground = SKSpriteNode(imageNamed: "Ground")
        frontground.anchorPoint = CGPoint(x: 0, y: 1.0)
        frontground.position = CGPoint(x: 0, y: starOfGame)
        frontground.zPosition = photos.frontground.rawValue
        nodeOfWorld.addChild(frontground)
    }
    
    func setRole() {
        roleOfGame.position = CGPoint(x: size.width * 0.2, y: heightOfGame * 0.4 + starOfGame)
        roleOfGame.zPosition = photos.roleOfGame.rawValue
        nodeOfWorld.addChild(roleOfGame)
    }
    
    //MARK: 主角上升
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
    }
    
    func updateRole() {
        let acceleration = CGPoint(x: 0, y: gravity)
        velocity = velocity + acceleration * CGFloat(dt)
        roleOfGame.position = roleOfGame.position + velocity * CGFloat(dt)
        
        if roleOfGame.position.y - roleOfGame.size.height / 2 < starOfGame {
            roleOfGame.position = CGPoint(x: roleOfGame.position.x, y: starOfGame + roleOfGame.size.height / 2)
        }
    }
}







