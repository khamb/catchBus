//
//  StopPin.swift
//  catchBus
//
//  Created by Khadim Mbaye on 4/21/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import Foundation
import MapKit

class StopPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
