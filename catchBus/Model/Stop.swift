//
//  Stop.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/25/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation

struct Stop{
    var stopNo: String!
    var stopName: String!
    
    init(stopNo: String, stopName: String) {
        self.stopNo = stopNo
        self.stopName = stopName
    }
}
