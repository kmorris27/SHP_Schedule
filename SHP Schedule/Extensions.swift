//
//  Extensions.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 6/28/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func toDate(withFormat format:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))    }
    
    func toDate() -> Date? {
        return self.toDate(withFormat: "MM-dd-yyyy")
    }
    
    func toTime() -> Date? {
        return self.toDate(withFormat: "k:mm")
    }
    
    func toDateTime() -> Date? {
        return self.toDate(withFormat: "MM-dd-yyyy k:mm")
    }
}

extension Date {
    func toString(withFormat format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func toDateString() -> String {
        return self.toString(withFormat: "M-dd-yyyy")
    }
    
    func toTimeString() -> String {
        return self.toString(withFormat: "hh:mm")
        
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

    
//General UIColor fromHex function
extension UIColor {
    static func fromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    static var schoolColor: UIColor{
        return UIColor(red: 151.0/255.0, green: 47.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    }
}

