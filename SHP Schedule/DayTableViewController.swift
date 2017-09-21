//
//  DayTableViewController.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 7/5/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit
import Foundation

class DayTableViewController: UITableViewController,UISplitViewControllerDelegate, SchoolScheduleDelegate {
    
    var schoolSchedule = SchoolSchedule()
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    var timer: Timer?
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.tableView.reloadData()
            //print("Reloading TableView")
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
    }
    
    override var shouldAutorotate: Bool {
       return true
    }
    
    func addGestures() {

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(DayTableViewController.rightSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(DayTableViewController.leftSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)

    }

    func rightSwipeGesture() {
        if Calendar.current.component(.weekday, from: dayForView!) == 2
        {
            dayForView = dayForView?.addingTimeInterval(TimeInterval(-oneDay*3))
        }
        else
        {
            dayForView = dayForView?.addingTimeInterval(TimeInterval(-oneDay))
        }
    }
    
    func leftSwipeGesture() {
        dayForView = dayForView?.addingTimeInterval(TimeInterval(oneDay))
    }
 
    
    var dayForView:Date? {
        didSet {
            let dayOfWeek = Calendar.current.component(.weekday, from: dayForView!)
            if dayOfWeek == 7
            {
                dayForView?.addTimeInterval(TimeInterval(oneDay*2))
            }
            if dayOfWeek == 1
            {
                dayForView?.addTimeInterval(TimeInterval(oneDay))
            }
            
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
        splitViewController?.delegate = self
        schoolSchedule.delegate = self
        startTimer()
        addGestures()
        self.tableView.isScrollEnabled = false
        print("Day View Loaded")
        
        self.dayForView = Date()
        
        let segmentControl = UISegmentedControl(items: ["Day","Month"]);
        segmentControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        segmentControl.tintColor = UIColor.fromHex(rgbValue: 0x971927)
        segmentControl.selectedSegmentIndex = 0
        let segmentedControlButtonItem = UIBarButtonItem(customView: segmentControl)
        self.toolbarItems?.insert(segmentedControlButtonItem, at: 2)
        
        spinner.center = self.tableView.center
        self.view.addSubview(spinner)
        spinner.bringSubview(toFront: self.view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    func startScheduleDownload() {
        spinner.startAnimating()
    }
    
    func endScheduleDownload() {
        self.tableView.reloadData()
        spinner.stopAnimating()
    }
    
    override  var supportedInterfaceOrientations : UIInterfaceOrientationMask     {
            return .all
    }
    
    func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            let weekCollectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "Week") as! WeekCollectionViewController
            weekCollectionViewController.weekForView = dayForView
            if let navCon = self.navigationController {
                if navCon.visibleViewController == self {
                navCon.pushViewController(weekCollectionViewController, animated: true)
                print("DAY PUSH")
                }
            }
            
        } else if orientation == .portrait
        {
            print("DAY = PORTRAIT")

        } else if orientation == .portraitUpsideDown {
            print("DAY = UPSIDE DOWN")

        } else {
        }
        
    }
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var result = scheduleArrayForDay?.count ?? 0

        if (shouldHideBeginningZPeriod) {
            result -= 1
        }
        return result

        
    }
    
    private var scheduleArrayForDay:Array<[String]>? {
        get {
            let dayAsText = (dayForView?.toDateString())!
            if let whichSchedule = schoolSchedule.dayScheduleDictionary?[dayAsText]?[0] {
                let periodDictionary = schoolSchedule.schedulePeriodDictionary
                if let arrayOfPeriodsForDay = periodDictionary?[whichSchedule] {
                    return arrayOfPeriodsForDay
                }
            }
            return nil
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayTableCell", for: indexPath)
        let row = shouldHideBeginningZPeriod ? indexPath.row+1 : indexPath.row
        let scheduleArray = scheduleArrayForDay
        let period = scheduleArray?[row][0]
        let calendar = Calendar.current
        
        cell.textLabel?.text = period
        //print("\(period)")
        //print("dayTable viewDidLoad")
        
        if let personalClass = schoolSchedule.personalSchedule?[period!] {
            if personalClass.characters.count>0 {
                cell.textLabel?.text = period! + " (" + personalClass + ")"
            }
        }
        let startTimeMil = scheduleArray?[row][1]
        let endTimeMil = scheduleArray?[row][2]
        
        let startTime = startTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
        let endTime = endTimeMil?.toTime()?.toString(withFormat: "h:mm") ?? "x:xx"
        
        cell.detailTextLabel?.text = startTime + " to " + endTime
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        //This if statement turns current period text red
        
        cell.textLabel?.textColor = UIColor.black
        cell.detailTextLabel?.textColor = UIColor.black
        if dayForView?.toDateString() == Date().toDateString()
        {
            //print("CORRECT DAY")
            let currentComponents = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: Date())
            var startComponents = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: (startTimeMil?.toDate(withFormat: "hh:mm"))!)
            if row > 0  // KMo added this
            {
                if let tempDate = (scheduleArray?[row-1][2].toDate(withFormat: "hh:mm")) {
                startComponents = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: tempDate)
                }
            }
            let endComponents = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: (endTimeMil?.toDate(withFormat: "hh:mm"))!)
            //print("\(startComponents.hour)--\(currentComponents.hour)--\(endComponents.hour)")
            let currentMinutes = currentComponents.hour!*60+currentComponents.minute!
            //.hour = 0 when it should be 12
            var startMinutes: Int
            if startComponents.hour == 0 {
                startMinutes = 12*60 + startComponents.minute!
            } else {
                startMinutes = startComponents.hour!*60 + startComponents.minute!
            }
            var endMinutes: Int
            if endComponents.hour == 0 {
                endMinutes = 12*60 + endComponents.minute!
            } else {
                endMinutes = endComponents.hour!*60 + endComponents.minute!
            }
            
            //print("\(startTime) -- \(endTime)")
            //print("\([startMinutes, currentMinutes, endMinutes])")
            //print("\(startMinutes)")
            if currentMinutes >= startMinutes+1 && currentMinutes <= endMinutes
            {
                cell.textLabel?.textColor = UIColor.schoolColor
                cell.detailTextLabel?.textColor = UIColor.schoolColor
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dayAsText = (dayForView?.toDateString())!
        return schoolSchedule.dayScheduleDictionary?[dayAsText]?[0] ?? ""
    }
    
    private let oneDay = 24*60*60
    
    @IBAction func goBackOneDay(_ sender: Any?) {
        if Calendar.current.component(.weekday, from: dayForView!) == 2
        {
            dayForView = dayForView?.addingTimeInterval(TimeInterval(-oneDay*3))
        }
        else
        {
        dayForView = dayForView?.addingTimeInterval(TimeInterval(-oneDay))
        }
    }
    
    @IBAction func goForwardOneDay(_ sender: Any?) {
        dayForView = dayForView?.addingTimeInterval(TimeInterval(oneDay))
        
    }
    
    @IBAction func todayButtonPressed(_ sender: UIBarButtonItem) {
        dayForView = Date()
    }
    
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contentViewController == self {
            if secondaryViewController.contentViewController is MonthCollectionViewController {
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
