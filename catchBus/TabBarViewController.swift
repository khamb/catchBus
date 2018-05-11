//
//  TabBarViewController.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/10/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit
import CoreLocation

class TabBarViewController: UITabBarController, CLLocationManagerDelegate{
    
    static var locationManager = CLLocationManager()
    static let locationAuthorization = CLLocationManager.authorizationStatus()
    static var userCoordinates: CLLocationCoordinate2D!
    
    let rightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 20))
    
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
        
        TabBarViewController.locationManager.delegate = self
        self.initLocationServices()
        TabBarViewController.userCoordinates = TabBarViewController.locationManager.location?.coordinate
       
        DataService.instance.getStopName(location: TabBarViewController.userCoordinatesToString(), handler: { closest in
            //then get its stop number
             self.rightLabel.text = closest
        })
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initLocationServices(){
        if TabBarViewController.locationAuthorization == .notDetermined{
            TabBarViewController.locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    static func userCoordinatesToString()->String{
        var latitude = Double(TabBarViewController.userCoordinates.latitude)
        latitude = floor(pow(10.0, 6) * latitude)/pow(10.0, 6)
        var longitude = Double(TabBarViewController.userCoordinates.longitude)
        longitude = floor(pow(10.0, 6) * longitude)/pow(10.0, 6)
        let toString = String(latitude)+","+String(longitude)
        return toString
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
