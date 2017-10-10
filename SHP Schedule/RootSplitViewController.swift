//
//  RootSplitViewController.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 9/26/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class RootSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var shouldAutorotate: Bool {
        if let masterNav = self.viewControllers.first as? UINavigationController {
            if masterNav.topViewController is SettingsViewController {
                return false
            }
        }
        return true
    }
}
