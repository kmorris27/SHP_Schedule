//
//  TodayViewController.swift
//  Today's SHP Schedule
//
//  Created by Isabella Rhyu on 8/7/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Variables
    @IBOutlet weak var tableView: UITableView!
    let defaults = UserDefaults(suiteName: "group.org.shschools.shpschedule.todayextension")!
    
    var schoolSchedule = SchoolSchedule()
    let dayForView = Date()
    var isShowingLess:Bool {
        get {
            return self.extensionContext?.widgetActiveDisplayMode == NCWidgetDisplayMode.compact
        }
    }
    
    private var scheduleArrayForDay:Array<[String]>? {
        get {
            
            let dayAsText = dayForView.toDateString()
            if let whichSchedule = schoolSchedule.dayScheduleDictionary?[dayAsText]?[0] {
                let periodDictionary = schoolSchedule.schedulePeriodDictionary
                if let arrayOfPeriodsForDay = periodDictionary?[whichSchedule] {
                    return arrayOfPeriodsForDay
                }
            }
            return nil
        }
    }
    
    
    private var shouldHideBeginningZPeriod:Bool {
        get {
            if scheduleArrayForDay?[0][0]=="Z" {
                if let zClass =  schoolSchedule.personalSchedule?["Z"] {
                    if zClass.characters.count > 0 {
                        return false
                    }
                }
            }
            return true
        }
    }
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view from its nib.
    }
    
    func periodsForSchedule(_ schedule:String) -> String
    {
        var result = ""
        let validPeriods = "ABCDEFG"
        let dict = schoolSchedule.schedulePeriodDictionary
        if let periodArray = dict?[schedule] {
            for periodInfo in periodArray {
                let period = periodInfo[0]
                if validPeriods.contains(period) {
                    result += period
                }
            }
        }
        return result
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updatePreferredContentSize() {
        self.preferredContentSize = CGSize(width: CGFloat(0), height: CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * CGFloat(tableView.rowHeight) + tableView.sectionFooterHeight)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
        }
        else {
            //expanded
            self.preferredContentSize = CGSize(width: CGFloat(0), height: CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * CGFloat(tableView.rowHeight) + tableView.sectionHeaderHeight)
            //self.preferredContentSize = CGSize(width: maxSize.width, height: 200)
        }
        tableView.reloadData()
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let dayAsText = dayForView.toDateString()
        return schoolSchedule.dayScheduleDictionary?[dayAsText]?[0] ?? "No classes today"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowingLess == true {
            return 1
        }
        else {
            var result = scheduleArrayForDay?.count ?? 0
            
            if (shouldHideBeginningZPeriod) {
                result -= 1
            }
            return result
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowingLess {
            let cell = tableView.dequeueReusableCell(withIdentifier: "widgetAllPeriods", for: indexPath) as! WidgetAllPeriodsTableViewCell
            let dayAsText = dayForView.toDateString()
            let schedule = schoolSchedule.dayScheduleDictionary?[dayAsText]?[0] ?? ""
            let allPeriods = periodsForSchedule(schedule)
            cell.allPeriodsLabel.text = allPeriods
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "widgetOnePeriod", for: indexPath) as! WidgetPeriodTableViewCell
            let row = shouldHideBeginningZPeriod ? indexPath.row+1 : indexPath.row
            let period = scheduleArrayForDay?[row][0]
            cell.periodLabel.text = period
            
            if let personalClass = schoolSchedule.personalSchedule?[period!] {
                if personalClass.characters.count>0 {
                    cell.periodLabel?.text = period! + " (" + personalClass + ")"
                }
            }
            
            let startTimeMil = scheduleArrayForDay?[row][1]
            let endTimeMil = scheduleArrayForDay?[row][2]
            let startTime = startTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
            let endTime = endTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
            cell.timingLabel.text = startTime + " to " + endTime
            return cell

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isShowingLess {
            return self.tableView.bounds.height - tableView.sectionHeaderHeight
        }
        else {
            return self.tableView.rowHeight
        }
    }
    
}

