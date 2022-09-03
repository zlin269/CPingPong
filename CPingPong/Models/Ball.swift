//
//  Ball.swift
//  CPingPong
//
//  Created by 林子轩 on 2022/8/31.
//

import Foundation

struct Ball {
    var ball_spin : Double
    let drag_coefficient : Double
    var ball_height : Double {
        didSet {
            if let ballHeightChangeHandler = ballHeightChangeHandler {
                ballHeightChangeHandler(ball_height)
            }
        }
    }
    var ball_X_Velocity : Double
    var ball_Y_Velocity : Double
    var ball_Z_Velocity : Double
    
    var ballHeightChangeHandler: ((Double)->())?
}
