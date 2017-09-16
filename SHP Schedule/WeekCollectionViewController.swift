//
//  WeekCollectionViewController.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 7/13/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class WeekCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var weekForView:Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addGestures()
       
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.isToolbarHidden = true
        
        updateUIForNewWeek()

    }
    
    func addGestures() {
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(WeekCollectionViewController.swipeRightGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(WeekCollectionViewController.swipeLeftGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    func swipeRightGesture () {
        weekForView = weekForView?.addingTimeInterval(TimeInterval(-oneDay*7))
        updateUIForNewWeek()
    }
    
    func swipeLeftGesture () {
        weekForView = weekForView?.addingTimeInterval(TimeInterval(oneDay*7))
        updateUIForNewWeek()
    }
    
    func updateUIForNewWeek() {

        resetToFirstDayOfWeek()
        self.title = weekForView?.toString(withFormat: "MMMM, YYYY")
        self.collectionView?.reloadData()
    }
    
    func resetToFirstDayOfWeek() {
    
        let calendar = Calendar.current
        var components = calendar.dateComponents([Calendar.Component.weekday, Calendar.Component.hour], from: weekForView!)
        if let offset = components.weekday {
            print("RESET \(offset)")

            weekForView = weekForView!.addingTimeInterval(TimeInterval(-oneDay*(offset-2)))
            if let hours = components.hour {
                weekForView = weekForView!.addingTimeInterval(TimeInterval(-hours*60*60))
                weekForView = weekForView!.addingTimeInterval(TimeInterval(12*60*60))
            
            }
        }
    }

    
    func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            print("ROTATED = landscape")
            
        } else if orientation == .portrait || orientation == .portraitUpsideDown {
            
            print("ROTATED = portrait")
            self.navigationController?.isToolbarHidden = false
            self.navigationController?.popViewController(animated: true)

        } else {
            print("ROTATED = other")
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func goForwardOneWeek(_ sender: UIBarButtonItem) {
        weekForView = weekForView?.addingTimeInterval(TimeInterval(oneDay*7))
        updateUIForNewWeek()
    }
    
    @IBAction func goBackOneWeek(_ sender: UIBarButtonItem) {
        weekForView = weekForView?.addingTimeInterval(TimeInterval(-oneDay*7))
        updateUIForNewWeek()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow = 5
        let width = Int(collectionView.bounds.width  / CGFloat(numberOfItemsPerRow))
        let height = Int(collectionView.bounds.height)
        
        return CGSize(width: width, height: height)
    }

    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    private let oneDay = 24*60*60

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekCell", for: indexPath)
        let weekCell = cell as! WeekCollectionViewCell
        weekCell.dayForView = weekForView?.addingTimeInterval(TimeInterval(oneDay*indexPath.row))
        weekCell.tableView.delegate = weekCell
        weekCell.tableView.dataSource = weekCell
        // Evan added the lines inbetween the comments
        weekCell.tableView.rowHeight = collectionView.bounds.height/CGFloat(13)
        weekCell.tableView.isScrollEnabled = false;
        if let periodArray = weekCell.scheduleArrayForDay {
        
            if periodArray.count > 9 {
                weekCell.tableView.rowHeight = collectionView.bounds.height/CGFloat(4+periodArray.count)
            }
        }
        // Evan added the lines inbetween the comments
        weekCell.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeekTableViewCell")
        weekCell.layer.borderColor = UIColor.black.cgColor
        weekCell.layer.borderWidth = 1.0
        weekCell.tableView.reloadData()
        return weekCell
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
