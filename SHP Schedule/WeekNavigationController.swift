//
//  WeekNavigationController.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 9/23/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import UIKit

class WeekNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @objc override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        let currentCollection = self.traitCollection
        if currentCollection.verticalSizeClass == .compact &&
            newCollection.verticalSizeClass == .regular &&
            newCollection.horizontalSizeClass == .compact {
            self.dismiss(animated: true, completion: nil)
            //print("DISMISS!")
        }
    }

    

    

}
