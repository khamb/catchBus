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

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
 
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var busesTable: UITableView!
    var busesData = [BusInfo]()
    var tableRefresher:UIRefreshControl = UIRefreshControl()
    
    var session: WCSession!
    
    @IBOutlet weak var tableActivityViewIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init mapView
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.centerOnUserLocation()
        
        // configure busesTable
        self.busesTable.dataSource = self
        self.busesTable.delegate = self
        
        //register cell
        self.busesTable.register(UINib(nibName: "busInfoCell", bundle: nil), forCellReuseIdentifier: "busInfoCellIdentifier")
        
        self.tableActivityViewIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.loadTable(handler: { completed in
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: { //just to simulate a delay
                self.busesTable.reloadData()
                self.tableActivityViewIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        })

        
        self.initTableRefresher()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func centerBtnPressed(_ sender: Any) {
        if TabBarViewController.locationAuthorization == .authorizedAlways || TabBarViewController.locationAuthorization == .authorizedWhenInUse{
            self.centerOnUserLocation()
            //self.loadTable()
        }
    }
    
    

    @objc func loadTable(handler: @escaping (_ completed: Bool)->()){
        //first get closest stops' name
        DataService.instance.getStopName(location: TabBarViewController.userCoordinatesToString(), handler: { closest in
            
            DataService.instance.getStopNumber(withStopName: closest, handler: { stopCode in
                //after that get bus infos from that stop
                DataService.instance.getBusInfos(stopCode: stopCode, handler: { (data) in
                    self.busesData = data
                    self.tableRefresher.endRefreshing()
                    handler(true)
                })
            })
        })
    }
    
    func initTableRefresher(){
        self.busesTable.refreshControl = self.tableRefresher
        self.tableRefresher.addTarget(self, action: #selector(ViewController.self.loadTable), for: UIControlEvents.valueChanged)
        self.tableRefresher.attributedTitle = NSAttributedString(string: "updating bus informations ...")
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busesData.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = UIContextualAction(style: .normal, title: "") { (action, view, completed) in
            
            if FavouriteBuses.instance.addToFavourites(bus: self.busesData[indexPath.row]){
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       
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
        if let location = TabBarViewController.locationManager.location?.coordinate{
            let region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)
            mapView.setRegion(region, animated: true)
        }
    }
}


