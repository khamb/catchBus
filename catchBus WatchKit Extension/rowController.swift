//
//  rowController.swift
//  catchBus WatchKit Extension
//
//  Created by Khadim Mbaye on 3/26/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import WatchKit

class rowController: NSObject {
    
   
    @IBOutlet var routeLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    
    func initRow(busInfo: BusInfo){
        self.routeLabel.setText(busInfo.no+", "+busInfo.routeHeading!)
        self.timeLabel.setText(busInfo.time+" m") 
    }
}
