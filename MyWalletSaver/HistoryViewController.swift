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
    
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var allOperations: [Operation] = [Operation]()
    
    let reuseIdentifier = "Cell"
    
    static let months = [1: "January", 2:"February", 3:"March", 4:"April", 5:"May", 6:"June", 7:"July", 8:"August", 9:"September", 10:"October", 11:"November", 12: "December"]
    
    @IBOutlet weak var periodLabel: UILabel?
    
    @IBOutlet weak var totalExpenseLabel: UILabel?
    @IBOutlet weak var totalIncomeLabel: UILabel?
    
    var totalExpense: Double = 0.0
    var totalIncome: Double = 0.0
    
    
    @IBOutlet var currencySymbolLabel: [UILabel]?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.registerNib(UINib(nibName: "OperationTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        
//        self.edgesForExtendedLayout = UIRectEdge.None
//        self.extendedLayoutIncludesOpaqueBars = false
//        self.automaticallyAdjustsScrollViewInsets = false
//        self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        if self.tableView?.respondsToSelector(Selector("setLayoutMargins:")) == true {
            self.tableView?.layoutMargins = UIEdgeInsetsZero
        }
        
//        self.tableView.backgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1)
        
//        self.tableView.rowHeight = 55
        
//        if self.tableView.respondsToSelector(Selector("setLayoutMargins:")) == true {
//            self.tableView.layoutMargins = UIEdgeInsetsZero
//        }
        
//        configureOperations()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let day_month = self.getCurrentDate()
        self.updatePeriodLabel(period: "1 \(day_month.1) - \(day_month.0) \(day_month.1)")
        
        self.configureOperations()
        self.updateAmountLabels()
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        self.allOperations.removeAll(keepCapacity: true)
        self.tableView.reloadData()
    }
    
    
    // MARK: - Functions
    
    func configureOperations() {
        
        self.allOperations = filter(self.allOperations) {!$0.fault}
        
        let request = NSFetchRequest(entityName: "Operation")
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        request.sortDescriptors = [sortDescriptor]
        let predicate = NSPredicate(format: "NOT(SELF in %@)", allOperations)
        
        request.predicate = predicate
        
        var error: NSError?
        if let results = managedObjectContext.executeFetchRequest(request, error: &error) as? [Operation] {
            
            if results.count > 0 {
                
                if self.allOperations.count == 0 {
                    self.allOperations.extend(results)
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
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let doneButton = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(doneButton)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        var income = 0.0
        var expense = 0.0
        for operation in self.allOperations {
            let amount = operation.amount
            let symbol = operation.currency
            if symbol != self.currencySymbolLabel?[0].text { continue }
            
            if amount > 0 {
                income += amount
            } else {
                expense += amount
            }
        }

        self.totalIncome = income
        self.totalExpense = expense
        
    }
    
    
    
    
    func addAmount(#amount: Double, inout toVariable: Double) {
        toVariable += amount
    }
    
    
    
    
    func getCurrentDate() -> (Int, String) {
        
        
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit, fromDate: NSDate())
        let dayNum = components.day
        let monthNum: Int = components.month
        
        return (dayNum, HistoryViewController.months[monthNum]!)
        
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
    
    
    
    func updatePeriodLabel(#period: String) {
        
        self.periodLabel?.text = "Period: " + period
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
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 25.0
//    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.contentView.backgroundColor = tableView.backgroundColor
        
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
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DraggableOperationTableViewCell
        
        let row = indexPath.row
        let operation = self.allOperations[row]
        let amount = operation.amount
        let currency_symbol = operation.currency
        
        let fraction = floor(amount) == amount && !amount.isInfinite ? "0" : "2"
        let format = amount > 0 ? "\(currency_symbol)+%.\(fraction)f" : "\(currency_symbol)%.\(fraction)f"

        
        cell.configure(String(format: format, amount), categoryImage: self.appDelegate.textures[operation.category], walletName: "\(operation.wallet.name)", date: NSDate(timeIntervalSinceReferenceDate: operation.timestamp))
        
        cell.delegate = self
        cell.operation = operation
        
        cell.setCellColor(UIColor.clearColor())
        cell.setLabelColor(UIColor.whiteColor())

        cell.selectionStyle = .None
        
        cell.textOnSwipe = "Remove"

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
        if !managedObjectContext.save(&error) {
            println("Error saving Core Data after deleting relation: \(error?.localizedDescription)")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
