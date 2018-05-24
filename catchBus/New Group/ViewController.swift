//
//  ViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 3/25/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit
import WatchConnectivity
import MapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
 
    var locationManager = CLLocationManager()
    let locationAuthorization = CLLocationManager.authorizationStatus()
    var userCoordinates: CLLocationCoordinate2D!
    
    let rightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 20))
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var busesTable: UITableView!
    var busesData = [BusInfo]()
    var tableRefresher:UIRefreshControl = UIRefreshControl()
    static var stopCode = ""
    var session: WCSession!
    
    @IBOutlet weak var tableActivityViewIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //***customize navigation bar
        navigationItem.titleView = UIImageView(image: UIImage(named: "busIcon")) //title icon
        
        //adding right bar item
        let locIconImageView = UIImageView(image: UIImage(named: "locIcon"))
        rightLabel.textColor = UIColor.white
        rightLabel.adjustsFontSizeToFitWidth = true
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel), UIBarButtonItem(customView: locIconImageView)]
        //end of customize navigation bar ***
        
        self.locationManager.delegate = self
        self.initLocationServices()
        self.userCoordinates = self.locationManager.location?.coordinate
        
        //init mapView
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.centerOnUserLocation()
        
        // configure busesTable
        self.busesTable.dataSource = self
        self.busesTable.delegate = self
        //register cell
        self.busesTable.register(UINib(nibName: "busInfoCell", bundle: nil), forCellReuseIdentifier: "busInfoCellIdentifier")
        
        self.initTableRefresher()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ssss")
        self.tableActivityViewIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.loadTable(handler: { completed, closestStop in
            DispatchQueue.main.async{
                //update stop name on
                self.rightLabel.text = closestStop
                
                //reloading buses table
                self.busesTable.reloadData()
                self.tableActivityViewIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        })
        

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

    @IBAction func centerBtnPressed(_ sender: Any) {
        if self.locationAuthorization == .authorizedAlways || self.locationAuthorization == .authorizedWhenInUse{
            self.centerOnUserLocation()
        }
    }

    func loadTable(handler: @escaping (_ completed: Bool,_ closest: String)->()){
        //first get closest stops' name
        DataService.instance.getStopName(location: self.userCoordinatesToString(), handler: { closest in
            DataService.instance.getStopNumber(withStopName: closest, handler: { stopCode in
                //after that get bus infos from that stop
                ViewController.stopCode = stopCode
                DataService.instance.getBusInfos(stopCode: stopCode, handler: { (data) in
                    self.busesData = data
                    handler(true,closest)
                })
            })
        })
    }
    
    @objc func refreshTable(){
        self.loadTable(handler: { complete, closest in
            DispatchQueue.main.async {
                self.busesTable.reloadData()
                self.tableRefresher.endRefreshing()
            }
        })
    }
    
    func initTableRefresher(){
        self.busesTable.refreshControl = self.tableRefresher
        self.tableRefresher.addTarget(self, action: #selector(ViewController.self.refreshTable), for: UIControlEvents.valueChanged)
        self.tableRefresher.attributedTitle = NSAttributedString(string: "updating bus informations ...")
       // self.tableRefresher.endRefreshing()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busesData.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = UIContextualAction(style: .normal, title: "") { (action, view, completed) in
            
            if FavouriteBuses.instance.addToFavourites(bus: self.busesData[indexPath.row], stopCode: ViewController.stopCode){
                let alert = UIAlertController(title: "Add to favourites", message: "✅ SUCCESS!", preferredStyle: .alert)
                self.present(alert, animated: true, completion: {
                    alert.dismiss(animated: true, completion: nil)
                })
                completed(true)
            } else {
                let alert = UIAlertController(title: "Add to favourites", message: "❌ ALREADY IN FAVOURITES!", preferredStyle: .alert)
                self.present(alert, animated: true, completion: {
                    alert.dismiss(animated: true, completion: nil)
                })
                completed(true)
            }
        }
        favorite.image = UIImage(named: "fav")
        return UISwipeActionsConfiguration(actions: [favorite])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = busesTable.dequeueReusableCell(withIdentifier: "busInfoCellIdentifier") as? busInfoCell else {return UITableViewCell()}
        cell.initRow(busInfo: self.busesData[indexPath.row])
        return cell
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


