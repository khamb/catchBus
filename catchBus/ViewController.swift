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
    let rightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 20))
    
    var locationManager = CLLocationManager()
    var session: WCSession!
    var userCoordinates: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.busesTable.dataSource = self
        self.busesTable.delegate = self
        
        //init navigation bar
        navigationItem.titleView = UIImageView(image: UIImage(named: "busIcon"))
        let locIconImageView = UIImageView(image: UIImage(named: "locIcon"))
        rightLabel.textColor = UIColor.white
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel), UIBarButtonItem(customView: locIconImageView)]
        
        
        
        
        DispatchQueue.main.async {
            //activate watch connectivity if the device support it
            if (WCSession.isSupported()) {
                self.session = WCSession.default
                self.session.delegate = self
                self.session.activate()
            }
            
            //set up location service
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
            self.userCoordinates = self.locationManager.location?.coordinate

            self.loadTable()
        }
        
        self.initTableRefresher()

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
            
            self.session.sendMessage(["loc": self.userCoordinates], replyHandler: nil, errorHandler: nil)
            
            //then get its stop number
            DataService.instance.getStopNumber(withStopName: closest, handler: { stopCode in
                self.rightLabel.text = closest
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
                    self.busesTable.reloadData()
                    
                })
            })
        })
        
        self.tableRefresher.endRefreshing()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error != nil{
            print(error?.localizedDescription)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        self.session.activate()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        self.session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
       
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            self.userCoordinates = locations[0].coordinate
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



