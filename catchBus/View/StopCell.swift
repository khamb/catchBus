//
//  StopCell.swift
//  catchBus
//
//  Created by Khadim Mbaye on 5/26/18.
//  Copyright © 2018 Khadim Mbaye. All rights reserved.
//

import UIKit

class StopCell: UITableViewCell {

    @IBOutlet weak var stopLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initCell(stop: Stop){
        self.stopLabel.text = stop.stopName.lowercased().capitalized
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
