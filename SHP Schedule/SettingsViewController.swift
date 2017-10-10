//
//  SettingsViewController.swift
//  SHP Schedule
//
//  Created by Isabella Rhyu on 7/10/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SchoolScheduleDelegate {

    //MARK: - Variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var syncView: UIView!

    @IBOutlet weak var latestSyncTimeLabel: UILabel!
    @IBOutlet weak var latestPublishedTimeLabel: UILabel!

    var periods = ["A", "B", "C", "D", "E", "F", "G", "W", "X", "Y", "Z"]

    var schoolSchedule = SchoolSchedule()
    
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        schoolSchedule.delegate = self
        self.tableView.register(PeriodTableViewCell.self, forCellReuseIdentifier: "cell")
        
        latestSyncTimeLabel.text! = schoolSchedule.lastTimeCheckedServer.toString(withFormat: "MMMM d, yyyy h:mm a")
        latestPublishedTimeLabel.text! = schoolSchedule.lastTimeServerWasUpdated.toString(withFormat: "MMMM d, yyyy h:mm a")
        self.navigationController?.isToolbarHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: .UIKeyboardDidHide, object: nil)

        spinner.center = self.view.center
        self.view.addSubview(spinner)
        spinner.bringSubview(toFront: self.view)
        
    }
    
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isToolbarHidden = false
        finishEditingCells()
        NotificationCenter.default.removeObserver(#selector(keyboardDidShow))
        NotificationCenter.default.removeObserver(#selector(keyboardDidHide))

    }
    
    @objc func keyboardDidShow(_ notification:Notification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height

        self.tableView.contentInset = contentInset
        
    }
    
    @objc func keyboardDidHide(_ notification:Notification) {

        self.tableView.contentInset = UIEdgeInsets.zero
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if let cell = textField.superview?.superview as? PeriodTableViewCell {
            if var indexPath = tableView.indexPath(for: cell) {
                indexPath.row = indexPath.row + 1
                if let nextCell = self.tableView.cellForRow(at: indexPath) as? PeriodTableViewCell
                {
                    textField.resignFirstResponder()
                    nextCell.periodTextField.becomeFirstResponder()
                    return true
                }
            }
        }
        return false
    }
    
    func finishEditingCells() {
        for row in 0..<periods.count {
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = self.tableView.cellForRow(at: indexPath) as? PeriodTableViewCell {
                cell.editingPeriodEnded()
            }
            
        }
    }
    
    @IBAction func updateRequested(_ sender: Any) {
        //TODO: - Have label update immediately (Most recent sync not updating till next viewController cycle
        schoolSchedule.downloadFromServer()
        latestSyncTimeLabel.text! = schoolSchedule.lastTimeCheckedServer.toString(withFormat: "MMMM d, yyyy h:mm a")
    }
    
    func startScheduleDownload() {
        DispatchQueue.main.async {
            self.spinner.color = UIColor.schoolColor
            self.spinner.startAnimating()
        }
    }
        
    func endScheduleDownload() {
        DispatchQueue.main.async {
            self.latestSyncTimeLabel.text = self.schoolSchedule.lastTimeCheckedServer.toString(withFormat: "MMMM d, yyyy h:mm a")
            self.latestPublishedTimeLabel.text = self.schoolSchedule.lastTimeServerWasUpdated.toString(withFormat: "MMMM d, yyyy h:mm a")
            self.tableView.reloadData()
            self.spinner.stopAnimating()
        }
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
        cell.periodTextField.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.none
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
