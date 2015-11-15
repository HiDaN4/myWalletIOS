//
//  DateCalendarManager.swift
//  WalletTracker
//
//  Created by Dmitry Sokolov on 11/14/15.
//  Copyright © 2015 Dmitry Sokolov. All rights reserved.
//

import Foundation


class DateCalendarManager {
    
    static let calendar = NSCalendar.currentCalendar()
    
    static let months = [1: "January", 2:"February", 3:"March", 4:"April", 5:"May", 6:"June", 7:"July", 8:"August", 9:"September", 10:"October", 11:"November", 12: "December"]
    
    
    class func getCurrentDate() -> (dayNumber: Int, month: String) {
        
        let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Day, NSCalendarUnit.Month], fromDate: NSDate())
        let dayNum = components.day
        let monthNum: Int = components.month
        
        return (dayNum, months[monthNum]!)
        
    }

    
    
    class func getMonthName(fromDate aDate: NSDate?) -> (month: String, lastDay: Int) {
        
        if let date = aDate {
            
            let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Day, NSCalendarUnit.Month], fromDate: date)
            let monthNum: Int = components.month
            let dayNum = components.day
            return (months[monthNum]!, dayNum)
            
        }
        
        return ("Unknown", 0)
    }
    
    
    
    class func getComponentsFrom(date aDate: NSDate) -> (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
        
        let components = calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: aDate)
        
        return (components.year, components.month, components.day, components.hour, components.minute, components.second)
        
    }
    
    
    class func getBeginningDayOf(date: NSDate) -> NSDate {
        
        let components = calendar.components([ .Year, .Month, .Day, .Minute, .Hour, .Second], fromDate: date)
        
        components.timeZone = calendar.timeZone
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        
        let begin = calendar.dateFromComponents(components)!
        
        return begin
        
    }
    
    class func getEndOfDayOf(date: NSDate) -> NSDate {
        
        let components = calendar.components([ .Year, .Month, .Day, .Minute, .Hour, .Second], fromDate: date)
        
        components.timeZone = calendar.timeZone
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        
        let end = calendar.dateFromComponents(components)!
        
        return end
        
    }
    
    
    class func getPreviousDayFrom(date: NSDate) -> NSDate {
        let components = calendar.components([ .Year, .Month, .Day, .Minute, .Hour, .Second], fromDate: date)
        
        components.timeZone = calendar.timeZone
        components.day -= 1
        
        let end = calendar.dateFromComponents(components)!
        
        return end
    }
    
    
    class func getNextDayFrom(date: NSDate) -> NSDate {
        let components = calendar.components([ .Year, .Month, .Day, .Minute, .Hour, .Second], fromDate: date)
        
        components.timeZone = calendar.timeZone
        components.day += 1
        
        let next = calendar.dateFromComponents(components)!
        
        return next
    }
    
    
    class func getDayPeriod(date: NSDate) -> (begin: NSDate, end: NSDate) {
        
        let components = calendar.components([ .Year, .Month, .Day, .Minute, .Hour, .Second], fromDate: date)
        
        components.timeZone = calendar.timeZone
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        
        let begin = calendar.dateFromComponents(components)
        
        components.day += 1
        
        let end = calendar.dateFromComponents(components)
        
        if begin != nil && end != nil {
            return (begin!, end!)
        }
        
        
        return (NSDate(), NSDate())
    }
    
    
    class func getStartOfMonth(date date: NSDate) -> NSDate? {
        
        // get components with year and month
        let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: date)
        
        components.timeZone = calendar.timeZone
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        // get date from components
        let startOfMonth = calendar.dateFromComponents(components)
        
        
        // return date with the beginning of this month
        return startOfMonth
        
    }
    
    
    
    class func getPreviousMonth(fromDate fromDate: NSDate) -> (startOfMonth: NSDate?, endOfMonth: NSDate?) {
    
        let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: fromDate.dateByAddingTimeInterval(-1))
        
        components.timeZone = calendar.timeZone
        
        if let previousMonthDate = calendar.dateFromComponents(components) {
            
            let newComponents = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: previousMonthDate)
            
            newComponents.timeZone = calendar.timeZone
            
            newComponents.day = 1
            
            let startOfMonth = calendar.dateFromComponents(newComponents)
            
            return (startOfMonth, previousMonthDate)
        }
        
        return (nil, nil)
        
    }
    
    
    
    
    
}