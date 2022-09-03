//
//  PingpongTable.swift
//  CPingPong
//
//  Created by 林子轩 on 2022/9/2.
//

import Foundation

struct PingpongTable {
    let TABLE_HEIGHT_WIDTH_RATIO : Double = 1.79672131148
    let SHADOW_DISTANCE : Double = 200
    let TABLE_BALL_RATIO : Double = 15
    var table_width : Double {
        if let table_width_calculation = table_width_calculation {
            return table_width_calculation()
        }
        return 0
    }
    
    var table_width_calculation: (() -> (Double))?
}
