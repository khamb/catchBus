//
//  ViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/25/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
 
    var locationManager = CLLocationManager()
    let locationAuthorization = CLLocationManager.authorizationStatus()
    var userCoordinates: CLLocationCoordinate2D!
    var closestStopCoordinates: CLLocationCoordinate2D!
    
    let noBusLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
    let loadingAlert = UIAlertController(title: "Loading", message: nil, preferredStyle: .alert)
    
    @IBOutlet weak var centerMapOnUserLocationBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var busesTable: UITableView!
    var busesData = [BusInfo]()
    var tableRefresher:UIRefreshControl = UIRefreshControl()
    var stop = Stop(stopNo: 0, stopName: "")
    static var allStops = [Stop]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //***customize navigation bar
        navigationItem.titleView = UIImageView(image: UIImage(named: "busIcon")) //title icon

        //end of customize navigation bar ***
        self.locationManager.delegate = self
        self.userCoordinates = self.locationManager.location?.coordinate
        
        //init mapView
        self.configureMapView()
        self.centerOnUserLocation()
        self.centerMapOnUserLocationBtn.layer.cornerRadius = 0.5*self.centerMapOnUserLocationBtn.bounds.height
        self.centerMapOnUserLocationBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.centerMapOnUserLocationBtn.layer.shadowColor = UIColor.darkGray.cgColor
        self.centerMapOnUserLocationBtn.layer.shadowOpacity = 0.5
        
        // configure busesTable
        self.busesTable.dataSource = self
        self.busesTable.delegate = self
        //register cell
        self.busesTable.register(UINib(nibName: "busInfoCell", bundle: nil), forCellReuseIdentifier: "busInfoCellIdentifier")
        
        self.initTableRefresher()
        
        //populate stops array
        self.initAllStopsArray()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadTable(handler: { completed in
            if completed {
               // DispatchQueue.main.async{
                self.loadingAlert.dismiss(animated: true, completion: nil)
               // }
            }else{
                DispatchQueue.main.async {
                    self.setupNoBusLabel()
                }
            }
       })
        
        
    }

    
    @IBAction func onRefreshTapped(_ sender: Any) {
        self.centerOnUserLocation()
        self.locationManager.requestLocation()
        self.userCoordinates = self.locationManager.location?.coordinate
        self.loadTable(handler: { completed in
            if completed {
                DispatchQueue.main.async{
                    self.busesTable.reloadData()
                    self.loadingAlert.dismiss(animated: true, completion: nil)
                }
            }else{
                DispatchQueue.main.async {
                    self.setupNoBusLabel()
                }
            }
        })

    }
    
    private func initAllStopsArray(){
        let path = Bundle.main.url(forResource: "stops", withExtension: "json")
        guard let data = try? Data(contentsOf: path!) else {return}
        
        do {
            ViewController.allStops = try! JSONDecoder().decode([Stop].self, from: data)
        } catch {
            print("Error decoding stops array => \(error)")
        }
    }

    func loadTable(handler: @escaping (_ completed: Bool)->()){

        //first get closest stops' name45.415703,-75.668875
        self.present(self.loadingAlert, animated: true, completion:{
            DataService.instance.getStopName(location: self.userCoordinatesToString(), handler: { finished in
                self.closestStopCoordinates = DataService.instance.closestStopCoordinate
                DataService.instance.getStopNumber(handler: { completed in
                    DataService.instance.getBusInfoAtStop(stops: DataService.instance.closestStops, handler: { data in
                        
                        if !data.isEmpty{
                            self.busesData = data
                            let stop = DataService.instance.closestStops[0]
                            self.stop = stop
                            
                            DispatchQueue.main.async {
                                self.busesTable.reloadData()
                                self.getDirectionToClosestStop(stopCoordinate: self.closestStopCoordinates, stopName: stop.stopName)
                            }
                        
                            handler(true)
                        } else{
                            handler(false)
                        }

                    })
                })
            })
        })
        DataService.instance.reset()
        
    }
    
    @objc func refreshTable(){
        self.loadTable(handler: { complete in
            DispatchQueue.main.async {
                self.busesTable.reloadData()
                self.tableRefresher.endRefreshing()
                self.loadingAlert.dismiss(animated: true, completion: nil)
                
            }
        })
    }
    
    func setupNoBusLabel(){
        self.noBusLabel.text = "❌ No bus Available at this stop right now❗️"
        self.noBusLabel.textAlignment = .center
        self.noBusLabel.center.x = self.busesTable.center.x
        self.noBusLabel.center.y = self.busesTable.center.y-30
        self.busesTable.backgroundView = self.noBusLabel
    }
    
    func initTableRefresher(){
        self.busesTable.refreshControl = self.tableRefresher
        self.tableRefresher.addTarget(self, action: #selector(ViewController.self.refreshTable), for: UIControlEvents.valueChanged)
        self.tableRefresher.attributedTitle = NSAttributedString(string: "updating bus information ...")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.stop.stopName
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.busesData.isEmpty{
            tableView.backgroundView?.isHidden = false
        }else{
            tableView.backgroundView?.isHidden = true
        }
        return self.busesData.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = UIContextualAction(style: .normal, title: "") { (action, view, completed) in
            let favBus = FavBusInfo(busInfo: self.busesData[indexPath.row], stop: self.stop)
            
            if FavouriteBuses.instance.addToFavourites(favBus: favBus){
                let alert = UIAlertController(title: "✅", message: "SUCCESS!", preferredStyle: .alert)
                self.present(alert, animated: true, completion:{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })
                completed(true)
            } else {
                let alert = UIAlertController(title: "❌", message: "ALREADY IN YOUR FAVOURITES!", preferredStyle: .alert)
                self.present(alert, animated: true, completion:{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.75, execute: {
                        alert.dismiss(animated: true, completion: nil)
                    })
                })

                completed(true)
            }
        }
        favorite.image = UIImage(named: "fav")
        return UISwipeActionsConfiguration(actions: [favorite])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Bundle.main.loadNibNamed("busInfoCell", owner: self, options: nil)?.first as? busInfoCell else {return UITableViewCell()}
        cell.initRow(busInfo: self.busesData[indexPath.row])
        return cell
    }
}

extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userCoordinates = locations[0].coordinate
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        print(error)
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
        self.centerOnUserLocation()
    }
}

extension ViewController: MKMapViewDelegate{
    
    func configureMapView(){
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.showsBuildings = true
        self.mapView.userTrackingMode = .followWithHeading
    }
    
    func centerOnUserLocation(){
        if let location = self.locationManager.location?.coordinate{
            let region = MKCoordinateRegionMakeWithDistance(location, 800, 800)
            mapView.setRegion(region, animated: true)
        }
    }
    
    /*
     show direction to stop
     
     create direction request DR
     choose DR source (mkplacemark)
     choose DR destination
     get direction mkdirection
     */
    func getDirectionToClosestStop(stopCoordinate: CLLocationCoordinate2D, stopName: String){
        self.removeAllAnnotationsAndOvarlays()
        
        let request = MKDirectionsRequest()
        
        //Droping a pin at closest bus stop
        let stopAnnotation = MKPointAnnotation()
        stopAnnotation.coordinate = stopCoordinate
        stopAnnotation.title = stopName
        self.mapView.addAnnotation(stopAnnotation)
        
        let source = MKMapItem(placemark: MKPlacemark(coordinate: self.userCoordinates))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: stopCoordinate))
        
        request.source = source
        request.destination = destination
        request.transportType = .walking
        
        
        let directions = MKDirections(request: request)
        
        directions.calculate(completionHandler: { (response, error) in
            if error == nil{
                let route = response?.routes[0]
                self.mapView.add((route?.polyline)!, level: MKOverlayLevel.aboveRoads)
                
                let routeRegion = MKCoordinateRegionForMapRect((route?.polyline.boundingMapRect)!)
                self.mapView.setRegion(routeRegion, animated: true)
            }
        })
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 5
        renderer.lineCap = .round
        return renderer
    }
    
    func removeAllAnnotationsAndOvarlays(){
        if !self.mapView.annotations.isEmpty{
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
        }
    }
    
}


