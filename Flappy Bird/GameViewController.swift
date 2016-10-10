//
//  GameViewController.swift
//  Flappy Bird
//
//  Created by fang on 15/12/2.
//  Copyright (c) 2015年 Fang YiXiong. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let ViewOfGame = self.view as? SKView {
            if ViewOfGame.scene == nil {
                //  创建场景
                let boundsOfView = ViewOfGame.bounds.size.height / ViewOfGame.bounds.size.width
                let SceneOfGame = GameScene(size:CGSize(width: 320, height: 320 * boundsOfView))
                ViewOfGame.showsFPS = true
                ViewOfGame.showsNodeCount = true
                ViewOfGame.showsPhysics = true
                ViewOfGame.ignoresSiblingOrder = true
                
                SceneOfGame.scaleMode = .AspectFill
                
                ViewOfGame.presentScene(SceneOfGame)
            }
        }
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

