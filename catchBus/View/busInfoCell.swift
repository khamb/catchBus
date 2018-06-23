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
    @IBOutlet weak var shadowView: UIView!
    
    override func awakeFromNib() {
        // Initialization code
       /* super.awakeFromNib()
        self.shadowView.layer.cornerRadius = 4
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.shadowView.layer.shadowColor = UIColor.darkGray.cgColor
        self.shadowView.layer.shadowOpacity = 0.5*/

    }
    
    func initRow(busInfo: BusInfo){
        busNoLabel.text = busInfo.no
        headingLabel.text = busInfo.routeHeading
        timeLabel.text = busInfo.time
    }
    

}
