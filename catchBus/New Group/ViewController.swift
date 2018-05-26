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
    
    let rightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var busesTable: UITableView!
    var busesData = [BusInfo]()
    var tableRefresher:UIRefreshControl = UIRefreshControl()
    var stop = Stop(stopNo: "", stopName: "")
    var session: WCSession!
    
    @IBOutlet weak var tableActivityViewIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //***customize navigation bar
        navigationItem.titleView = UIImageView(image: UIImage(named: "busIcon")) //title icon
        
        //adding right bar item
        rightLabel.textColor = UIColor.white
        rightLabel.adjustsFontForContentSizeCategory = true
        rightLabel.textAlignment = .right
        rightLabel.adjustsFontSizeToFitWidth = true
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel)]
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

        self.tableActivityViewIndicator.startAnimating()
        self.loadTable(handler: { completed, closestStop in
            DispatchQueue.main.async{
   
                //update stop name on
                self.stop = closestStop
                self.rightLabel.text = "🚏"+closestStop.stopName
                
                self.busesTable.reloadData() //reloading buses table
                self.tableActivityViewIndicator.stopAnimating()

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

    func loadTable(handler: @escaping (_ completed: Bool,_ closest: Stop)->()){
        UIApplication.shared.beginIgnoringInteractionEvents()
        //first get closest stops' name45.422923, -75.681740
        DataService.instance.getStopName(location: "45.419849,-75.678814", handler: { finished in
            
            DataService.instance.getStopNumber(handler: { completed in
                DataService.instance.getBusInfos(handler: { (data, stop) in
                    self.busesData = data
                    handler(true,stop)
                })
            })
            
        })
        UIApplication.shared.endIgnoringInteractionEvents()
        DataService.instance.reset()
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
        self.tableRefresher.attributedTitle = NSAttributedString(string: "updating bus information ...")
       // self.tableRefresher.endRefreshing()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busesData.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = UIContextualAction(style: .normal, title: "") { (action, view, completed) in
            let favBus = FavBusInfo(busInfo: self.busesData[indexPath.row], stop: self.stop)
            
            if FavouriteBuses.instance.addToFavourites(favBus: favBus){
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


