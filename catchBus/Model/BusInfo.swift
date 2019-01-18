//
//  BusInfo.swift
//  catchBus WatchKit Extension
//
//  Created by Khadim Mbaye on 5/27/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation

class BusInfo: Codable{
    let no: String
    let routeHeading: String
    let time: String

    
    init(no: String, routeHeading: String, time: String){
        self.no = no
        self.routeHeading = routeHeading
        if time==""{
            self.time = "-";
        }else{
            self.time = time
        }

    }
    
  
    
}


