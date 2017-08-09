//
//  PeriodTableViewCell.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 7/5/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class PeriodTableViewCell: UITableViewCell {

    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var periodTextField: UITextField!
    var schoolSchedule:SchoolSchedule? = SchoolSchedule()

    
    @IBAction func editingPeriodEnded() {
        var dict = schoolSchedule?.personalSchedule ?? Dictionary<String,String>()
        dict[periodLabel.text!] = periodTextField.text
        schoolSchedule?.personalSchedule = dict
    }
    
    
    func updateUI(for period: String, withPersonalClass className: String?) {
        periodLabel.text = period
        periodTextField.text = schoolSchedule?.personalSchedule?[period]
    }

   
}
