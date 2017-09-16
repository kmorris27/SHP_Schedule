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
    
    @IBAction func periodTextFieldEditingFinished(_ sender: Any) {
        editingPeriodEnded()
    }
    
    var schoolSchedule:SchoolSchedule? = SchoolSchedule()
    
    func editingPeriodEnded() {
        if periodTextField != nil {
        var dict = schoolSchedule?.personalSchedule ?? Dictionary<String,String>()
        dict[periodLabel.text!] = periodTextField.text
        schoolSchedule?.personalSchedule = dict
        }
    }
    
    func updateUI(for period: String, withPersonalClass className: String?) {
        periodLabel.text = period
        periodTextField.text = schoolSchedule?.personalSchedule?[period]
    }

}
