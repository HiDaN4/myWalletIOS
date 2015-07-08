//
//  FirstViewController.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 6/21/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, HolderDelegate {
    

    //MARK: - Properties

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!

    @IBOutlet weak var cashBalanceLabel: UILabel!
    @IBOutlet weak var cardsBalanceLabel: UILabel!
    @IBOutlet weak var sourceSegmentedControl: UISegmentedControl!

    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var expenseButton: UIButton!
    @IBOutlet weak var incomeButton: UIButton!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var holders: [Holder]!
    var current_holder: Holder!
    
    var operations = [Operation]()
    
    var refreshControl: UIRefreshControl!
    
    //MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSFetchRequest(entityName: "Holder")
        
        if let results = managedObjectContext.executeFetchRequest(request, error: nil) as? [Holder] {
            
            if results.count > 1 {
                holders = results
//                swap(&holders[0], &holders[1])
                
                for holder in holders {
                    var items = holder.operations.allObjects as! [Operation]
                    
//                    items.sort({ (op1 :Operation, op2: Operation) -> Bool in
//                        return op1.timestamp < op2.timestamp
//                    })
                    
//                    let items = nitems.sortedArrayUsingDescriptors([NSSortDescriptor(key: "timestamp", ascending: false)]) as! [Operation]
                    
                    operations.extend(items)
                }
               
                operations.sort({ (operation1: Operation, operation2: Operation) -> Bool in
                    return operation1.timestamp > operation2.timestamp
                })
                
                if operations.count > 10 {
                    operations.removeRange(Range<Int>(start: 10, end: operations.count))
                }
                
//                for item in results[0].expenses {
//                    operations.append(item as! Operation)
//                }
//                
//                for item in results[0].incomes {
//                    operations.append(item as! Operation)
//                }
                
                
            } else {
                holders = [Holder]()
                
                let hold = NSEntityDescription.insertNewObjectForEntityForName("Holder", inManagedObjectContext: managedObjectContext) as! Holder
                
                hold.name = "Cash"
                hold.unique_id = 01
                hold.created = NSDate().timeIntervalSinceReferenceDate
                hold.currency_smbl = "$"
                
               
                holders.append(hold)
                
                let cards_hold = NSEntityDescription.insertNewObjectForEntityForName("Holder", inManagedObjectContext: managedObjectContext) as! Holder
                
                cards_hold.name = "Debit"
                cards_hold.unique_id = 2
                cards_hold.created = NSDate().timeIntervalSinceReferenceDate
                
                holders.append(cards_hold)
                
                var error: NSError?
                managedObjectContext.save(&error)
            }
        }
        
        self.updateCurrencyLabels(holders[0].currency_smbl)
        self.showBalanceForAllHolders()
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.inputField.delegate = self
        
        self.refreshControl = UIRefreshControl()
        
        self.refreshControl.backgroundColor = UIColor.greenColor()
        
        self.refreshControl.addTarget(self, action: Selector("reloadTV"), forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refreshControl)
        
        self.tableView.registerNib(UINib(nibName: "RecentOperationTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        self.tableView.rowHeight = 55
        
        self.sourceSegmentedControl.hidden = true
//
        self.tableView.backgroundColor = UIColor(red: 43.0/255.0, green: 70.0/255.0, blue: 77.0/255.0, alpha: 1)
//        self.tableView.
        
        self.expenseButton.backgroundColor = UIColor.redColor()
//        self.expenseButton.layer.frame = CGRect(x: self.expenseButton.frame.origin.x, y: self.expenseButton.frame.origin.y, width: 60, height: 60)
        self.expenseButton.layer.cornerRadius = 0.5 * self.expenseButton.frame.width
        
        self.incomeButton.backgroundColor = UIColor.greenColor()
//        self.incomeButton.layer.frame = CGRect(x: self.incomeButton.frame.origin.x, y: self.incomeButton.frame.origin.y, width: 60, height: 60)
        self.incomeButton.layer.cornerRadius = 0.5 * self.incomeButton.frame.width
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.expenseButton.backgroundColor = UIColor.redColor()
//        self.expenseButton.layer.cornerRadius = 0.5 * self.expenseButton.frame.width
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table View
    
    func reloadTV() {
        println("Reload")
        
        self.refreshControl.endRefreshing()
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operations.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! RecentOperationTableViewCell
        
        let index = indexPath.row
        let operation = self.operations[index]
        let amount = self.operations[index].amount
        let format = amount > 0 ? "+%.2f" : "%.2f"

        let date = NSDate(timeIntervalSinceReferenceDate: self.operations[index].timestamp)
        
        cell.configure(String(format: format, amount), walletName: operation.wallet.name, date: date)
        
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.tableView.beginUpdates()
            let operation = self.operations[indexPath.row]
            
            if operation.amount > 0 {
                operation.wallet.totalIncome -= operation.amount
            } else {
                operation.wallet.totalExpense -= operation.amount
            }

            managedObjectContext.deleteObject(operation)
            
            managedObjectContext.processPendingChanges()
            var error: NSError?
            if !managedObjectContext.save(&error) {
                println("Error saving Core Data after deleting relation: \(error?.localizedDescription)")
            }
            
            self.showBalanceForAllHolders()
            
            self.operations.removeAtIndex(indexPath.row)
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            self.tableView.endUpdates()
            
        }
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Share") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            println("\(action.style.rawValue)")
            
        }
        
        shareAction.backgroundColor = UIColor.blueColor()
        
        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
            
            self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
        }
        
        return [deleteAction, shareAction]
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    
    //MARK: - Buttons
    
    @IBAction func incomeButtonPressed(sender: AnyObject) {
        println("Income pressed")
//        self.inputField.resignFirstResponder()
        if self.checkInput() {
            createRecordInCoreData((inputField.text as NSString).doubleValue)
            inputField.text = ""
        }
    }
    
    
    @IBAction func expenseButtonPressed(sender: AnyObject) {
        println("Expense pressed")
//        self.inputField.resignFirstResponder()
        if self.checkInput() {
            createRecordInCoreData(0 - (inputField.text as NSString).doubleValue)
            inputField.text = ""
        }
    }
    
    
    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        return false
//    }
    
    
    @IBAction func rightButtonPressed(sender: AnyObject) {
        let settings = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsVC") as? SettingsViewController
        
        if let vs = settings {
            vs.holderDelegate = self
            vs.currentSymbol = holders[0].currency_smbl
            self.presentViewController(vs, animated: true, completion: nil)
        }
    }
    
    @IBAction func didPressField(sender: AnyObject) {
        let touch = UITapGestureRecognizer(target: self, action: Selector("tapped"))
        touch.numberOfTouchesRequired = 1
        
        self.tableView.addGestureRecognizer(touch)
        
        let sender = sender as! UITextField
        
        println("\(sender.frame.height)")
        
        self.sourceSegmentedControl.hidden = false
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layer.frame.offset(dx: 0, dy: CGFloat(-sender.frame.height*6 - 20))
        })
        
        
    }
    
    
    
    @IBAction func sourceChosen(sender: AnyObject) {
        let sender = sender as! UISegmentedControl
        
        let value = sender.selectedSegmentIndex
        println("\(value)")
        switch value {
        case 0:
            break
        case 1:
            break
        default:
            break
        }
    }

    
    //MARK: - Helper functions
    
    
    func checkInput() -> Bool {
        
        let empty = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        let text = self.inputField.text
        if text.stringByTrimmingCharactersInSet(empty) == "" || text.stringByTrimmingCharactersInSet(digits) != "" || text == "0" {
            self.inputField.text = "0"
            return false
        }
        
        return true
    }
    
    
    
    
    
    func showBalanceForAllHolders() {
        
        var value: Double = 0
        for wallet in holders {
            value += wallet.totalIncome + wallet.totalExpense
        }
        
        var format = value > 0 ? "+%.2f" : "%.2f"
        self.balanceLabel.text = String(format: format, value)
        
        value = holders[0].totalIncome + holders[0].totalExpense
        format = value > 0 ? "+%.2f" : "%.2f"
        self.cashBalanceLabel.text = String(format: format, value)
        
        value = holders[1].totalIncome + holders[1].totalExpense
        format = value > 0 ? "+%.2f" : "%.2f"
        self.cardsBalanceLabel.text = String(format: format, value)
    }
    
    
    func updateCurrencyLabels(symbol: String) {
        
        for clabel in currencyLabels {
            clabel.text = symbol
        }
        
    }
    
    
    func createRecordInCoreData(amount: Double) {
        
        let current_wallet = holders[self.sourceSegmentedControl.selectedSegmentIndex]
        
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Operation", inManagedObjectContext: managedObjectContext) as! Operation
        
        newItem.amount = amount
        
        newItem.timestamp = NSDate().timeIntervalSinceReferenceDate
        
        newItem.wallet = current_wallet
        
        println("Control: \(self.sourceSegmentedControl.selectedSegmentIndex)")
        
        var operations_ = current_wallet.operations.mutableCopy() as! NSMutableSet
        operations_.addObject(newItem)
        
        if amount > 0 {
            current_wallet.totalIncome += amount
        } else {
            current_wallet.totalExpense += amount
        }
        
        self.operations.insert(newItem, atIndex: 0)
        
        if self.operations.count == 11 {
            self.operations.removeLast()
        }
        
        var error: NSError?
        
        managedObjectContext.save(&error)
        
        var value: Double = 0
        for wallet in holders {
            value += wallet.totalIncome + wallet.totalExpense
        }
        
        let format = value > 0 ? "+%.2f" : "%.2f"
        
        self.balanceLabel.text = String(format: format, value)
        
        self.showBalanceForAllHolders()
        
        self.tableView.reloadData()
        
    }
    
    
    
    func tapped() {
        self.tableView.gestureRecognizers?.removeLast()
        
        self.sourceSegmentedControl.hidden = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layer.frame.offset(dx: 0, dy: CGFloat(30*6 + 20))
        })
        
        
        self.inputField.resignFirstResponder()
    }
    
    
    func setWalletValues(details: [String : String]?) {
        if let dict = details {
            
            if let newCurrency = dict["currency"] {
                
                for wallet in holders {
                    wallet.currency_smbl = newCurrency
                    wallet.totalExpense = 0
                    wallet.totalIncome = 0
                }
                
                managedObjectContext.save(nil)
                
                self.updateCurrencyLabels(newCurrency)
                self.showBalanceForAllHolders()
                
            } // end if let newCurrency
        }
    }
    

}

