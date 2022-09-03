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
    
    // Table Constants
    var pingpongTable = PingpongTable()
    
    // elements
    var table : SKSpriteNode?
    var ball : SKSpriteNode?
    var shadow : SKSpriteNode?
    var p1 : SKSpriteNode?
    var p2 : SKSpriteNode?
    
    // movements
    var pad1 = Paddle()
    var pad2 = Paddle()
    
    var ball_info = Ball(ball_spin: 0, drag_coefficient: 0.5, ball_height: 0,
                         ball_X_Velocity: 0, ball_Y_Velocity: 0, ball_Z_Velocity: 0)
    
    var game_states = GameStateVars(gravity: -5)
   
    var topLbl : SKLabelNode?
    var bottomLbl : SKLabelNode?
    var message : SKLabelNode?
    
   
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector.zero
        
        bindModelVariableListeners()
        
        table = SKSpriteNode(imageNamed: "table")
        table?.size = CGSize(width: pingpongTable.table_width, height: pingpongTable.table_width * table!.size.height / table!.size.width)
        table?.zPosition = 0.1
        table?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        table?.position = CGPoint.zero
        self.addChild(table!)
        let table_shadow = SKShapeNode(rect: CGRect(origin: CGPoint(x: 15 - pingpongTable.table_width/2, y: -15 - table!.size.height/2), size: table!.size), cornerRadius: 5)
        table_shadow.zPosition = -1
        table_shadow.fillColor = .black
        table_shadow.strokeColor = .clear
        table_shadow.alpha = 0.5
        table?.addChild(table_shadow)
        
        ball = SKSpriteNode(imageNamed: "ball")
        ball?.size = CGSize(width: pingpongTable.table_width / pingpongTable.TABLE_BALL_RATIO, height: pingpongTable.table_width / pingpongTable.TABLE_BALL_RATIO)
        ball?.zPosition = 20
        ball?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ball?.name = "ball"
        ball?.physicsBody = SKPhysicsBody(rectangleOf: ball!.size)
        ball?.physicsBody?.contactTestBitMask = 1
        ball?.physicsBody?.collisionBitMask = 0
        self.addChild(ball!)
        
        shadow = SKSpriteNode(color: .clear, size: ball!.size)
        let circle = SKShapeNode(circleOfRadius: ball!.size.width/2)
        circle.fillColor = .black
        circle.strokeColor = .clear
        circle.alpha = 0.8
        shadow?.zPosition = 19
        shadow?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        shadow?.addChild(circle)
        self.addChild(shadow!)
        
        p1 = SKSpriteNode(imageNamed: "pad1")
        p1?.size = CGSize(width: ball!.size.width * 2.5, height: ball!.size.width * 2.5 / p1!.size.width * p1!.size.height)
        p1?.zPosition = 10
        p1?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        p1?.name = "p1"
        p1?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: p1!.size.width * 0.8, height: ball!.size.width))
        p1?.physicsBody?.contactTestBitMask = 1
        p1?.physicsBody?.isDynamic = false
        self.addChild(p1!)
        
        p2 = SKSpriteNode(imageNamed: "pad2")
        p2?.size = CGSize(width: ball!.size.width * 2.5, height: ball!.size.width * 2.5 / p2!.size.width * p2!.size.height)
        p2?.zPosition = 10
        p2?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        p2?.name = "p2"
        p2?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: p2!.size.width * 0.8, height: ball!.size.width))
        p2?.physicsBody?.contactTestBitMask = 1
        p2?.physicsBody?.isDynamic = false
        self.addChild(p2!)
        
        let scoreBoard = SKShapeNode(rect: CGRect(origin: CGPoint(x: self.frame.maxX - 10 - pingpongTable.table_width / 7, y: -table!.size.height / 3), size: CGSize(width: pingpongTable.table_width / 7, height: 2 * table!.size.height / 3)), cornerRadius: 20)
        scoreBoard.zPosition = 0
        scoreBoard.strokeColor = .clear
        scoreBoard.fillColor = UIColor(red: 101.0/255, green: 23.0/255, blue: 201.0/255, alpha: 1)
        self.addChild(scoreBoard)
        let minipad1_icon = SKSpriteNode(imageNamed: "mini pad 1")
        minipad1_icon.zPosition = 1
        minipad1_icon.position = CGPoint(x: scoreBoard.frame.midX, y: scoreBoard.frame.minY + 30)
        minipad1_icon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        minipad1_icon.zRotation = -.pi / 2
        scoreBoard.addChild(minipad1_icon)
        let minipad2_icon = SKSpriteNode(imageNamed: "mini pad 2")
        minipad2_icon.zPosition = 1
        minipad2_icon.position = CGPoint(x: scoreBoard.frame.midX, y: scoreBoard.frame.maxY - 30)
        minipad2_icon.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        minipad2_icon.zRotation = -.pi / 6
        scoreBoard.addChild(minipad2_icon)
        
        topLbl = SKLabelNode()
        topLbl?.fontName = "HelveticaNeue-Bold"
        topLbl?.fontColor = .white
        topLbl?.fontSize = 30
        topLbl?.position = CGPoint(x: scoreBoard.frame.midX - 12, y: self.frame.midY + table!.size.height / 5)
        topLbl?.zRotation = -.pi / 2
        topLbl?.zPosition = 100
        self.addChild(topLbl!)
        
        bottomLbl = SKLabelNode()
        bottomLbl?.fontName = "HelveticaNeue-Bold"
        bottomLbl?.fontColor = .white
        bottomLbl?.fontSize = 30
        bottomLbl?.position = CGPoint(x: scoreBoard.frame.midX - 12, y: self.frame.midY - table!.size.height / 5)
        bottomLbl?.zRotation = -.pi / 2
        bottomLbl?.zPosition = 100
        self.addChild(bottomLbl!)
        
        message = SKLabelNode()
        message?.fontName = "HelveticaNeue-Bold"
        message?.fontColor = UIColor(red: 101.0/255, green: 23.0/255, blue: 201.0/255, alpha: 1)
        message?.fontSize = 40
        message?.position = CGPoint(x: self.frame.minX + 45, y: self.frame.midY)
        message?.zRotation = .pi / 2
        message?.zPosition = 100
        self.addChild(message!)
        
        
        startGame()
    }

   
    // Contact Detection
    func didBegin(_ contact: SKPhysicsContact) {
        
        if game_states.wait_for_reset { // no update
            return
        }
        
        message?.text = ""
        
        // check for passing the net because one can only hit the ball once
        if game_states.passedTheNet {
            
            var isPad1 : Bool!
            if contact.bodyA.node?.name == "ball" {
                isPad1 = contact.bodyB.node?.name == "p1"
            }
            else if contact.bodyB.node?.name == "ball" {
                isPad1 = contact.bodyA.node?.name == "p1"
            }
            
            // takes care of the case ball spawns on a pad
            if !game_states.game_started {
                if (isPad1) ? pad1.Y_velocity > 0 : pad2.Y_velocity < 0 {
                    game_states.game_started = true // start the game if moving pad touches the ball
                } else {
                    return
                }
            }
            
            handleBallHit(isPad1)
            
            game_states.passedTheNet = false
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if location.y < -20 {
                p1?.run(SKAction.move(to: location, duration: 0))
                pad1.prevLocation = p1!.position
            }
            if location.y > 20 {
                p2?.run(SKAction.move(to: location, duration: 0))
                pad2.prevLocation = p2!.position
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if location.y < -20 {
                p1?.run(SKAction.move(to: location, duration: 0))
            }
            if location.y > 20 {
                p2?.run(SKAction.move(to: location, duration: 0))
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        defer {
            game_states.lastUpdateTime = currentTime
            pad1.prevLocation = p1?.position
            pad2.prevLocation = p2?.position
        }
        guard game_states.lastUpdateTime != nil else {
            return
        }
        if let lastTime = game_states.lastUpdateTime  {
            game_states.dt = currentTime - lastTime
            game_states.dt = game_states.dt / 2
        }
        
        if game_states.game_started {
            
            renderBallTrace()
            
            // reduction on velocity and spin due to air resistance
            let prevY = ball?.position.y
            
            simulateBallMovement()
            
            // the middle of the table has y-coordinate of 0
            if Double(prevY!) * Double((ball?.position.y)!) <= 0 {
                game_states.passedTheNet = true
            }
            
            simulateVertialBallMovement()
            
            // Check ball height when crossing the net
            if (prevY! * ball!.position.y <= 0 && ball_info.ball_height < 0.1) && !ballOutofBound() && !game_states.wait_for_reset{
                if Int.random(in: 1...20) == 1 {
                    // the case when scratching the net but still passes
                    // very powerful in real life "lucky ball"
                    ball_info.ball_Y_Velocity = ball_info.ball_Y_Velocity * 0.1
                } else {
                    if Int.random(in: 1...3) == 1 {
                        message?.text = "NET"
                        ball_info.ball_Y_Velocity *= -0.1
                        round_over()
                    }
                }
            }
            
            
        }
        
        shadow?.position.y = ball!.position.y
        
    }
    
   
}
