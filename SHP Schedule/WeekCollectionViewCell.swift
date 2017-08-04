//
//  WeekCollectionViewCell.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 7/13/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class WeekCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    //MARK: - Variables
    
    var schoolSchedule = SchoolSchedule()
    var dayForView: Date?
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Methods

     var scheduleArrayForDay:Array<[String]>?
    {
        get {
            let dayAsText = (dayForView?.toDateString())!
            if let whichSchedule = schoolSchedule.dayScheduleDictionary?[dayAsText]?[0] {
                let periodDictionary = schoolSchedule.schedulePeriodDictionary
                if let arrayOfPeriodsForDay = periodDictionary?[whichSchedule] {                return arrayOfPeriodsForDay
                }
            }
            return nil
        }
    }
    
    private var scheduleForDay:String?
    {
        get {
            let dayAsText = (dayForView?.toDateString())!
            if let whichSchedule = schoolSchedule.dayScheduleDictionary?[dayAsText]?[0] {
                return whichSchedule
            }
            return nil
        }
    }

    //Evan added the following variable
    var dayForViewIsToday: Bool {
        return dayForView?.toDateString() == Date().toDateString()
    }
    
    //MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = scheduleArrayForDay
        let count = array?.count ?? 0
        return count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekTableViewCell", for: indexPath)
        if indexPath.row==0 {
            cell.textLabel?.text = dayForView?.toString(withFormat: "EEE d")
            // Evan added the lines inbetween the comments
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            
            if dayForViewIsToday { cell.textLabel?.textColor = UIColor.red}
            else { cell.textLabel?.textColor = UIColor.black }
            // Evan added the lines inbetween the comments
        } else if indexPath.row==1 {
            cell.textLabel?.text = scheduleForDay
            // Evan added the lines inbetween the comments
            cell.textLabel?.font = nil
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            if scheduleForDay != nil && (cell.textLabel?.text?.characters.count)! > 20
            {
                cell.textLabel?.adjustsFontSizeToFitWidth = false
                cell.textLabel?.font = cell.textLabel?.font.withSize(10)
            }
            
            if dayForViewIsToday { cell.textLabel?.textColor = UIColor.shpRedColor }
            else { cell.textLabel?.textColor = UIColor.black }
            
            // Evan added the lines inbetween the comments
            
        }
        else {
            if let period = scheduleArrayForDay?[indexPath.row-2][0] {
                cell.textLabel?.text = period
            }
        }
        return cell
    }
}
