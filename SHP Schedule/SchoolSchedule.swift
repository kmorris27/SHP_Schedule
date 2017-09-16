//
//  SchoolSchedule.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 6/28/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import Foundation
import UserNotifications

protocol SchoolScheduleDelegate {
    func startScheduleDownload()
    func endScheduleDownload()
}

public class SchoolSchedule {
    var delegate:SchoolScheduleDelegate?
    
    private let intervalBetweenUpdates = 24*60*60
    private let urlForScheduleFiles = "http://web.shschools.org/kmo/"
    private let lastUpdatedFileName = "last_updated.txt"
    private let datesFileName = "dates.txt"
    private let defaults = UserDefaults(suiteName: "group.org.shschools.shpschedule.todayextension")
    private let keyForPersonalSchedule = "shp_schedule_personal_schedule_key"
    private let keyForDayScheduleDictionary = "shp_schedule_day_schedule_key"
    private let keyForSchedulePeriodDictionary = "shp_schedule_schedule_period_key"
    private let keyForLastTimeCheckedServer = "shp_schedule_last_time_checked_server_key"
    private let keyForLastTimeServerWasUpdated = "shp_schedule_last_time_server_was_updated"
    private var isDownloading = false {
        didSet {
            if isDownloading { delegate?.startScheduleDownload() }
            else { delegate?.endScheduleDownload() }
        }
    }
    
    
    
    var lastTimeServerWasUpdated:Date {
        get {
            if let dateFromDefaults = (self.defaults!.object(forKey: keyForLastTimeServerWasUpdated) as? Date) {
                return dateFromDefaults
            }
            else { return Date.distantPast }
            
        }
        set {
            defaults!.set(newValue, forKey: keyForLastTimeServerWasUpdated)
        }
    }
    
    var lastTimeCheckedServer:Date {
        get {
            if let dateFromDefaults = (self.defaults!.object(forKey: keyForLastTimeCheckedServer) as? Date) {
                return dateFromDefaults
            }
            else { return Date.distantPast }
        }
        set {
            defaults!.set(newValue, forKey: keyForLastTimeCheckedServer)
            
        }
        
    }
    
    var dayScheduleDictionary:[String:Array<String>]? {
        get {
            if shouldDownloadFromServer() {
                downloadFromServer()
            }
            if let dictionaryFromDefaults = self.defaults!.object(forKey: keyForDayScheduleDictionary) {
                return dictionaryFromDefaults as? [String:Array<String>]
            }
            else {
                return nil
            }
            
        }
    }
    
    
    var schedulePeriodDictionary:[String: Array<[String]> ]? {
        get {
            if shouldDownloadFromServer() {
                downloadFromServer()
            }
            if let dictionaryFromDefaults = self.defaults!.object(forKey: keyForSchedulePeriodDictionary) {
                return dictionaryFromDefaults as? [ String:Array<[String]> ]
            }
            else {
                return nil
            }
            
        }
    }
    
    var personalSchedule:[String:String]? {
        get {
            let dict = self.defaults!.dictionary(forKey: self.keyForPersonalSchedule) as? [String:String]
            return dict
        }
        set {
            self.defaults!.set(newValue, forKey: keyForPersonalSchedule)
        }
    }
    
    
    private func shouldDownloadFromServer() -> Bool {
        
        if isDownloading { return false }
        
        
        let x = self.lastTimeServerWasUpdated
        let y = self.lastTimeCheckedServer
        if x==Date.distantPast || y==Date.distantPast {
            
            print("Server Has Never Been Updated")
            return true
        }
        
        let now = Date()
        if self.lastTimeCheckedServer.addingTimeInterval(TimeInterval(intervalBetweenUpdates)) > now {
            print("Interval inbetween updates is < 24 hours")
            return false
        }
        if let dateDownloadedFromServer = downloadLastUpdatedDateFromServer() {
            return dateDownloadedFromServer != self.lastTimeServerWasUpdated
        }
        else {
            return false
        }
        
    }
    
    private func downloadLastUpdatedDateFromServer() -> Date?
    {
        let urlForLastUpdatedFile = self.urlForScheduleFiles+self.lastUpdatedFileName
        if let url = URL(string: urlForLastUpdatedFile) {
            do {
                let contents = try String(contentsOf: url)
                print("GRABBED DATE FROM SERVER")
                
                if let dateFromServer = contents.toDateTime() {
                    //print("DFS == \(dateFromServer)")
                    
                    lastTimeCheckedServer = Date()
                    
                    return dateFromServer
                }
            }
            catch let error {
                print("Error: \(error)")
            }
        }
        return nil
        
    }
    
    //Parse text file
    
    //TODO: - For notifications, check presence of oneDayInfoArray[2] and send notification at 9:00 pm the night before
    
    func downloadFromServer() {
        print("DOWNLOADING...")
        let urlForDatesFile = self.urlForScheduleFiles+self.datesFileName
        var dictDayScheduleFromFile = [String:Array<String>]()
        var dictSchedulePeriodFromFile = [String:Array<[String]>]()
        self.isDownloading = true
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            if let url = URL(string: urlForDatesFile) {
                do {
                    
                    let contents = try String(contentsOf: url)
                    //print("HTML : \(contents)")
                    let dateInfoArray = contents.components(separatedBy: "\n")
                    for dateInfo in dateInfoArray {
                        var oneDayInfoArray = dateInfo.components(separatedBy: "\t")
                        if (oneDayInfoArray.count>1) {
                            while(oneDayInfoArray.count<4) {
                                oneDayInfoArray.append("")
                            }
                            let key = oneDayInfoArray[0]
                            let scheduleIdentifier = oneDayInfoArray[1]
                            let value = [oneDayInfoArray[1],oneDayInfoArray[2],oneDayInfoArray[3]]
                            dictDayScheduleFromFile[ key ] = value
                            if let scheduleInfoArray = self?.downloadOneScheduleIdentifier(identifier: scheduleIdentifier) {
                                dictSchedulePeriodFromFile[ scheduleIdentifier ] = scheduleInfoArray
                            }
                        }
                    }
                    
                    self?.defaults!.set(dictDayScheduleFromFile, forKey: (self?.keyForDayScheduleDictionary)!)
                    
                    self?.defaults!.set(dictSchedulePeriodFromFile, forKey: (self?.keyForSchedulePeriodDictionary)!)
                    
                    let now = Date()
                    self?.lastTimeCheckedServer = now
                    
                    if let downloadedLastTimeServerWasUpdated = self?.downloadLastUpdatedDateFromServer() {
                        self?.defaults!.set(downloadedLastTimeServerWasUpdated, forKey: (self?.keyForLastTimeServerWasUpdated)!)
                    }
                    self?.scheduleNotifications()
                    self?.isDownloading = false
                    print("DONE DOWNLOADING")
                }
                catch let error {
                    print("Error!: \(error)") }
                
            }
        }
    }
    
    private func downloadOneScheduleIdentifier(identifier:String) ->Array<[String]>? {
        let urlForDatesFile = self.urlForScheduleFiles+identifier+".txt"
        var result = Array<[String]>()
        
        if let url = URL(string: urlForDatesFile.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)      {
            
            do {
                let contents = try String(contentsOf: url)
                let scheduleInfoArray = contents.components(separatedBy: "\n")
                for scheduleInfo in scheduleInfoArray {
                    let onePeriodScheduleInfoArray = scheduleInfo.components(separatedBy: "\t")
                    if (onePeriodScheduleInfoArray.count==3) {
                        let period = onePeriodScheduleInfoArray[0]
                        //let startTime = onePeriodScheduleInfoArray[1].toTime()!
                        //let endTime = onePeriodScheduleInfoArray[2].toTime()!
                        let startTime = onePeriodScheduleInfoArray[1]
                        let endTime = onePeriodScheduleInfoArray[2]
                        let array = [period,startTime,endTime]
                        result.append(array)
                        
                    }
                }
                
            }
            catch {
                return nil
            }
        }
        return result
        
    }
    
    
    func scheduleNotifications() {
        print("Notifications Started...")
        removeNotifications()
        if let dict = self.dayScheduleDictionary
        {
            for (key,value) in dict {
                if value[1] != "" //If that day has something in the notifications column on the text document
                {
                    handleOneNotification(key: key)
                }
            }
        }
        print("Notifications Complete...")
    }
    
    private func handleOneNotification(key: String)
    {
        let content = notificationContent(date: key.toDate()!)
        if content != nil{
            let time = key.toDate()
            var triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: time!)
            triggerDate.hour = 21
            triggerDate.day = triggerDate.day!-1
            print("content = \(String(describing: content)) date = \(key)")
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            let request = UNNotificationRequest(identifier: key, content: content!, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.add(request, withCompletionHandler: { (error) in if error != nil {
                //Something went wrong
                print("Error in scheduling notification")
                }})
            //print(" \(key) ---- \(time)")
            
        }
    }
    
    private func notificationContent(date: Date) -> UNMutableNotificationContent? {
        if let schedule = dayScheduleDictionary?[date.toDateString()]?[0]        {
            let content = UNMutableNotificationContent()
            var title = ""
            let body = ""
            if (schedulePeriodDictionary?[schedule]) != nil
            {
                if let notification = dayScheduleDictionary?[date.toDateString()]?[1]
                {
                    if notification.characters.count > 0
                    {
                        title = notification + ". "
                    }
                }
                content.title = title
                content.body = body
                content.sound = UNNotificationSound.default()
    
                return content
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func removeNotifications() {
        let center = UNUserNotificationCenter.current()
        if dayScheduleDictionary != nil {
            for (key,_) in dayScheduleDictionary!
            {
                
                center.removePendingNotificationRequests(withIdentifiers: [key])
            }
        }
    }
    
}
