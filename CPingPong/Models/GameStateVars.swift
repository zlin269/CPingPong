//
//  GameStateVars.swift
//  CPingPong
//
//  Created by 林子轩 on 2022/8/31.
//

import Foundation

struct GameStateVars {
    var MAX_PAD_VELOCITY : Double {
        if let max_pad_velocity_calculation = max_pad_velocity_calculation {
            return max_pad_velocity_calculation()
        }
        return 0
    }
    
    var max_pad_velocity_calculation: (()->(Double))?
    
    let gravity : Double
    var game_started : Bool = false
    var p1_hit : Bool = true
    var serving : Bool = true
    var passedTheNet : Bool = true {
        didSet {
            if passedTheNet {
                bounced = false
            }
        }
    }
    var bounced : Bool = false
    var smashed : Bool = false
    var wait_for_reset : Bool = false // when waiting for reset, do not check for rule violation
    
    // text indicators and scoring
    var score : [Int]? {
        didSet {
            if let handleScoreChange = handleScoreChange {
                handleScoreChange(score![0], score![1]);
            }
        }
    }
    
    
    var lastUpdateTime : TimeInterval?
    var dt : TimeInterval = 0
    
    var handleScoreChange: ((Int, Int) -> ())?
}
