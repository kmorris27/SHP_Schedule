//
//  WidgetPeriodTableViewCell.swift
//  SHP Schedule
//
//  Created by Isabella Rhyu on 8/7/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class WidgetPeriodTableViewCell: UITableViewCell {
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var timingLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
