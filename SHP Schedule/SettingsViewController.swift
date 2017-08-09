//
//  SettingsViewController.swift
//  SHP Schedule
//
//  Created by Isabella Rhyu on 7/10/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var syncView: UIView!
    @IBOutlet weak var informationLabel: UILabel!
    //TODO: - Adjust spacing in label to make it less crowded
    @IBOutlet weak var latestPublishedLabel: UILabel!
    @IBOutlet weak var latestSyncLabel: UILabel!
    //TODO: - Make periods adjustable based upon the student's schedule (i.e. optional Z period)
    var periods = ["A", "B", "C", "D", "E", "F", "G", "X", "Y", "Z"]
    //Modified to make school schedule non-optional
    var schoolSchedule = SchoolSchedule()
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(PeriodTableViewCell.self, forCellReuseIdentifier: "cell")
        latestPublishedLabel.text! = "Latest published school schedule: " + schoolSchedule.lastTimeServerWasUpdated.toTimeString()
        latestSyncLabel.text! = "Most recent sync: " + schoolSchedule.lastTimeCheckedServer.toTimeString()
        informationLabel.numberOfLines = 0
        informationLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        //Adjust such that font sizes between labels are uniform
        //label.font = label.font.fontWithSize(20)

        latestPublishedLabel.font = informationLabel.font
        latestSyncLabel.font = informationLabel.font

        
        // Do any additional setup after loading the view.
    }
    @IBAction func updateRequested(_ sender: Any) {
        //TODO: - Have label update immediately (Most recent sync not updating till next viewController cycle
        schoolSchedule.downloadFromServer()
        latestSyncLabel.text! = "Most recent sync: " + schoolSchedule.lastTimeCheckedServer.toTimeString()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periods.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "periodCell", for: indexPath) as! PeriodTableViewCell
        let period = periods[indexPath.row]
        cell.periodLabel.text = period
        let personalClass = schoolSchedule.personalSchedule?[period]
        cell.updateUI(for: period, withPersonalClass: personalClass)
        //cell.textLabel?.text = periods[indexPath.row]
        return cell
    }
    
    /* func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.rowHeight = UITableViewAutomaticDimension
        return (tableView.frame.height / CGFloat(periods.count))
    } */
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section==0 {
            return "My Personal Schedule"
        }
        else if section==1 {
            return "Update Schedule Data"
        }
        else {
            return nil
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
