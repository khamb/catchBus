//
//  Trip.swift
//  catchBus
//
//  Created by Khadim Mbaye on 1/17/19.
//  Copyright © 2019 Khadim Mbaye. All rights reserved.
//

import Foundation

struct Trip: Decodable {
    var adjustedScheduleTime: String
    
    enum CodingKeys: String, CodingKey {
        case adjustedScheduleTime = "AdjustedScheduleTime"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        adjustedScheduleTime = try container.decode(String.self, forKey: .adjustedScheduleTime)
        print(adjustedScheduleTime)
    }
}
