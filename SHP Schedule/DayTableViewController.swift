//
//  DayTableViewController.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 7/5/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class DayTableViewController: UITableViewController,UISplitViewControllerDelegate, SchoolScheduleDelegate {
    
    var schoolSchedule = SchoolSchedule()
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var dayForView:Date? {
        didSet {
            self.title = dayForView?.toString(withFormat:"E, MMMM d")
            self.tableView.reloadData()
        }
    }
    
    func segmentedControlChanged(_ sender:UISegmentedControl) {
        let monthCollectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "Month") as! MonthCollectionViewController
        sender.selectedSegmentIndex=0
        monthCollectionViewController.monthForView = dayForView
        self.navigationController?.pushViewController(monthCollectionViewController, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schoolSchedule.delegate = self
        
        //self.dayForView = "10-12-2017".toDate()!
        self.dayForView = Date()
        
        spinner.center = self.tableView.center
        self.view.addSubview(spinner)
        spinner.bringSubview(toFront: self.view)
        splitViewController?.delegate = self

        // KMO, this is what you changed
        /* NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        */
        
    }
    
    func startScheduleDownload() {
        spinner.startAnimating()
    }
    
    func endScheduleDownload() {
        self.tableView.reloadData()
        spinner.stopAnimating()
    }
    
    // KMO, this is what you added
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if (self.view.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact) {

            let weekCollectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "Week") as! WeekCollectionViewController
            weekCollectionViewController.weekForView = dayForView
            self.navigationController?.pushViewController(weekCollectionViewController, animated: true)
        }

    }
    
    // KMO, this is what you changed

    /*
    func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            let weekCollectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "Week") as! WeekCollectionViewController
            weekCollectionViewController.weekForView = dayForView
            self.navigationController?.pushViewController(weekCollectionViewController, animated: true)
            
        } else if orientation == .portrait || orientation == .portraitUpsideDown {
            // do nothing
        } else {
        }
        
    }
    */
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    private var beginsWithZPeriod:Bool {
        get { return scheduleArrayForDay?[0][0]=="Z" }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (beginsWithZPeriod) {
            return (scheduleArrayForDay?.count)!-1
        }
        else {
            return scheduleArrayForDay?.count ?? 0
        }
    }
    
    private var scheduleArrayForDay:Array<[String]>? {
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayTableCell", for: indexPath)
        let row = beginsWithZPeriod ? indexPath.row+1 : indexPath.row
        let scheduleArray = scheduleArrayForDay
        let period = scheduleArray?[row][0]
        cell.textLabel?.text = period
        
        if let personalClass = schoolSchedule.personalSchedule?[period!] {
            if personalClass.characters.count>0 {
                //print("\(period)...\(personalClass)")
                cell.textLabel?.text = period! + " (" + personalClass + ")"
            }
        }
        let startTimeMil = scheduleArray?[row][1]
        let endTimeMil = scheduleArray?[row][2]
        
        let startTime = startTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
        let endTime = endTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
        cell.detailTextLabel?.text = startTime + " to " + endTime
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dayAsText = (dayForView?.toDateString())!
        return schoolSchedule.dayScheduleDictionary?[dayAsText]?[0] ?? ""
    }
    
    private let oneDay = 24*60*60
    
    
    @IBAction func goBackOneDay(_ sender: Any?) {
        dayForView = dayForView?.addingTimeInterval(TimeInterval(-oneDay))
    }
    
    @IBAction func goForwardOneDay(_ sender: Any?) {
        dayForView = dayForView?.addingTimeInterval(TimeInterval(oneDay))
        
    }
    
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem) {
        dayForView = Date()
    }
    
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contentViewController == self {
            if (secondaryViewController.contentViewController is MonthCollectionViewController) {
                
                let segmentControl = UISegmentedControl(items: ["Day","Month"]);
                segmentControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
                segmentControl.tintColor = UIColor.schoolColor
                segmentControl.selectedSegmentIndex = 0
                let segmentedControlButtonItem = UIBarButtonItem(customView: segmentControl);
                self.toolbarItems?.insert(segmentedControlButtonItem, at: 2);
                
                return true
            }
        }
        return false
    }
 
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showSettings" {
            let settingsViewController = segue.destination.contentViewController as! SettingsViewController
            settingsViewController.schoolSchedule = self.schoolSchedule
            settingsViewController.periods = ["A", "B", "C", "D", "E", "F", "G", "X", "Y", "Z"]
        }
        
    }
    
    
}
