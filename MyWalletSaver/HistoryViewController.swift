//
//  HistoryTableViewController.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 7/9/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, OperationTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet var currencySymbolLabel: [UILabel]?
    
    @IBOutlet weak var rightArrowButton: CustomArrowButton?
    
    @IBOutlet weak var periodLabel: UILabel?
    
    @IBOutlet weak var totalExpenseLabel: UILabel?
    @IBOutlet weak var totalIncomeLabel: UILabel?
    
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var allOperations: [Operation] = [Operation]()
    
    let reuseIdentifier = "Cell"
    
    static let months = [1: "January", 2:"February", 3:"March", 4:"April", 5:"May", 6:"June", 7:"July", 8:"August", 9:"September", 10:"October", 11:"November", 12: "December"]

    
    var totalExpense: Double = 0.0
    var totalIncome: Double = 0.0
    
    
    var viewingMonth: NSDate?
    var stackOfMonths = Stack<(NSDate?, NSDate?)>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewingMonth = self.getStartOfMonth(date: NSDate())
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        self.tableView?.registerNib(UINib(nibName: "OperationTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        
//        self.edgesForExtendedLayout = UIRectEdge.None
//        self.extendedLayoutIncludesOpaqueBars = false
//        self.automaticallyAdjustsScrollViewInsets = false
//        self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        if self.tableView?.respondsToSelector(Selector("setLayoutMargins:")) == true {
            if #available(iOS 8.0, *) {
                self.tableView?.layoutMargins = UIEdgeInsetsZero
            } else {
                // Fallback on earlier versions
            }
        }
        
//        self.tableView.backgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1)
        
//        self.tableView.rowHeight = 55
        
//        if self.tableView.respondsToSelector(Selector("setLayoutMargins:")) == true {
//            self.tableView.layoutMargins = UIEdgeInsetsZero
//        }
        
//        configureOperations()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        
        self.rightArrowButton?.hidden = true
        
        let day_month_interval = self.getCurrentDate()
        
        self.updatePeriodLabel(period: "1 \(day_month_interval.month) - \(day_month_interval.dayNumber) \(day_month_interval.month)")
        
        self.configureOperations(fromDate: self.viewingMonth)
        self.updateAmountLabels()
        
        self.viewingMonth = NSDate()
        
        self.view.backgroundColor = kkbackgroundColor
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("Stack \(self.stackOfMonths.count())")
        self.tableView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.allOperations.removeAll(keepCapacity: true)
        self.tableView?.reloadData()
    }
    
    
    // MARK: - Functions
    
    func configureOperations(fromDate fromDate: NSDate?, toDate: NSDate? = nil) {
        
        self.allOperations = self.allOperations.filter {!$0.fault}
        
        let request = NSFetchRequest(entityName: "Operation")
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        request.sortDescriptors = [sortDescriptor]
        
        var predicate: NSPredicate?
        
        let firstPredicate = NSPredicate(format: "NOT(SELF in %@)", allOperations)
        
        if let date = fromDate {
            let thPredicate = NSPredicate(format: "timestamp >= %@", date)
            
            predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [firstPredicate, thPredicate])
            
        } else {
            predicate = firstPredicate
        }
        
        if let upToDate = toDate {
            let thPredicate = NSPredicate(format: "timestamp <= %@", upToDate)
            
            let newPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [predicate!, thPredicate])
            
            predicate = newPredicate
            
            self.allOperations.removeAll(keepCapacity: false)
        }
        
        
        request.predicate = predicate
        
        if let results = (try? managedObjectContext.executeFetchRequest(request)) as? [Operation] {
            
            if results.count > 0 {
                
                if self.allOperations.count == 0 {
                    self.allOperations.appendContentsOf(results)
                } else {
                
                    for var count = results.count - 1; count >= 0; --count {
                        self.allOperations.insert(results[count], atIndex: 0)
                    }
                }
                
            }
            
            if let symbols = self.currencySymbolLabel {
                let lastCurrency = self.allOperations.first?.currency
                if lastCurrency != symbols[0].text {
                    for symbol in symbols {
                        symbol.text = lastCurrency
                    }
                }
            }
            
            
        } else {
            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "Error", message: "Error", preferredStyle: UIAlertControllerStyle.Alert)
                
                let doneButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                
                alert.addAction(doneButton)
                
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
            
        }
        
        var income = 0.0
        var expense = 0.0
        for operation in self.allOperations {
            let amount = operation.amount
            let symbol = operation.currency
            if symbol != self.currencySymbolLabel?.first?.text { continue }
            
            if amount > 0 {
                income += amount
            } else {
                expense += amount
            }
        }

        self.totalIncome = income
        self.totalExpense = expense
        
    }
    
    
    
    
    func addAmount(amount amount: Double, inout toVariable: Double) {
        toVariable += amount
    }
    
    
    
    func getCurrentDate() -> (dayNumber: Int, month: String) {
        
        
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Day, NSCalendarUnit.Month], fromDate: NSDate())
        let dayNum = components.day
        let monthNum: Int = components.month
        components.day = 1
        components.timeZone = calendar.timeZone
        if #available(iOS 8.0, *) {
            let startOfMonth = calendar.dateBySettingUnit(NSCalendarUnit.Day, value: 1, ofDate: NSDate(), options: [])
        } else {
            // Fallback on earlier versions
        }
        
        
        return (dayNum, HistoryViewController.months[monthNum]!)
        
    }
    
    
    func getMonthName(fromDate fromDate: NSDate?) -> (month: String, lastDay: Int) {
        
        if let date = fromDate {
           
            let calendar = NSCalendar.currentCalendar()
            
            let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Day, NSCalendarUnit.Month], fromDate: date)
            let monthNum: Int = components.month
            let dayNum = components.day
            return (HistoryViewController.months[monthNum]!, dayNum)
            
        }
        
        return ("", 0)
    }
    
    
    func getStartOfMonth(date date: NSDate) -> NSDate? {
        
        // get current calendar
        let calendar = NSCalendar.currentCalendar()
        
        // get components with year and month
        let components = calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: date)
        
        components.timeZone = calendar.timeZone
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        
        // get date from components
        let startOfMonth = calendar.dateFromComponents(components)
        
//        startOfMonth = startOfMonth?.dateByAddingTimeInterval(60*60*3)
        
        // return date with the beginning of this month
        return startOfMonth
        
    }
    
    
    func getPreviousMonth(fromDate fromDate: NSDate) -> (startOfMonth: NSDate?, endOfMonth: NSDate?) {
        
        let calendar = NSCalendar.currentCalendar()
        
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
    
    
    
    func updateAmountLabels() {
        var value: Double = 0
        var fraction: String = ""
        var format: String = ""
        
        value = self.totalIncome
        
        fraction = floor(value) == value && !value.isInfinite ? "0" : "2"
        format = value > 0 ? "%.\(fraction)f" : "%.\(fraction)f"
        self.totalIncomeLabel?.text = String(format: format, value)
        
        value = self.totalExpense
        fraction = floor(value) == value && !value.isInfinite ? "0" : "2"
        format = value > 0 ? "%.\(fraction)f" : "%.\(fraction)f"
        
        self.totalExpenseLabel?.text = String(format: format, value)
    }
    
    
    
    func updatePeriodLabel(period period: String) {
        
        self.periodLabel?.text = period
    }

    // MARK: - Table view data source
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.contentView.backgroundColor = UIColor.whiteColor()
        
//        let line = UILabel(frame: CGRect(x: header.frame.origin.x, y: header.frame.origin.y + header.frame.height - 1, width: header.frame.width, height: 1))
//        
//        line.backgroundColor = UIColor.whiteColor()
//        
//        header.addSubview(line)
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return " " + getCurrentMonth()
//    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.allOperations.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! OperationTableViewCell
        
        let row = indexPath.row
        let operation = self.allOperations[row]
        let amount = operation.amount
        let currency_symbol = operation.currency
        
        let fraction = floor(amount) == amount && !amount.isInfinite ? "0" : "2"
        let format = amount > 0 ? "\(currency_symbol)+%.\(fraction)f" : "\(currency_symbol)%.\(fraction)f"

        
        cell.configure(String(format: format, amount), categoryImage: self.appDelegate.textures[operation.category], walletName: "\(operation.wallet.name)", date: NSDate(timeIntervalSinceReferenceDate: operation.timestamp))
        
        
//        cell.delegate = self
//        cell.operation = operation
        
        cell.setCellColor(UIColor.clearColor())
        cell.setLabelColor(kklabelsColor)

        cell.selectionStyle = .None
        
//        cell.textOnSwipeLeft = "Remove"

        return cell
    }
    
    func deleteItem(item: Operation) {
        let operation = item
        
        if let clabels = self.currencySymbolLabel {
            if operation.currency == clabels.first?.text {
                if operation.amount > 0 {
                    operation.wallet.totalIncome -= operation.amount
                    self.addAmount(amount: -operation.amount, toVariable: &self.totalIncome)
                } else {
                    operation.wallet.totalExpense -= operation.amount
                    self.addAmount(amount: -operation.amount, toVariable: &self.totalExpense)
                }
            }
        }
        
        
        
        managedObjectContext.deleteObject(operation)
        
        managedObjectContext.processPendingChanges()
        var error: NSError?
        do {
            try managedObjectContext.save()
        } catch let error1 as NSError {
            error = error1
            print("Error saving Core Data after deleting relation: \(error?.localizedDescription)")
        }
        
        
        let index = (self.allOperations as NSArray).indexOfObject(operation)
        
        if index == NSNotFound { return }
        
        
        self.allOperations.removeAtIndex(index)
        
        self.tableView?.beginUpdates()
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView?.endUpdates()
        
        NSNotificationCenter.defaultCenter().postNotificationName("DeleteItemFromTableNotification", object: nil, userInfo: ["operation": operation])
        
        self.updateAmountLabels()
        
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    
    // MARK: - Button Actions
    
    @IBAction func leftArrowPressed(sender: AnyObject) {
        
        if self.rightArrowButton?.hidden == true { self.rightArrowButton?.hidden = false }
        
        let thism = self.getStartOfMonth(date: self.viewingMonth!)
        
        let prevm = self.getPreviousMonth(fromDate: thism!)
        
        let endm = self.viewingMonth
        
        self.stackOfMonths.push((thism, endm))
        
        self.viewingMonth = prevm.endOfMonth
        
        self.configureOperations(fromDate: prevm.startOfMonth, toDate: prevm.endOfMonth)
        self.updateAmountLabels()
        let month = self.getMonthName(fromDate: prevm.endOfMonth)
        self.updatePeriodLabel(period: "1 \(month.month) - \(month.lastDay) \(month.month)")
        
        
        self.tableView?.reloadData()
    }
    
    @IBAction func rightArrowPressed(sender: AnyObject) {
        let month = self.stackOfMonths.pop()

        self.viewingMonth = month.1
        self.configureOperations(fromDate: month.0, toDate: month.1)
        self.updateAmountLabels()
        
        let monthDate = self.getMonthName(fromDate: month.1)
        self.updatePeriodLabel(period: "1 \(monthDate.month) - \(monthDate.lastDay) \(monthDate.month)")
        
        
        if self.stackOfMonths.isEmpty() {
            self.rightArrowButton?.hidden = true
        }
        
        self.tableView?.reloadData()
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
