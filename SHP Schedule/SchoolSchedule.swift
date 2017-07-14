//
//  SchoolSchedule.swift
//  SHP Schedule
//
//  Created by Kevin Morris on 6/28/17.
//  Copyright © 2017 Kevin Morris. All rights reserved.
//

import Foundation

protocol SchoolScheduleDelegate {
    func startScheduleDownload()
    func endScheduleDownload()
}

public class SchoolSchedule
{
    var delegate:SchoolScheduleDelegate?

    private let intervalBetweenUpdates = 24*60*60
    private let urlForScheduleFiles = "http://web.shschools.org/kmo/"
    private let lastUpdatedFileName = "last_updated.txt"
    private let datesFileName = "dates.txt"
    private let defaults = UserDefaults.standard
    private let keyForPersonalSchedule = "shp_schedule_personal_schedule_key"
    private let keyForDayScheduleDictionary = "shp_schedule_day_schedule_key"
    private let keyForSchedulePeriodDictionary = "shp_schedule_schedule_period_key"
    private let keyForLastTimeCheckedServer = "shp_schedule_last_time_checked_server_key"
    private let keyForLastTimeServerWasUpdated = "shp_schedule_last_time_server_was_updated"
    private var isDownloading = false
    {
        didSet {
            if isDownloading { delegate?.startScheduleDownload() }
            else { delegate?.endScheduleDownload() }
        }
    }
    
    
    
    private var lastTimeServerWasUpdated:Date {
        get {
            if let dateFromDefaults = (self.defaults.object(forKey: keyForLastTimeServerWasUpdated) as? Date)
            {
                return dateFromDefaults
            }
            else { return Date.distantPast }
            
        }
        set {
            defaults.set(newValue, forKey: keyForLastTimeServerWasUpdated)
        }
    }
    
    private var lastTimeCheckedServer:Date
    {
        get {
            if let dateFromDefaults = (self.defaults.object(forKey: keyForLastTimeCheckedServer) as? Date)
            {
                return dateFromDefaults
            }
            else { return Date.distantPast }
        }
        set {
            defaults.set(newValue, forKey: keyForLastTimeCheckedServer)
            
        }
        
    }
    
    var dayScheduleDictionary:[String:Array<String>]?
    {
        get {
            if shouldDownloadFromServer()
            {
                downloadFromServer()
            }
            if let dictionaryFromDefaults = self.defaults.object(forKey: keyForDayScheduleDictionary)
            {
                return dictionaryFromDefaults as? [String:Array<String>]
            }
            else
            {
                return nil
            }
            
        }
    }
    
    
    var schedulePeriodDictionary:[String: Array<[String]> ]?
    {
        get {
            if shouldDownloadFromServer()
            {
                downloadFromServer()
            }
            if let dictionaryFromDefaults = self.defaults.object(forKey: keyForSchedulePeriodDictionary)
            {
                return dictionaryFromDefaults as? [ String:Array<[String]> ]
            }
            else
            {
                return nil
            }
            
        }
    }
    
    var personalSchedule:[String:String]?
    {
        get {
            let dict = self.defaults.dictionary(forKey: self.keyForPersonalSchedule) as? [String:String]
            return dict
        }
        set {
            self.defaults.set(newValue, forKey: keyForPersonalSchedule)
            print("SETTING \(String(describing: newValue))")
        }
    }
    
    
    private func shouldDownloadFromServer() -> Bool
    {

        if isDownloading { return false }
        

        let x = self.lastTimeServerWasUpdated
        let y = self.lastTimeCheckedServer
        if x==Date.distantPast || y==Date.distantPast
        {
            
            return true
        }
        
        let now = Date()
        if self.lastTimeCheckedServer.addingTimeInterval(TimeInterval(intervalBetweenUpdates)) > now
        {
            return false
        }
        if let dateDownloadedFromServer = downloadLastUpdatedDateFromServer()
        {
            return dateDownloadedFromServer != self.lastTimeServerWasUpdated
        }
        else
        {
            return false
        }
        
        
    }
    
    private func downloadLastUpdatedDateFromServer() -> Date?
    {
        let urlForLastUpdatedFile = self.urlForScheduleFiles+self.lastUpdatedFileName
        if let url = URL(string: urlForLastUpdatedFile)
        {
            do {
                let contents = try String(contentsOf: url)
                
                if let dateFromServer = contents.toDateTime()
                {
                    //print("DFS == \(dateFromServer)")
                    
                    return dateFromServer
                }
            }
            catch let error {
                print("Error: \(error)")
            }
        }
        return nil
        
    }
    
    private func downloadFromServer()
    {
        print("DOWNLOADING...")
        let urlForDatesFile = self.urlForScheduleFiles+self.datesFileName
        var dictDayScheduleFromFile = [String:Array<String>]()
        var dictSchedulePeriodFromFile = [String:Array<[String]>]()
        self.isDownloading = true
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            if let url = URL(string: urlForDatesFile)
            {
                do {
                    
                    let contents = try String(contentsOf: url)
                    //print("HTML : \(contents)")
                    let dateInfoArray = contents.components(separatedBy: "\n")
                    for dateInfo in dateInfoArray
                    {
                        var oneDayInfoArray = dateInfo.components(separatedBy: "\t")
                        if (oneDayInfoArray.count>1)
                        {
                            while(oneDayInfoArray.count<4)
                            {
                                oneDayInfoArray.append("")
                            }
                            let key = oneDayInfoArray[0]
                            let scheduleIdentifier = oneDayInfoArray[1]
                            let value = [oneDayInfoArray[1],oneDayInfoArray[2],oneDayInfoArray[3]]
                            dictDayScheduleFromFile[ key ] = value
                            if let scheduleInfoArray = self?.downloadOneScheduleIdentifier(identifier: scheduleIdentifier)
                            {
                                dictSchedulePeriodFromFile[ scheduleIdentifier ] = scheduleInfoArray
                            }
                        }
                    }
                    
                    self?.defaults.set(dictDayScheduleFromFile, forKey: (self?.keyForDayScheduleDictionary)!)
                    
                    self?.defaults.set(dictSchedulePeriodFromFile, forKey: (self?.keyForSchedulePeriodDictionary)!)
                    
                    let now = Date()
                    self?.lastTimeCheckedServer = now
                    
                    if let downloadedLastTimeServerWasUpdated = self?.downloadLastUpdatedDateFromServer()
                    {
                        self?.defaults.set(downloadedLastTimeServerWasUpdated, forKey: (self?.keyForLastTimeServerWasUpdated)!)
                    }
                    self?.isDownloading = false
                }
                catch let error {
                    print("Error!: \(error)") }
                
            }
        }
    }
    
    private func downloadOneScheduleIdentifier(identifier:String) ->Array<[String]>?
    {
        let urlForDatesFile = self.urlForScheduleFiles+identifier+".txt"
        var result = Array<[String]>()
        
        if let url = URL(string: urlForDatesFile.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)      {
            
            do
            {
                let contents = try String(contentsOf: url)
                let scheduleInfoArray = contents.components(separatedBy: "\n")
                for scheduleInfo in scheduleInfoArray
                {
                    let onePeriodScheduleInfoArray = scheduleInfo.components(separatedBy: "\t")
                    if (onePeriodScheduleInfoArray.count==3)
                    {
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
    
    
    
    
}







