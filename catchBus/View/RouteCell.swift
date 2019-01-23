//
//  RouteCell.swift
//  catchBus
//
//  Created by Khadim Mbaye on 1/18/19.
//  Copyright © 2019 Khadim Mbaye. All rights reserved.
//

import UIKit

class RouteCell: UITableViewCell {

    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var adjustedTimeLabel: UILabel!
    
    func update(route: Route) {
        noLabel.text = String(describing: route.no)
        headingLabel.text = route.heading
        
        guard let trips = route.trips else {
            adjustedTimeLabel.text = "-"
            return
        }
        adjustedTimeLabel.text = trips.first?.adjustedScheduleTime ?? "-"
    }

}
