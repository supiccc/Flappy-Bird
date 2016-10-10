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
    
    let nodeOfWorld = SKNode()
    var starOfGame: CGFloat = 0
    var heightOfGame: CGFloat = 0
    
    
    override func didMoveToView(view: SKView) {
        addChild(nodeOfWorld)
        setBackground()
        setFrontground()
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
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
   
    override func update(currentTime: CFTimeInterval) {

    }
}
