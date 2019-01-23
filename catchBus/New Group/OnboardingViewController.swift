//
//  OnboardingViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 7/12/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit
import CoreLocation

class OnboardingViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var activateGPSBtn: UIButton!
    

    var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        
        //styling activateGPSBtn
        self.activateGPSBtn.layer.cornerRadius = 5
        self.activateGPSBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.activateGPSBtn.layer.shadowOpacity = 0.5
        
        
    }
    
    @IBAction func onActivateGPSTapped(_ sender: UIButton) {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways{
            UserDefaults.standard.set(true, forKey: "isGPSActivated")
            UserDefaults.standard.synchronize()
            
            performSegue(withIdentifier: "TabBarControllerSegue", sender: self)
        }else{
            UserDefaults.standard.set(false, forKey: "isGPSActivated")
            UserDefaults.standard.synchronize()
        }
    }
}
