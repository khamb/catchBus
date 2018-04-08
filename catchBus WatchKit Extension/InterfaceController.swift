//
//  InterfaceController.swift
//  catchBus WatchKit Extension
//
//  Created by Khadim Mbaye on 3/25/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
   

    @IBOutlet var table: WKInterfaceTable!
    var busesData = [BusInfo]()
    var locationManager = CLLocationManager()
    //var data = [String:Any]()
    var session: WCSession = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
       
        self.session = WCSession.default
        self.session.delegate = self
        self.session.activate()
        
        DispatchQueue.main.async {
            self.loadTable()
        }
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print(self.session.isReachable)
    }
  
    
    func loadTable(){
            
        //first get closest stops' name
        DataService.instance.getStopName(handler: { closest in
            
            //then get its stop number
            DataService.instance.getStopNumber(withStopName: closest, handler: { stopCode in

                //after that get bus infos from that stop
                DataService.instance.getBusInfos(stopCode: stopCode, handler: { (data) in
                    self.busesData = data
                    
                    //filter buses out of service
                    self.busesData = self.busesData.filter({bus in
                        return bus.time != "-"
                    })
                    
                    //sort by ascending arrival time
                    self.busesData.sort(by: {(bus1, bus2) in
                        return Int(bus1.time)! < Int(bus2.time)!
                    })
                    
                    //finally load table with buses data
                    self.table.setNumberOfRows(self.busesData.count, withRowType: "myRow")

                    for i in 0..<self.busesData.count{
                        // Set the values for the row controller
                        if let row = self.table.rowController(at: i) as? rowController{
                            row.initRow(busInfo: self.busesData[i])
                        }
                    }//end of loading table
                })
            })
        })
        
    }
    

}
