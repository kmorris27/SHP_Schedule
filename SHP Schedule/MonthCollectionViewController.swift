//
//  MonthCollectionViewController.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 7/9/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class MonthCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SchoolScheduleDelegate {
    
    //MARK: - Variables
    private let oneDay = 24*60*60
    var schoolSchedule = SchoolSchedule()
    let spinner:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var smallestFont: CGFloat = 40
    var monthForView:Date?
    
    
    var offsetForFirstDayOfMonth:Int {
        get {
            let calendar = Calendar.current
            if let monthForOffset = monthForView {
                let weekday = calendar.component(.weekday, from: monthForOffset)
                if weekday==7 {return 2}
                else if weekday==1 {return 1}
                else {return -(weekday-2)}
            }
            return 0
        }
    }
    
    func addGestures() {
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(MonthCollectionViewController.rightSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(MonthCollectionViewController.leftSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    func rightSwipeGesture() {
        monthForView = monthForView?.addingTimeInterval(TimeInterval(-oneDay))
        updateUIForNewMonth()
    }
    
    func leftSwipeGesture() {
        monthForView = monthForView?.addingTimeInterval(TimeInterval(oneDay*31))
        updateUIForNewMonth()
    }

    
    
    //MARK: - Methods
    func updateUIForNewMonth() {
        resetToFirstDayOfMonth()
        self.title = monthForView?.toString(withFormat: "MMMM, YYYY")
        self.collectionView?.reloadData()
    }
        
    func resetToFirstDayOfMonth() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([Calendar.Component.day, Calendar.Component.hour], from: monthForView!)
        if let offset = components.day {
            monthForView = monthForView!.addingTimeInterval(TimeInterval(-oneDay*(offset-1)))
            if let hours = components.hour {
                
                monthForView = monthForView!.addingTimeInterval(TimeInterval(-hours*60*60))
                monthForView = monthForView!.addingTimeInterval(TimeInterval(12*60*60))

            }
        }
    }

    func segmentedControlChanged(_ sender:UISegmentedControl) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schoolSchedule.delegate = self
        collectionView!.dataSource = self
        addGestures()
        print("Month View Loaded")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        //Why not register the monthViewCell here?
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        //self.collectionView!.register(MonthCollectionViewCell.self, forCellWithReuseIdentifier: "monthViewCell")
        let segmentControl = UISegmentedControl(items: ["Day","Month"])
        segmentControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        segmentControl.selectedSegmentIndex=1
        segmentControl.tintColor = UIColor.schoolColor
        let segmentedControlButtonItem = UIBarButtonItem(customView: segmentControl)
        self.toolbarItems?.insert(segmentedControlButtonItem, at: 2)

        spinner.center = self.collectionView?.center ?? self.view.center
        self.view.addSubview(spinner)
        spinner.bringSubview(toFront: self.view)
        
        updateUIForNewMonth()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            let weekCollectionViewController = self.storyboard?.instantiateViewController(withIdentifier: "Week") as! WeekCollectionViewController
            weekCollectionViewController.weekForView = monthForView
            self.navigationController?.pushViewController(weekCollectionViewController, animated: true)
            
        } else if orientation == .portrait || orientation == .portraitUpsideDown {
            // do nothing
        } else {
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    
    func startScheduleDownload() {
        spinner.startAnimating()
    }
    
    func endScheduleDownload() {
        self.collectionView?.reloadData()
        spinner.stopAnimating()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "MTWTF",
                                                                             for: indexPath)
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfItemsPerRow = 5
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalHorizontalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let navBarHeight = (self.navigationController?.navigationBar.frame.height)!
        let toolbarHeight = (self.navigationController?.toolbar.frame.height)!
        let headerHeight = flowLayout.headerReferenceSize.height
        let totalVerticalSpace = flowLayout.sectionInset.top
            + flowLayout.sectionInset.bottom
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
            + navBarHeight
            + toolbarHeight
            + headerHeight
            + 16
        //let width = Int((collectionView.contentSize.width - totalHorizontalSpace) / CGFloat(numberOfItemsPerRow))
        
        let width = Int((collectionView.bounds.width - totalHorizontalSpace) / CGFloat(numberOfItemsPerRow))
        
        let height = Int((collectionView.bounds.height - totalVerticalSpace) / CGFloat(numberOfItemsPerRow))
        
        return CGSize(width: width, height: height)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 25
    }
    
    private func scheduleArray(for day:Date)-> [String]? {
            let dayAsText = day.toDateString()
            let dict = schoolSchedule.dayScheduleDictionary
            if let scheduleArray = dict?[dayAsText] {
               return scheduleArray
                }
            return nil
    }

    func dateFromIndexPath(_ indexPath:IndexPath) -> Date {
        let offset = offsetForFirstDayOfMonth
        let extraWeekendDays = (indexPath.row)/5*2
        let daysAhead = indexPath.row+extraWeekendDays+offset
        return monthForView?.addingTimeInterval(TimeInterval(oneDay*daysAhead)) ?? Date()

    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "monthViewCell", for: indexPath) as! MonthCollectionViewCell
        let calendar = Calendar.current
        let today = Date()
        let fontSize = cell.numberLabel.font.pointSize
        if fontSize < smallestFont {
            smallestFont = fontSize
        }
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1.0
        cell.numberLabel.font = cell.numberLabel.font.withSize(smallestFont)

        if monthForView != nil
        {
            let month = String(calendar.component(.month, from: monthForView!))
            let dayForCellView = dateFromIndexPath(indexPath)
            let day = String(calendar.component(.day, from: dayForCellView))
            cell.numberLabel.text = day
            let array = scheduleArray(for: dayForCellView)
            let schedule = array?[0] ?? ""
            cell.scheduleLabel.text = schedule
            cell.periodLabel.text = periodsForSchedule(schedule)
            if (today.toDateString()==dayForCellView.toDateString())
            {
                
                cell.layer.borderColor = UIColor.schoolColor.cgColor
                cell.layer.borderWidth = 3.0
            }
            let textColor:UIColor
            let backgroundColor:UIColor
            if (month != String(calendar.component(.month, from: dayForCellView)))
            { textColor = UIColor.darkGray }
            else
            { textColor = UIColor.black }
            let dict = schoolSchedule.schedulePeriodDictionary
            let periods = dict?[schedule]
            print("\(dayForCellView) \(schedule)  \(String(describing: periods?.count))")
            if (periods == nil || periods?.count == 0)
            { backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)}
            else
            { backgroundColor = UIColor.white }

            cell.numberLabel.textColor = textColor
            cell.scheduleLabel.textColor = textColor
            cell.backgroundColor = backgroundColor
        }
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let rootViewController = self.navigationController?.viewControllers.first
        if let dayTableViewController = rootViewController as? DayTableViewController {
            dayTableViewController.dayForView = dateFromIndexPath(indexPath)
            self.navigationController?.popViewController(animated: true)            
        }
    }
    
    @IBAction func goBackOneMonth(_ sender: Any) {
        monthForView = monthForView?.addingTimeInterval(TimeInterval(-oneDay))
        updateUIForNewMonth()
    }
    
    @IBAction func goForwardOneMonth(_ sender: Any) {
        monthForView = monthForView?.addingTimeInterval(TimeInterval(oneDay*31))
        updateUIForNewMonth()
        
        
    }
    
    @IBAction func todayButtonPressed(_ sender: Any) {
        monthForView = Date()
        updateUIForNewMonth()
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
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}
