//
//  GameScene.swift
//  Ping-Pong
//
//  Created by Prashuk Ajmera on 5/21/19.
//  Copyright © 2019 Prashuk Ajmera. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var lastUpdateTime : TimeInterval?
    var dt : TimeInterval = 0
    
    var score : [Int]?
    
    // elements
    var table : SKSpriteNode?
    var ball : SKSpriteNode?
    var p1 : SKSpriteNode?
    var p2 : SKSpriteNode?
    
    // movements
    var p1PrevLocation : CGPoint?
    var p2PrevLocation : CGPoint?
    var p1_X_Velocity : Double {
        return (p1!.position.x - p1PrevLocation!.x)/dt
    }
    var p1_Y_Velocity : Double {
        return (p1!.position.y - p1PrevLocation!.y)/dt
    }
    var p2_X_Velocity : Double {
        return (p2!.position.x - p2PrevLocation!.x)/dt
    }
    var p2_Y_Velocity : Double {
        return (p2!.position.y - p2PrevLocation!.y)/dt
    }
    var ball_X_Velocity : Double = 0
    var ball_Y_Velocity : Double = 0
    var ball_spin : Double = 0
    var drag_coefficient : Double = 0.2
    
    var passedTheNet : Bool = true
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector.zero
        
        table = SKSpriteNode(color: .blue, size: CGSize(width: self.size.width * 0.75, height: self.size.height * 0.75))
        table?.zPosition = 0
        table?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        table?.position = CGPoint.zero
        self.addChild(table!)
        
        ball = SKSpriteNode(color: .yellow, size: CGSize(width: 15, height: 15))
        ball?.zPosition = 20
        ball?.position = CGPoint(x: (table?.position.x)!, y: ((Int.random(in: 0...1) == 0) ? -self.size.height / 5 : self.size.height / 5))
        ball?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ball?.name = "ball"
        ball?.physicsBody = SKPhysicsBody(rectangleOf: ball!.size)
        ball?.physicsBody?.contactTestBitMask = 1
        self.addChild(ball!)
        
        p1 = SKSpriteNode(color: .white, size: CGSize(width: 50, height: 15))
        p1?.zPosition = 10
        p1?.position = CGPoint(x: (table?.position.x)!, y: -table!.size.height/2 - 20)
        p1?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        p1?.name = "p1"
        p1?.physicsBody = SKPhysicsBody(rectangleOf: p1!.size)
        p1?.physicsBody?.contactTestBitMask = 1
        p1?.physicsBody?.isDynamic = false
        self.addChild(p1!)
        p1PrevLocation = p1?.position
        
        p2 = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 15))
        p2?.zPosition = 10
        p2?.position = CGPoint(x: (table?.position.x)!, y: table!.size.height/2 + 20)
        p2?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        p2?.name = "p2"
        p2?.physicsBody = SKPhysicsBody(rectangleOf: p2!.size)
        p2?.physicsBody?.contactTestBitMask = 1
        p2?.physicsBody?.isDynamic = false
        self.addChild(p2!)
        p2PrevLocation = p2?.position
        
        startGame()
    }

    func startGame() {

        score = [0,0]
        
    }
    
    func addScore(playerWhoWon: SKSpriteNode) {
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if passedTheNet {
            var pingpong: SKSpriteNode?
            var pad1 : Bool!
            if contact.bodyA.node?.name == "ball" {
                pingpong = contact.bodyA.node as? SKSpriteNode
                pad1 = contact.bodyB.node?.name == "p1"
            }
            else if contact.bodyB.node?.name == "ball" {
                pingpong = contact.bodyB.node as? SKSpriteNode
                pad1 = contact.bodyA.node?.name == "p1"
            }
            ball_Y_Velocity = -ball_Y_Velocity * 0.6
            ball_Y_Velocity += ((pad1) ? p1_Y_Velocity : p2_Y_Velocity)
            let sideSpin : Bool = (pad1) ? abs(p1_X_Velocity) > abs(p1_Y_Velocity) : abs(p2_X_Velocity) > abs(p2_Y_Velocity)
            if sideSpin {
                ball_X_Velocity += ((pad1) ? p1_X_Velocity : p2_X_Velocity) / 4
                ball_spin += ((pad1) ? p1_X_Velocity : p2_X_Velocity) / 4
            } else {
                ball_X_Velocity += ((pad1) ? p1_X_Velocity : p2_X_Velocity) / 2
            }
            passedTheNet = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if location.y < -10 {
                p1?.run(SKAction.move(to: location, duration: 0))
            }
            if location.y > 10 {
                p2?.run(SKAction.move(to: location, duration: 0))
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if location.y < -10 {
                p1?.run(SKAction.move(to: location, duration: 0))
            }
            if location.y > 10 {
                p2?.run(SKAction.move(to: location, duration: 0))
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        defer {
            lastUpdateTime = currentTime
            p1PrevLocation = p1?.position
            p2PrevLocation = p2?.position
        }
        guard lastUpdateTime != nil else {
            return
        }
        if let lastTime = lastUpdateTime  {
            dt = currentTime - lastTime
        }
        ball_Y_Velocity -= ball_Y_Velocity * drag_coefficient * dt
        let prevY = ball?.position.y
        ball?.position.y += ball_Y_Velocity * dt
        ball_X_Velocity -= ball_X_Velocity * drag_coefficient * dt
        ball?.position.x += ball_X_Velocity * dt
        if Double(prevY!) * Double((ball?.position.y)!) <= 0 {
            passedTheNet = true
        }
        print("ball x: \(ball_X_Velocity)")
        print("ball y: \(ball_Y_Velocity)")
        
        if ballOutOfBound() {
            reset()
        }
    }
    
    func ballOutOfBound () -> Bool {
        return (ball?.position.x)! < -self.size.width/2 || (ball?.position.x)! > self.size.width/2 ||
        (ball?.position.y)! < -self.size.height/2 || (ball?.position.y)! > self.size.height/2
    }
    
    func reset () {
        ball_X_Velocity = 0
        ball_Y_Velocity = 0
        ball_spin = 0
        ball?.position = CGPoint(x: (table?.position.x)!, y: ((Int.random(in: 0...1) == 0) ? -self.size.height / 5 : self.size.height / 5))
        passedTheNet = true
    }
    
    func backBtnTap() {
        print("backbtn tapped")
    }
}
