//
//  File.swift
//  CPingPong
//
//  Created by 林子轩 on 2022/8/31.
//

import Foundation
import SpriteKit

struct Paddle {
    var prevLocation : CGPoint?
    var X_velocity : CGFloat {
        if let X_velocity_calculation = X_velocity_calculation {
            return X_velocity_calculation();
        } else {
            return 0;
        }
    }
    var Y_velocity : CGFloat {
        if let X_velocity_calculation = X_velocity_calculation {
            return X_velocity_calculation();
        } else {
            return 0;
        }
    }
    
    var X_velocity_calculation : (()->(CGFloat))?
    
    var Y_velocity_calculation : (()->(CGFloat))?

}
