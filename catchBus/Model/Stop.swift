//
//  Stop.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/25/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation

struct Stop: Codable{ // change to a nsobject with a coordinate2d attribute
    let stopNo: Int
    let stopName: String
    
    enum CodingKeys: String, CodingKey {
        case stopNo = "stop_code"
        case stopName = "stop_name"
    }
    
    /*init(stopNo: String, stopName: String) {
        self.stopNo = stopNo
        self.stopName = stopName
    }*/
}



