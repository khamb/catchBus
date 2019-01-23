//
//  StopCell.swift
//  catchBus
//
//  Created by Khadim Mbaye on 6/8/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit

class StopCell: UITableViewCell {

    @IBOutlet weak var stopLabel: UILabel!

    
    func initCell(stop: Stop){
        self.stopLabel.text = stop.name.lowercased().capitalized
    }
    

}
