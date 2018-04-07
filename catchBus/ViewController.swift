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

class ViewController: UIViewController, CLLocationManagerDelegate, WCSessionDelegate {
    
    var locationManager = CLLocationManager()
    var session: WCSession!
    var userCoordinates: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

}



