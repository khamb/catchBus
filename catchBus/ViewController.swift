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
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
 
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var busesTable: UITableView!
    var busesData = [BusInfo]()
    var tableRefresher:UIRefreshControl = UIRefreshControl()
    let rightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 20))
    
    var session: WCSession!
    
    var locationManager = CLLocationManager()
    let locationAuthorization = CLLocationManager.authorizationStatus()
    var userCoordinates: CLLocationCoordinate2D!

    @IBOutlet weak var tableActivityViewIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init mapView
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.centerOnUserLocation()
        
        //init location services
        self.locationManager.delegate = self
        self.initLocationServices()
        self.userCoordinates = self.locationManager.location?.coordinate
        
        // Do any additional setup after loading the view, typically from a nib.
        self.busesTable.dataSource = self
        self.busesTable.delegate = self
        
        //init navigation bar
        navigationItem.titleView = UIImageView(image: UIImage(named: "busIcon"))
        let locIconImageView = UIImageView(image: UIImage(named: "locIcon"))
        rightLabel.textColor = UIColor.white
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel), UIBarButtonItem(customView: locIconImageView)]
        
        self.tableActivityViewIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: { //just to simulate a delay
            self.loadTable()
            self.tableActivityViewIndicator.stopAnimating()
        })
        UIApplication.shared.endIgnoringInteractionEvents()
        
        
        self.initTableRefresher()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func centerBtnPressed(_ sender: Any) {
        if self.locationAuthorization == .authorizedAlways || self.locationAuthorization == .authorizedWhenInUse{
            self.centerOnUserLocation()
            self.loadTable()
        }
    }
    
    func initLocationServices(){
        if self.locationAuthorization == .notDetermined{
            self.locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    
    func userCoordinatesToString()->String{
        var latitude = Double(self.userCoordinates.latitude)
        latitude = floor(pow(10.0, 6) * latitude)/pow(10.0, 6)
        var longitude = Double(self.userCoordinates.longitude)
        longitude = floor(pow(10.0, 6) * longitude)/pow(10.0, 6)
        let toString = String(latitude)+","+String(longitude)
        return toString
    }
    
    @objc func loadTable(){

        
        //first get closest stops' name
        DataService.instance.getStopName(location: self.userCoordinatesToString(), handler: { closest in
            //then get its stop number
            self.rightLabel.adjustsFontSizeToFitWidth = true
            self.rightLabel.text = closest
        
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
                    self.busesTable.reloadData()
                    
                })
            })
        })
        
        self.tableRefresher.endRefreshing()

    }
    
    func initTableRefresher(){
        self.busesTable.refreshControl = self.tableRefresher
        self.tableRefresher.addTarget(self, action: #selector(ViewController.self.loadTable), for: UIControlEvents.valueChanged)
        self.tableRefresher.attributedTitle = NSAttributedString(string: "updating bus informations ...")
        
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = UIContextualAction(style: .normal, title: "Add to favorites") { (action, view, nil) in
        }
        favorite.image = UIImage(named: "fav")
        return UISwipeActionsConfiguration(actions: [favorite])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.busesTable.dequeueReusableCell(withIdentifier: "busInfoCell") as? busInfoCell{
            cell.initRow(busInfo: self.busesData[indexPath.row])
            return cell
        }
        
        return busInfoCell()
    }

    
}



extension ViewController:  WCSessionDelegate{
    
    func initWCSession(){
        //activate watch connectivity if the device support it
        if (WCSession.isSupported()) {
            self.session = WCSession.default
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
     
    }
    
    func sessionDidDeactivate(_ session: WCSession) {

    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
    }
}

extension ViewController: MKMapViewDelegate{
    
    func centerOnUserLocation(){
        if let location = self.locationManager.location?.coordinate{
            let region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)
            mapView.setRegion(region, animated: true)
        }
    }
}


