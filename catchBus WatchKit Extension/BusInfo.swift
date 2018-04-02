//
//  BusInfo.swift
//  catchBus WatchKit Extension
//
//  Created by Khadim Mbaye on 3/27/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation

struct BusInfo {
    var no: String!
    var routeHeading: String!
    var time: String!
    
    init(no: String, routeHeading: String, time: String){
        self.no = no
        self.routeHeading = routeHeading
        self.time = time
    }
}