//
//  busInfoCell.swift
//  catchBus
//
//  Created by Khadim Mbaye on 4/8/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit

class busInfoCell: UITableViewCell {

    @IBOutlet weak var busNoLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initRow(busInfo: BusInfo){
        busNoLabel.text = busInfo.no
        headingLabel.text = busInfo.routeHeading
        timeLabel.text = busInfo.time
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
