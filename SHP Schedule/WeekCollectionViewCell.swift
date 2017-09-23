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
    
    private var beginsWithZPeriod:Bool {
        get { return scheduleArrayForDay?[0][0]=="Z" }
    }
    
    //MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array = scheduleArrayForDay
        let count = array?.count ?? 0
        if (beginsWithZPeriod) {
            return count + 1
        }
        else {
            return count + 2

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: - Make this more efficient
        //DONE: - Alternating white and grey
        //DONE: - "timing label" should be personal schedule class
        if indexPath.row == 0 {
             let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! DateTableViewCell
            cell.dateLabel.text = dayForView!.toString(withFormat: "EEE d")
            if dayForViewIsToday
            {
                cell.dateLabel.textColor = UIColor.schoolColor
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleNameCell") as! ScheduleNameTableViewCell
            
            cell.scheduleNameLabel.text = scheduleForDay ?? ""
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        } else {
            let index = beginsWithZPeriod ? indexPath.row-1 : indexPath.row-2
             let cell = tableView.dequeueReusableCell(withIdentifier: "periodDetailCell") as! PeriodDetailTableViewCell
            let period = scheduleArrayForDay?[index][0]
            cell.periodLabel.text = period
            if let personalClass = schoolSchedule.personalSchedule?[period!] {
                if personalClass.characters.count>0 {
                    //print("\(period)...\(personalClass)")
                    cell.periodLabel?.text = period! + " (" + personalClass + ")"
                }
            }
            //Set detailTextLabel.text
            let startTimeMil = scheduleArrayForDay?[index][1]
            //let endTimeMil = scheduleArrayForDay?[index][2]
            
            let startTime = startTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
            //let endTime = endTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
            cell.timeLabel.text = startTime // + " to " + endTime
            if (index%2==0) {
                cell.backgroundColor = UIColor.lightGray
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell

        }
       
        

    }
}
