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
    
    // Constants
    let MAX_PAD_VELOCITY : Double = 600
    
    var game_started : Bool = false
    
    var lastUpdateTime : TimeInterval?
    var dt : TimeInterval = 0
    
    var score : [Int]?
    
    // elements
    var table : SKSpriteNode?
    var net : SKSpriteNode?
    var line : SKSpriteNode?
    var border : SKSpriteNode?
    var ball : SKSpriteNode?
    var shadow : SKSpriteNode?
    var p1 : SKSpriteNode?
    var p2 : SKSpriteNode?
    
    // movements
    var p1PrevLocation : CGPoint?
    var p2PrevLocation : CGPoint?
    var p1_X_Velocity : Double {
        return (p1!.position.x - p1PrevLocation!.x)/dt
    }
    var p1_Y_Velocity : Double {
        return min((p1!.position.y - p1PrevLocation!.y)/dt *
                   abs((table?.size.height)! / 2 / p1!.position.y), MAX_PAD_VELOCITY)
    }
    var p2_X_Velocity : Double {
        return (p2!.position.x - p2PrevLocation!.x)/dt
    }
    var p2_Y_Velocity : Double {
        return max((p2!.position.y - p2PrevLocation!.y)/dt *
                   abs((table?.size.height)! / 2 / p2!.position.y), -MAX_PAD_VELOCITY)
    }
    var ball_X_Velocity : Double = 0
    var ball_Y_Velocity : Double = 0
    var ball_spin : Double = 0
    let drag_coefficient : Double = 0.5
    var ball_height : Double = 0 {
        didSet {
            shadow?.position.x = ball!.position.x + CGFloat(ball_height * 100)
        }
    }
    let gravity : Double = -1
    var ball_Z_Velocity : Double = 0
    
    var serving : Bool = true
    var passedTheNet : Bool = true
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector.zero
        
        table = SKSpriteNode(color: .blue, size: CGSize(width: self.size.width * 0.75, height: self.size.height * 0.75))
        table?.zPosition = 0.1
        table?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        table?.position = CGPoint.zero
        self.addChild(table!)
        
        border = SKSpriteNode(color: .white, size: CGSize(width: self.size.width * 0.78, height: self.size.height * 0.78))
        border?.zPosition = 0
        border?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        border?.position = CGPoint.zero
        self.addChild(border!)
        
        line = SKSpriteNode(color: .white, size: CGSize(width: (border!.size.width - table!.size.width)/2, height: (table?.size.height)!))
        line?.zPosition = 0.2
        line?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        line?.position = CGPoint.zero
        self.addChild(line!)
        
        net = SKSpriteNode(color: .gray, size: CGSize(width: (table?.size.width)! * 1.05, height: (border!.size.width - table!.size.width)/4))
        net?.zPosition = 0.2
        net?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        net?.position = CGPoint.zero
        self.addChild(net!)
        
        ball = SKSpriteNode(color: .yellow, size: CGSize(width: 15, height: 15))
        ball?.zPosition = 20
        ball?.position = CGPoint(x: (table?.position.x)!, y: ((Int.random(in: 0...1) == 0) ? -self.frame.height / 3 : self.frame.height / 3))
        ball?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ball?.name = "ball"
        ball?.physicsBody = SKPhysicsBody(rectangleOf: ball!.size)
        ball?.physicsBody?.contactTestBitMask = 1
        ball?.physicsBody?.collisionBitMask = 0
        self.addChild(ball!)
        
        shadow = SKSpriteNode(color: .black, size: CGSize(width: 18, height: 18))
        shadow?.zPosition = 19
        shadow?.position = ball!.position
        shadow?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ball_height = 0.1
        self.addChild(shadow!)
        
        p1 = SKSpriteNode(color: .green, size: CGSize(width: 50, height: 15))
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
        // check for passing the net because one can only hit the ball once
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
            
            // takes care of the case ball spawns on a pad
            if !game_started {
                if (pad1) ? p1_Y_Velocity > 0 : p2_Y_Velocity < 0 {
                    game_started = true
                } else {
                    return
                }
            }
            
            // Rebounce
            ball_Y_Velocity = -ball_Y_Velocity * 0.6
            ball_X_Velocity = -ball_X_Velocity * 0.6
            
            // Forward Velocity
            ball_Y_Velocity += ((pad1) ? p1_Y_Velocity : p2_Y_Velocity)
            
            let side_spin = (pad1) ? abs(p1_X_Velocity) > 400 : abs(p2_X_Velocity) > 400
            
            if side_spin {
                ball_spin += ((pad1) ? p1_X_Velocity : p2_X_Velocity) / 16
                ball_X_Velocity += ((pad1) ? p1_X_Velocity : p2_X_Velocity) / 1024
                ball_X_Velocity += ball_spin
            } else {
                ball_X_Velocity += ((pad1) ? p1_X_Velocity : p2_X_Velocity)
                ball_X_Velocity += ball_spin
                ball_spin /= 4
            }
            
            if serving { // -- TODO
                ball_Z_Velocity = -0.3
                serving = false
                passedTheNet = false
                ball_Y_Velocity = (pad1) ? 400 : -400
                return
            } else {
                var target_distance = ball_Y_Velocity * table!.size.height / MAX_PAD_VELOCITY
                if abs(target_distance) > border!.size.height/2 {
                    let direction = ball_Y_Velocity > 0 ? 1.0 : -1.0
                    target_distance = direction * (border!.size.height/2 - 50 + Double.random(in: -80..<80))
                }
                let travel_distance = target_distance - ball!.position.y
                ball_Z_Velocity = -ball_height*ball_Y_Velocity/travel_distance - 0.5*gravity*travel_distance/ball_Y_Velocity
                if ball_Z_Velocity > 1 {
                    ball_Z_Velocity = 1
                }
            }
            
            passedTheNet = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if location.y < -100 {
                p1?.run(SKAction.move(to: location, duration: 0))
            }
            if location.y > 100 {
                p2?.run(SKAction.move(to: location, duration: 0))
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if location.y < -100 {
                p1?.run(SKAction.move(to: location, duration: 0))
            }
            if location.y > 100 {
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
        let ball_V_sqrd = ball_X_Velocity * ball_X_Velocity + ball_Y_Velocity * ball_Y_Velocity
        ball_X_Velocity -= ball_spin * dt
        let new_Y_V_due_to_spin = sqrt(abs(ball_V_sqrd - ball_X_Velocity * ball_X_Velocity))
        
        ball_Y_Velocity = (ball_Y_Velocity > 0) ? new_Y_V_due_to_spin : -new_Y_V_due_to_spin
        if Double(prevY!) * Double((ball?.position.y)!) <= 0 {
            passedTheNet = true
        }
        
        if game_started {
            if ball_height > 0 {
                ball_Z_Velocity += gravity * dt
                ball_height += ball_Z_Velocity * dt
            }
            else if ball_height < 0 {
                ball_Z_Velocity = -ball_Z_Velocity
                ball_height = 0.01
                let dot = SKSpriteNode(color: .red, size: ball!.size)
                dot.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                dot.zPosition = 100
                dot.position = ball!.position
                self.addChild(dot)
                dot.run(SKAction.fadeOut(withDuration: 1), completion: {
                    dot.removeFromParent()
                })
            }
        }
        
        shadow?.position.y = ball!.position.y
        
        print("ball z: \(ball_height)")
        print("ball z v: \(ball_Z_Velocity)")
        print("spin: \(ball_spin)")
        print(serving)
        
        if ballOutOfBound() {
            reset()
        }
    }
    
    func ballOutOfBound () -> Bool {
        return (ball?.position.x)! < -self.size.width/2 || (ball?.position.x)! > self.size.width/2 ||
        (ball?.position.y)! < -self.size.height/2 || (ball?.position.y)! > self.size.height/2
    }
    
    func reset () {
        game_started = false
        ball_X_Velocity = 0
        ball_Y_Velocity = 0
        ball_Z_Velocity = 0
        ball_height = 0.1
        ball_spin = 0
        ball?.position = CGPoint(x: (table?.position.x)!, y: ((Int.random(in: 0...1) == 0) ? -self.size.height / 3 : self.size.height / 3))
        shadow?.position = ball!.position
        passedTheNet = true
        serving = true
    }
    
}
