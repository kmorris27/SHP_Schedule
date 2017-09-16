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

    private var scheduleArrayForDay: Array<[String]>? {
        get {
            //Only works when school is in session, therefore use test date in development
            let todayString = Date().toDateString()
            //Mimicks "SchoolSchedule" functionality
            if let dayScheduleDict = defaults.object(forKey: "shp_schedule_day_schedule_key") {
                let dictFromDefaults = dayScheduleDict as! [String: Array<String>]
                //whichSchedule
                //08-10-2017
                let todaySchedule = dictFromDefaults[todayString]?[0]
                //periodDictionary
                if let periodDict = defaults.object(forKey: "shp_schedule_schedule_period_key") {
                    let periodDictFromDefaults = periodDict as! [String: Array<[String]>]
                    if let arrayOfPeriodsForDay = periodDictFromDefaults[todaySchedule!] {
                        return arrayOfPeriodsForDay
                    }
                    
                }
            }
            return nil
        }
    }
    
    private var beginsWithZPeriod:Bool {
        get { return scheduleArrayForDay?[0][0]=="Z" }
    }
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize
            tableView.reloadData()
        }
        else {
            //expanded
            self.preferredContentSize = CGSize(width: maxSize.width, height: 200)
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Add Z period implementation
        return scheduleArrayForDay!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WidgetPeriodTableViewCell
        let row = indexPath.row
        let period = scheduleArrayForDay?[row][0]
        cell.periodLabel.text = period
        
        let startTimeMil = scheduleArrayForDay?[row][1]
        let endTimeMil = scheduleArrayForDay?[row][2]
        let startTime = startTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
        let endTime = endTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
        cell.timingLabel.text = startTime + " to " + endTime
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //preferred content size / number of periods in a day
        return 200 / CGFloat(scheduleArrayForDay!.count)
    }
    
    

    
}

//Extensions are not shared between widget and project
extension Date {
    func toString(withFormat format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func toDateString() -> String {
        return self.toString(withFormat: "M-dd-yyyy")
    }
}

extension String {
    func toDate(withFormat format:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
    }
    
    func toTime() -> Date? {
        return self.toDate(withFormat: "k:mm")
    }
}
