//
//  SettingsTableViewController.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 7/5/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    var periods:[String]?
    var schoolSchedule:SchoolSchedule? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        self.navigationController?.isToolbarHidden = true
        //periods = ["A", "B", "C", "D", "E", "F", "G", "Z"]
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section==0) ? (periods?.count ?? 0) : 1
    }

   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section==0) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeriodSetting", for: indexPath)
        let settingsCell = cell as! PeriodTableViewCell
        let period = (periods?[indexPath.row])!
        let personalClass = schoolSchedule?.personalSchedule?[period]
            //settingsCell.updateUI(for: (periods?[indexPath.row])!)
         settingsCell.updateUI(for: period, withPersonalClass:personalClass)
        return settingsCell
        }
        else  //if indexPath.section==1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateSetting", for: indexPath)
            let updateCell = cell as! UpdateTableViewCell
            updateCell.lastUpdated = "now"
            
            //settingsCell.updateUI(for: (periods?[indexPath.row])!)
            return updateCell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        } else {
            return 100
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
