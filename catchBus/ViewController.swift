//
//  ViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 3/25/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity

class ViewController: UIViewController, CLLocationManagerDelegate, WCSessionDelegate, UITableViewDelegate, UITableViewDataSource {
 
    
    
    @IBOutlet weak var busesTable: UITableView!
    var busesData = [BusInfo]()
    var tableRefresher:UIRefreshControl = UIRefreshControl()
    
    var locationManager = CLLocationManager()
    var session: WCSession!
    var userCoordinates: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.busesTable.dataSource = self
        self.busesTable.delegate = self
        
        self.initTableRefresher()

        //activate watch connectivity if the device support it
        if (WCSession.isSupported()) {
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
        }
        
        //set up location service
        DispatchQueue.main.async {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
            
            self.loadTable()
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initTableRefresher(){
        self.busesTable.refreshControl = self.tableRefresher
        self.tableRefresher.addTarget(self, action: #selector(ViewController.self.loadTable), for: UIControlEvents.valueChanged)
        self.tableRefresher.attributedTitle = NSAttributedString(string: "updating bus informations ...")
    }
    
    @objc func loadTable(){
        
        //first get closest stops' name
        DataService.instance.getStopName(handler: { closest in
            
            //then get its stop number
            DataService.instance.getStopNumber(withStopName: closest, handler: { stopCode in
                
                //after that get bus infos from that stop
                DataService.instance.getBusInfos(stopCode: stopCode, handler: { (data) in
                    self.busesData = data
                    //finally load table with buses data
                    self.busesData = self.busesData.filter({bus in
                            return bus.time != "-"
                    })
                    
                    self.busesData.sort(by: {(bus1, bus2) in
                        return Int(bus1.time)! < Int(bus2.time)!
                    })
                    
                    self.busesTable.reloadData()
                    
                })
            })
        })
        self.tableRefresher.endRefreshing()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        self.session = WCSession.default
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        self.session.activate()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        DispatchQueue.main.async {
            self.userCoordinates = locations[0].coordinate
            let latitude = String(self.userCoordinates!.latitude)
            let longitude = String(self.userCoordinates!.longitude)
            let location  = ["lat": latitude, "long": longitude]
            
            //sending location to apple watch
            self.session.sendMessage(location, replyHandler: nil, errorHandler: { error in
                print(error.localizedDescription)
            })
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.busesTable.dequeueReusableCell(withIdentifier: "busInfoCell") as? busInfoCell{
            cell.initRow(busInfo: self.busesData[indexPath.row])
            return cell
        }
        
        return busInfoCell()
    }


    
}



