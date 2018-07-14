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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initCell(stop: Stop){
        let text = stop.stopName.lowercased().capitalized
        self.stopLabel.text = text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
