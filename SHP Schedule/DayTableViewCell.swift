//
//  DayTableViewCell.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 9/26/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell {

    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
