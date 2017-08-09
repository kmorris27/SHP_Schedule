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
        //TODO: - Make this more efficient
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! DateTableViewCell
            cell.dateLabel.text = dayForView!.toString(withFormat: "EEE d")
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleNameCell") as! ScheduleNameTableViewCell
            cell.scheduleNameLabel.text = scheduleForDay ?? "(no school)"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "periodDetailCell") as! PeriodDetailTableViewCell
            let period = scheduleArrayForDay?[indexPath.row - 2][0]
            cell.periodLabel.text = period
            //Set detailTextLabel.text
            let startTimeMil = scheduleArrayForDay?[indexPath.row - 2][1]
            let endTimeMil = scheduleArrayForDay?[indexPath.row - 2][2]
            
            let startTime = startTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
            let endTime = endTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
            cell.timeLabel.text = startTime + " to " + endTime
            
            return cell
        }
    }
}
