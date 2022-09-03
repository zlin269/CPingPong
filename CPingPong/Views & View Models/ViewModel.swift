//
//  ViewModel.swift
//  CPingPong
//
//  Created by 林子轩 on 2022/9/3.
//

import Foundation
import SpriteKit

extension GameScene {
    
    func bindModelVariableListeners() {
        pingpongTable.table_width_calculation = {
            if self.size.width * 16/9 <= self.size.height {
                return self.size.width * 0.7
            } else {
                return self.size.height * 0.7 / self.pingpongTable.TABLE_HEIGHT_WIDTH_RATIO
            }
        }
        
        pad1.X_velocity_calculation = { [self] in
            return (p1!.position.x - pad1.prevLocation!.x)/game_states.dt
        }
        
        pad1.Y_velocity_calculation = { [self] in
            return min((p1!.position.y - pad1.prevLocation!.y)/game_states.dt *
                       abs((table?.size.height)! / 2 / p1!.position.y), game_states.MAX_PAD_VELOCITY)
        }
        
        pad2.X_velocity_calculation = { [self] in
            return (p2!.position.x - pad2.prevLocation!.x)/game_states.dt
        }
        
        pad2.Y_velocity_calculation = { [self] in
            return max((p2!.position.y - pad2.prevLocation!.y)/game_states.dt *
                       abs((table?.size.height)! / 2 / p2!.position.y), -game_states.MAX_PAD_VELOCITY)
        }
        
        ball_info.ballHeightChangeHandler = { [self] ball_height in
            if ball_height >= 0 {
                shadow?.isHidden = false
                shadow?.position.x = ball!.position.x + CGFloat(ball_height * pingpongTable.SHADOW_DISTANCE)
            } else {
                shadow?.isHidden = true
            }
            ball?.size = CGSize(width: max(pingpongTable.table_width / pingpongTable.TABLE_BALL_RATIO + ball_height * 10, 0), height: max(pingpongTable.table_width / pingpongTable.TABLE_BALL_RATIO + ball_height * 10, 0))
        }
        
        game_states.max_pad_velocity_calculation = {
            return 2 * Double(self.size.height)
        }
        
        game_states.handleScoreChange = { [self] s0, s1 in
            topLbl?.text = "\(s1)"
            bottomLbl?.text = "\(s0)"
        }
    }
    
    func startGame() {

        fullReset()
        
    }
    
    func addScore(stroker is_p1 : Bool) {
        if is_p1 {
            game_states.score![1] += 1
        } else {
            game_states.score![0] += 1
        }
    }
    
    func ballOutOfScreen () -> Bool {
        return (ball?.position.x)! < -self.size.width/2 || (ball?.position.x)! > self.size.width/2 ||
        (ball?.position.y)! < -self.size.height/2 || (ball?.position.y)! > self.size.height/2
    }
    
    func ballOutofBound () -> Bool {
        return (ball?.position.x)! < -pingpongTable.table_width/2 || (ball?.position.x)! > pingpongTable.table_width/2 ||
        (ball?.position.y)! < -table!.size.height/2 || (ball?.position.y)! > table!.size.height/2
    }
    
    func round_over () {
        game_states.wait_for_reset = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            addScore(stroker: game_states.p1_hit)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            if !((game_states.score![0] >= 11 || game_states.score![1] >= 11) && abs(game_states.score![0]-game_states.score![1]) > 1) {
                reset()
            } else {
                message?.text = game_states.score![0] > game_states.score![1] ? "<- Winner -<" : ">- Winner ->"
            }
        }
    }
    
    // reset the ball
    func reset () {
        print("reset")
        // reset ball position
        ball_info.ball_X_Velocity = 0
        ball_info.ball_Y_Velocity = 0
        ball_info.ball_Z_Velocity = 0
        ball_info.ball_height = 0.1
        ball_info.ball_spin = 0
        ball?.position = CGPoint(x: (table?.position.x)!, y: ((Int.random(in: 0...1) == 0) ? -table!.size.height / 2.5 : table!.size.height / 2.5))
        shadow?.position = ball!.position
        
        // reset message
        message?.text = ""
        
        // Booleans
        game_states.game_started = false
        game_states.serving = true
        game_states.passedTheNet = true
        game_states.bounced = false
        game_states.wait_for_reset = false
    }
    
    // reset the game
    func fullReset() {
        reset()
        message?.text = "Hit the ball to start"
        game_states.score = [0,0]
        
        p1?.position = CGPoint(x: (table?.position.x)!, y: -table!.size.height/2 - 25)
        pad1.prevLocation = p1?.position
        p2?.position = CGPoint(x: (table?.position.x)!, y: table!.size.height/2 + 25)
        pad2.prevLocation = p2?.position
        
    }
    
    func handleBallHit(_ isPad1: Bool!) {
        game_states.p1_hit = isPad1
        
        // if pad touches the ball before bounce (except for serve)
        if !game_states.bounced && !game_states.serving {
            if ballOutofBound() { // if the ball is already out, it is out
                message?.text = "OUT"
                game_states.p1_hit = !game_states.p1_hit // receiver score
            } else {
                message?.text = "Volleying"
            }
            round_over()
        }
        
        // Rebounce
        ball_info.ball_Y_Velocity *= -0.6
        ball_info.ball_X_Velocity *= -0.6
        
        // Forward Velocity
        ball_info.ball_Y_Velocity += ((isPad1) ? pad1.Y_velocity : pad2.Y_velocity) / 3
        
        if game_states.smashed {
            ball_info.ball_X_Velocity += Double.random(in: -300...300)
            game_states.smashed = false
        }
        // if the ball is high enough, the stroke is considered a Smash
        // --a stroker too fast to react
        if ball_info.ball_height > 0.4 {
            ball_info.ball_Y_Velocity *= ball_info.ball_height * 2 + 1
            if abs(ball_info.ball_Y_Velocity) > 1400 {
                message?.text = "SMASH!!!"
                game_states.smashed = true
            }
        }
        
        // if the X Velocity is high enough, it will induce a spin to the ball
        let side_spin = (isPad1) ? abs(pad1.X_velocity) * 2 > abs(pad1.Y_velocity) : abs(pad2.X_velocity) * 2 > abs(pad2.Y_velocity)
        
        print("x:\((isPad1) ? pad1.X_velocity: pad2.X_velocity), y:\((isPad1) ? pad1.Y_velocity : pad2.Y_velocity)")
        
        if side_spin {
            let spin = ((isPad1) ? pad1.X_velocity : -pad2.X_velocity) / 4
            ball_info.ball_spin /= 4
            ball_info.ball_spin += spin
            ball_info.ball_X_Velocity += (ball_info.ball_Y_Velocity > 0) ? (ball_info.ball_spin / 2) : (-ball_info.ball_spin / 2)
            ball_info.ball_X_Velocity += ((isPad1) ? pad1.X_velocity : pad2.X_velocity) / 1024
        } else {
            ball_info.ball_X_Velocity += ((isPad1) ? pad1.X_velocity : pad2.X_velocity) / 3
            ball_info.ball_X_Velocity += (ball_info.ball_Y_Velocity > 0) ? (ball_info.ball_spin) : (-ball_info.ball_spin)
            ball_info.ball_spin /= 4
        }
        
        // calculate the angle, represented by vertical velocity, required to get the ball
        // to a desired location
        // this is done automatically based on the ball's velocity
        if game_states.serving {
            ball_info.ball_Z_Velocity = -0.8
            game_states.serving = false
            game_states.passedTheNet = false
        } else {
            var target_distance = ball_info.ball_Y_Velocity * table!.size.height * 0.8 / (game_states.MAX_PAD_VELOCITY / 3)
            if abs(target_distance) > table!.size.height/2 {
                let direction = ball_info.ball_Y_Velocity > 0 ? 1.0 : -1.0
                target_distance = direction * (table!.size.height/2 - 50 + Double.random(in: -80..<80))
            }
            let travel_distance = target_distance - ball!.position.y
            ball_info.ball_Z_Velocity = -ball_info.ball_height*ball_info.ball_Y_Velocity/travel_distance - 0.5*game_states.gravity*travel_distance/ball_info.ball_Y_Velocity
            if ball_info.ball_Z_Velocity > 2 {
                ball_info.ball_Z_Velocity = 2
            }
        }
    }
    
    func renderBallTrace() {
        // trace of the ball
        do {
            let trace = SKShapeNode(circleOfRadius: ball!.size.width / 2)
            trace.lineWidth = 2.0
            trace.fillColor = .white
            if abs(ball_info.ball_X_Velocity) + abs(ball_info.ball_Y_Velocity) > 1100 {
                trace.strokeColor = .cyan
            } else if abs(ball_info.ball_X_Velocity) + abs(ball_info.ball_Y_Velocity) > 800 {
                trace.strokeColor = .orange
            } else {
                trace.strokeColor = .white
            }
            trace.zPosition = 18
            trace.position = ball!.position
            self.addChild(trace)
            trace.run(SKAction.scale(to: 0, duration: 1))
            trace.run(SKAction.fadeOut(withDuration: 1), completion: {
                trace.removeFromParent()
            })
        }
    }
    
    func simulateVertialBallMovement() {
        // Vertical update
        if !ballOutofBound() {
            if ball_info.ball_height > 0 {
                ball_info.ball_Z_Velocity += game_states.gravity * game_states.dt
                ball_info.ball_height += ball_info.ball_Z_Velocity * game_states.dt
            } else if ball_info.ball_height > -0.1 { // Deal with ball hitting table
                if game_states.bounced {
                    if !game_states.wait_for_reset {
                        if game_states.passedTheNet {
                            game_states.p1_hit = !game_states.p1_hit
                        }
                        message?.text = "Double Bounce"
                        round_over()
                    }
                } else {
                    game_states.bounced = true
                }
                
                // reflect off the table top
                ball_info.ball_Z_Velocity *= -0.9
                ball_info.ball_height = 0.01
                // change of direction due to spin
                ball_info.ball_X_Velocity -= (ball_info.ball_Y_Velocity > 0 ? 1 : -1) * ball_info.ball_spin * 0.3
                ball_info.ball_spin *= 0.85
                
                // a marker on the table to indicate bounce
                let dot = SKShapeNode(circleOfRadius: ball!.size.width / 2)
                dot.fillColor = .red
                dot.strokeColor = .red
                dot.alpha = 0.5
                dot.zPosition = 100
                dot.position = ball!.position
                self.addChild(dot)
                dot.run(SKAction.fadeOut(withDuration: 1), completion: {
                    dot.removeFromParent()
                })
            }
        } else {
            if (ball_info.ball_height < -1 || (ball_info.ball_height < 0 && ballOutOfScreen())) && !game_states.wait_for_reset {
                if !game_states.bounced || !game_states.passedTheNet {
                    message?.text = "OUT"
                } else {
                    game_states.p1_hit = !game_states.p1_hit
                    message?.text = "Score"
                }
                round_over()
            }
            ball_info.ball_Z_Velocity += game_states.gravity * game_states.dt
            ball_info.ball_height += ball_info.ball_Z_Velocity * game_states.dt
        }
    }
    
    func simulateBallMovement() {
        ball_info.ball_Y_Velocity -= ball_info.ball_Y_Velocity * ball_info.drag_coefficient * game_states.dt
        ball?.position.y += ball_info.ball_Y_Velocity * game_states.dt
        ball_info.ball_X_Velocity -= ball_info.ball_X_Velocity * ball_info.drag_coefficient * game_states.dt
        ball?.position.x += ball_info.ball_X_Velocity * game_states.dt
        ball_info.ball_spin -= ball_info.ball_spin * ball_info.drag_coefficient * game_states.dt
        
        // change of direction due to spin
        let ball_V_sqrd = ball_info.ball_X_Velocity * ball_info.ball_X_Velocity + ball_info.ball_Y_Velocity * ball_info.ball_Y_Velocity
        ball_info.ball_X_Velocity += ball_info.ball_Y_Velocity > 0 ? -ball_info.ball_spin * game_states.dt : ball_info.ball_spin * game_states.dt
        let new_Y_V_due_to_spin = sqrt(abs(ball_V_sqrd - ball_info.ball_X_Velocity * ball_info.ball_X_Velocity))
        ball_info.ball_Y_Velocity = (ball_info.ball_Y_Velocity > 0) ? new_Y_V_due_to_spin : -new_Y_V_due_to_spin
    }
}
