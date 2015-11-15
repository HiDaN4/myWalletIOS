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
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet var currencySymbolLabel: [UILabel]?
    
    @IBOutlet weak var rightArrowButton: CustomArrowButton?
    
    @IBOutlet weak var periodLabel: UILabel?
    
    @IBOutlet weak var totalExpenseLabel: UILabel?
    @IBOutlet weak var totalIncomeLabel: UILabel?
    
    @IBOutlet weak var changePeriodButton: UIButton?
    @IBOutlet weak var showLastButton: UIButton?
    
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var allOperations: [Operation] = [Operation]()
    
    private let reuseIdentifier = "Cell"
    
    var totalExpense: Double = 0.0
    var totalIncome: Double = 0.0
    
    var viewingMonth: NSDate?
    var stackOfPeriods = Stack<(NSDate?, NSDate?)>()
    
    
    var isInPast = false
    
    enum ShowingBy {
        case day
        case week
        case month
    }
    
    var showingBy = ShowingBy.month

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = kkbackgroundColor
        
        self.viewingMonth = DateCalendarManager.getStartOfMonth(date: NSDate())
        
        self.configureTable()
        
        self.showLastButton?.hidden = true
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        
        self.rightArrowButton?.hidden = true
        
        let day_month_interval = DateCalendarManager.getCurrentDate()
        
        self.updatePeriodLabel(period: "1 \(day_month_interval.month) - \(day_month_interval.dayNumber) \(day_month_interval.month)")
        
        self.configureOperations(fromDate: self.viewingMonth)
        self.updateAmountLabels()
        
        self.viewingMonth = NSDate()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.allOperations.removeAll(keepCapacity: true)
        self.tableView?.reloadData()
    }
    
    
    // MARK: - Functions
    
    
    func configureTable() {
        
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
        
//        self.tableView?.backgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1)
//
//        self.tableView?.rowHeight = 55

        
    }
    
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
                let alert = UIAlertView(title: "Error", message: "Error", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
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
        
    }
    
    

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
    
    
    // MARK: - Button Actions
    
    @IBAction func leftArrowPressed(sender: AnyObject) {
        
        isInPast = true
        
        self.changePeriodButton?.hidden = true
        self.showLastButton?.hidden = false
        
        if self.rightArrowButton?.hidden == true { self.rightArrowButton?.hidden = false }
        
        self.handleGoBackHistory()
        
    }
    
    
    func handleGoBackHistory() {
        
        switch (self.showingBy) {
        case .month:
            
            let thism = DateCalendarManager.getStartOfMonth(date: self.viewingMonth!)
            
            let prevm = DateCalendarManager.getPreviousMonth(fromDate: thism!)
            
            let endm = self.viewingMonth
            
            self.stackOfPeriods.push((thism, endm))
            
            self.viewingMonth = prevm.endOfMonth
            
            self.configureOperations(fromDate: prevm.startOfMonth, toDate: prevm.endOfMonth)
            self.updateAmountLabels()
            let month = DateCalendarManager.getMonthName(fromDate: prevm.endOfMonth)
            self.updatePeriodLabel(period: "1 \(month.month) - \(month.lastDay) \(month.month)")
            
        case .week: break
            
        case .day:
            
            let this = self.viewingMonth!
            
            let prev = DateCalendarManager.getBeginningDayOf(this)
            
            let prevDay = DateCalendarManager.getPreviousDayFrom(prev)
            
            self.stackOfPeriods.push((this, prev))
            
            self.configureOperations(fromDate: prevDay, toDate: this)
            
//            self.viewingMonth = prev
            self.viewingMonth = DateCalendarManager.getEndOfDayOf(DateCalendarManager.getPreviousDayFrom(this))
            
            self.updateAmountLabels()
            
            let comps = DateCalendarManager.getComponentsFrom(date: prevDay)
            
            self.updatePeriodLabel(period: "\(comps.day) \(DateCalendarManager.months[comps.month]!)")
            
        }
        
        self.tableView?.reloadData()
    }
    
    
    
    
    
    @IBAction func rightArrowPressed(sender: AnyObject) {
        
        self.handleGoForwardHistory()
        
        if self.stackOfPeriods.isEmpty() {
            self.rightArrowButton?.hidden = true
            self.isInPast = false
        }
        
        if self.isInPast {
            self.changePeriodButton?.hidden = true
            self.showLastButton?.hidden = false
        } else {
            self.changePeriodButton?.hidden = false
            self.showLastButton?.hidden = true
        }
        
        
    }
    
    
    func handleGoForwardHistory() {
        
        switch (self.showingBy) {
        case .month:
            
            if let month = self.stackOfPeriods.pop() {
                self.viewingMonth = month.1
                self.configureOperations(fromDate: month.0, toDate: month.1)
                
                let monthDate = DateCalendarManager.getMonthName(fromDate: month.1)
                self.updatePeriodLabel(period: "1 \(monthDate.month) - \(monthDate.lastDay) \(monthDate.month)")
                
            }

            
            
        case .week: break
            
            
        case .day:
            if let day = self.stackOfPeriods.pop() {
                self.viewingMonth = day.0
                self.configureOperations(fromDate: day.1, toDate: day.0)
                
                let comps = DateCalendarManager.getComponentsFrom(date: day.0!)
                
                self.updatePeriodLabel(period: "\(comps.day) \(DateCalendarManager.months[comps.month]!)")
            }
        }
        
        self.updateAmountLabels()
        self.tableView?.reloadData()
    }
    
    
    

    
    @IBAction func changePeriodButtonPressed(sender: UIButton) {
        
        switch (sender.titleLabel!.text!) {
//            case "By Month":
//                sender.setTitle("By Week", forState: UIControlState.Normal)
//            
            
            case "By Month":
                self.showingBy = .day
                sender.setTitle("By Day", forState: .Normal)
                let date = NSDate()
                let period = DateCalendarManager.getDayPeriod(date)
                
                let comps = DateCalendarManager.getComponentsFrom(date: date)
                
                self.updatePeriodLabel(period: "\(comps.day) \(DateCalendarManager.months[comps.month]!)")
                
                self.allOperations.removeAll()
                self.configureOperations(fromDate: period.begin, toDate: period.end)
                self.updateAmountLabels()
                self.tableView?.reloadData()
            
            
            
            case "By Day":
                self.showingBy = .month
                sender.setTitle("By Month", forState: .Normal)
            
                self.viewingMonth = DateCalendarManager.getStartOfMonth(date: NSDate())

                
                let day_month_interval = DateCalendarManager.getCurrentDate()
                
                self.updatePeriodLabel(period: "1 \(day_month_interval.month) - \(day_month_interval.dayNumber) \(day_month_interval.month)")
                
                self.allOperations.removeAll()
                self.configureOperations(fromDate: self.viewingMonth)
                self.updateAmountLabels()
                self.tableView?.reloadData()
                
                self.viewingMonth = NSDate()
            
            
            
            
        default: break
        }
        
    }
    
    
    
    @IBAction func showLastPressed(sender: AnyObject) {
        
        while (self.stackOfPeriods.count > 1) {
            self.stackOfPeriods.pop()
        }
        
        self.handleGoForwardHistory()
        
        self.showLastButton?.hidden = true
        self.rightArrowButton?.hidden = true
        self.changePeriodButton?.hidden = false
        
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
