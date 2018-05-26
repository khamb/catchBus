//
//  FavBusInfo.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/26/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation

class FavBusInfo: BusInfo {
    var stop: Stop!
    
    init(busInfo: BusInfo, stop: Stop) {
        super.init(no: busInfo.no, routeHeading: busInfo.routeHeading, time: busInfo.time)
        self.stop = stop
    }
    
    func getBusStruct()->BusInfo{
        return BusInfo(no: self.no, routeHeading: self.routeHeading, time: self.time)
    }
    
    static func ==(left: FavBusInfo, right: FavBusInfo)->Bool{
        return left.no == right.no && left.stop.stopName == right.stop.stopName
    }
}
