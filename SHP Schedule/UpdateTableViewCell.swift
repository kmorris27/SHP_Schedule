//
//  UpdateTableViewCell.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 7/5/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class UpdateTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var lastUpdatedDateLabel: UILabel!
    
    @IBAction func updateButtonPressed(_ sender: Any) {
    }
    
    var lastUpdated:String?
    {
        get {return self.lastUpdatedDateLabel.text}
        set {self.lastUpdatedDateLabel.text = newValue }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
