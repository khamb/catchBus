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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    /* In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let mainViewController = segue.destination as? ViewController{
            mainViewController.locationAuthorization = self.locationAuthorization
        }
    }*/


}
