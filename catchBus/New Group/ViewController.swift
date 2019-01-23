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

class ViewController: UIViewController {
 

    @IBOutlet weak var centerMapOnUserLocationBtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var routesTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var locationManager = CLLocationManager()
    let locationAuthorization = CLLocationManager.authorizationStatus()
    var userCoordinates: CLLocationCoordinate2D!
    var closestStopCoordinates: CLLocationCoordinate2D!
    var stop = Stop(geometry: nil, code: 0, name: "")
    private var routes: [Route] = [Route]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "busIcon"))

        self.locationManager.delegate = self
        self.userCoordinates = self.locationManager.location?.coordinate
        
        self.configureMapView()
        
        routesTableView.dataSource = self
        routesTableView.delegate = self
        routesTableView.register(UINib(nibName: "RouteCell", bundle: nil), forCellReuseIdentifier: "RouteCell")
        
        
        populateRoutesTableView()
    }

    private func populateRoutesTableView(){
        //first get closest stops' name45.415703,-75.668875
        activityIndicator.startAnimating()
        DataService.instance.getClosestStopName(at: "45.415703,-75.668875") { completed in
            guard completed else { return }
            
            DataService.instance.getRoutes(at: DataService.instance.closestStops, handler: { routes in
                self.routes = routes
                DispatchQueue.main.async {
                    self.routesTableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicatorView.isHidden = true
                }
            })
        }
    }

}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DataService.instance.closestStopName
    }
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath) as? RouteCell else { return UITableViewCell() }
        cell.update(route: routes[indexPath.row])
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

extension ViewController: MKMapViewDelegate {
    
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


