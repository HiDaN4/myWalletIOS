//
//  FirstViewController.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 6/21/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, HolderDelegate, OperationTableViewCellDelegate {
    
    //MARK: - Properties

    @IBOutlet weak var balanceLabel: UILabel?
    @IBOutlet var currencyLabels: [UILabel]?

    @IBOutlet weak var cashBalanceLabel: UILabel?
    @IBOutlet weak var cardsBalanceLabel: UILabel?
    @IBOutlet weak var sourceSegmentedControl: UISegmentedControl?

    @IBOutlet weak var inputField: UITextField?
    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet weak var expenseButton: UIButton?
    @IBOutlet weak var incomeButton: UIButton?
    
    
    @IBOutlet var categoryButtons: [CustomCirclularButton]?
    var currentCategory: CustomCirclularButton?
    
    
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var holders: [Holder]!
    var current_holder: Holder!
    
    var operations = [Operation]()
    
    var refreshControl: UIRefreshControl!
    
    //MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureWallets()
        
        if let buttons = self.categoryButtons {
            var i = 500
            self.currentCategory = buttons[0]
            for button in buttons {
                button.tag = i++
                button.addTarget(self, action: Selector("categoryButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        self.inputField?.delegate = self
        
//        self.refreshControl = UIRefreshControl()
//        
//        self.refreshControl.backgroundColor = UIColor.greenColor()
//        
//        self.refreshControl.addTarget(self, action: Selector("reloadTV"), forControlEvents: UIControlEvents.ValueChanged)
//        
//        self.tableView.addSubview(refreshControl)
        
//        self.tableView.registerClass(RecentOperationTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        self.tableView?.registerNib(UINib(nibName: "OperationTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        self.tableView?.rowHeight = 55
        
        if self.tableView?.respondsToSelector(Selector("setLayoutMargins:")) == true {
            self.tableView?.layoutMargins = UIEdgeInsetsZero
        }

        
        self.sourceSegmentedControl?.hidden = true

//        self.tableView?.backgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1)
        
        self.tableView?.backgroundColor = UIColor(red: 25.0/255.0, green: 165.0/255.0, blue: 180.0/255.0, alpha: 1)
        
        // Do any additional setup after loading the view, typically from a nib.
        
        UITabBar.appearance().barTintColor = self.view.backgroundColor
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
    }
    
    
    
    func configureWallets() {
        
        let request = NSFetchRequest(entityName: "Holder")
        
        if let results = managedObjectContext.executeFetchRequest(request, error: nil) as? [Holder] {
            
            if results.count > 1 {
                holders = results
                
                if holders[0].name != "Cash" {
                    swap(&holders[0], &holders[1])
                }
                
                for holder in holders {
                    var items = holder.operations.allObjects as! [Operation]
                    
                    operations.extend(items)
                }
                if operations.count > 2 {
                    operations.sort({ (operation1: Operation, operation2: Operation) -> Bool in
                        return operation1.timestamp > operation2.timestamp
                    })
                    
                    if operations.count > 10 {
                        operations.removeRange(Range<Int>(start: 10, end: operations.count))
                    }
                }
                
                
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
                cards_hold.currency_smbl = "$"
                
                holders.append(cards_hold)
                
                var error: NSError?
                managedObjectContext.save(&error)
            }
        }
        
        self.updateCurrencyLabels(holders[0].currency_smbl)
        self.showBalanceForAllHolders()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showBalanceForAllHolders()
        
        self.operations = self.operations.filter {$0.timestamp != 0}
        
       // self.tableView?.reloadData()
    }
    
    //MARK: - Table View Data Source
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operations.count
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    // MARK: - Table View Delegate
    
    func reloadTV() {
        println("Reload")
        
        self.refreshControl.endRefreshing()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView?.dequeueReusableCellWithIdentifier("Cell") as! DraggableOperationTableViewCell
        
        let index = indexPath.row
        let operation = self.operations[index]
        let amount = self.operations[index].amount
        let currency_symbol = operation.currency
        let fraction = floor(amount) == amount && !amount.isInfinite ? "0" : "2"
        let format = amount > 0 ? "\(currency_symbol)+%.\(fraction)f" : "\(currency_symbol)%.\(fraction)f"

        let date = NSDate(timeIntervalSinceReferenceDate: self.operations[index].timestamp)
        
        cell.configure(String(format: format, amount), categoryImage: self.appDelegate.textures[operation.category], walletName: operation.wallet.name, date: date)
        
        cell.delegate = self
        cell.operation = operation
        
        cell.selectionStyle = .None
        
        cell.setCellColor(UIColor(red: 25.0/255.0, green: 165.0/255.0, blue: 180.0/255.0, alpha: 1))
        cell.setLabelColor(UIColor.whiteColor())
        
        cell.textOnSwipe = "Remove"
        
        return cell
    }
    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
    
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == UITableViewCellEditingStyle.Delete {
//            self.tableView.beginUpdates()
//            let operation = self.operations[indexPath.row]
//            
//            if operation.amount > 0 {
//                operation.wallet.totalIncome -= operation.amount
//            } else {
//                operation.wallet.totalExpense -= operation.amount
//            }
//
//            managedObjectContext.deleteObject(operation)
//            
//            managedObjectContext.processPendingChanges()
//            var error: NSError?
//            if !managedObjectContext.save(&error) {
//                println("Error saving Core Data after deleting relation: \(error?.localizedDescription)")
//            }
//            
//            self.showBalanceForAllHolders()
//            
//            self.operations.removeAtIndex(indexPath.row)
//            
//            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
//            
//            self.tableView.endUpdates()
//            
//        }
//    }
    
    
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
    
//        var shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Share") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
//            
//            println("\(action.style.rawValue)")
//            
//        }
//        
//        shareAction.backgroundColor = UIColor.blueColor()
//        
//        var deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
//            
//            self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
//        }
//        
//        return [deleteAction]
//    }
    
    
    
    // iOS 7
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    
    //MARK: - Buttons
    
    @IBAction func incomeButtonPressed(sender: AnyObject) {
        println("Income pressed")
        if self.checkInput() {
            createRecordInCoreData((inputField!.text as NSString).doubleValue)
            inputField!.text = ""
        }
    }
    
    
    @IBAction func expenseButtonPressed(sender: AnyObject) {
        println("Expense pressed")
        if self.checkInput() {
            createRecordInCoreData(0 - (inputField!.text as NSString).doubleValue)
            inputField!.text = ""
        }
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        self.tapped()
        return false
    }
    
    
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
        
        self.tableView?.addGestureRecognizer(touch)
        
        let sender = sender as! UITextField
        
        println("\(sender.frame.height)")
        
        self.sourceSegmentedControl?.hidden = false
        
        changeAppearanceOfCategoryButtons(hidden: false)
        
        if let buttons = self.categoryButtons {
            var i: CGFloat = 0
            for button in buttons {
                button.frame.origin.x = 0 - button.frame.width - i
                i += 8 + button.frame.width
            }
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layer.frame.offset(dx: 0, dy: CGFloat(-sender.frame.height*6 - 20))
            
        })
        
        UIView.animateWithDuration(0.7) {
            if let buttons = self.categoryButtons {
                var i: CGFloat = 0
                for button in buttons {
                    button.frame.origin.x = 10 + i
                    i += 8 + button.frame.width
                }
            }
        }
        
        
    }
    
    
    
    // is not used
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
    
    
    
    func categoryButtonPressed(button: UIButton?) {
        if let pressedButton = button as? CustomCirclularButton {
            
            if pressedButton.strokeColor != UIColor.greenColor() {
                
                self.currentCategory?.strokeColor = pressedButton.strokeColor
                self.currentCategory?.setNeedsDisplay()
                
//                if let buttons = self.categoryButtons {
//                    for cbutton in buttons {
//                        if cbutton != pressedButton {
//                            cbutton.strokeColor = UIColor.whiteColor()
//                            cbutton.setNeedsDisplay()
//                        }
//                    }
//                }
                
                self.currentCategory = pressedButton
                pressedButton.strokeColor = UIColor.greenColor()
                pressedButton.setNeedsDisplay()
            }
        }
    }

    
    //MARK: - Helper functions
    
    
    func checkInput() -> Bool {
        
        let empty = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let ddigits = NSCharacterSet(charactersInString: "1234567890.")
        let text = self.inputField!.text
        if text.stringByTrimmingCharactersInSet(empty) == "" || text.stringByTrimmingCharactersInSet(ddigits) != "" || text == "0" {
            self.inputField!.text = "0"
            return false
        }
        
        return true
    }
    
    
    
    
    
    func showBalanceForAllHolders() {
        
        var value: Double = 0
        var fraction: String = ""
        var format: String = ""
        
        for wallet in holders {
            value += wallet.totalIncome + wallet.totalExpense
        }
        
        fraction = floor(value) == value && !value.isInfinite ? "0" : "2"
        format = value > 0 ? "%.\(fraction)f" : "%.\(fraction)f"
        self.balanceLabel?.text = String(format: format, value)
        
        value = holders[0].totalIncome + holders[0].totalExpense
        fraction = floor(value) == value && !value.isInfinite ? "0" : "2"
        format = value > 0 ? "%.\(fraction)f" : "%.\(fraction)f"
        self.cashBalanceLabel?.text = String(format: format, value)
        
        value = holders[1].totalIncome + holders[1].totalExpense
        fraction = floor(value) == value && !value.isInfinite ? "0" : "2"
        format = value > 0 ? "%.\(fraction)f" : "%.\(fraction)f"
        self.cardsBalanceLabel?.text = String(format: format, value)
    }
    
    
    func updateCurrencyLabels(symbol: String) {
        
        if let labels = currencyLabels {
            for clabel in labels {
                clabel.text = symbol
            }
        }
        
    }
    
    
    func createRecordInCoreData(amount: Double) {
        
        let current_wallet = holders[self.sourceSegmentedControl!.selectedSegmentIndex]
        
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Operation", inManagedObjectContext: managedObjectContext) as! Operation
        
        newItem.amount = amount
        
        newItem.timestamp = NSDate().timeIntervalSinceReferenceDate
        
        newItem.wallet = current_wallet
        
        newItem.currency = current_wallet.currency_smbl
        
        println("Control: \(self.sourceSegmentedControl!.selectedSegmentIndex)")
        
        var operations_ = current_wallet.operations.mutableCopy() as! NSMutableSet
        operations_.addObject(newItem)
        
        if amount > 0 {
            current_wallet.totalIncome += amount
        } else {
            current_wallet.totalExpense += amount
        }
        
        var category = ""
        if let tag = self.currentCategory?.tag {
            switch tag {
            case 500:
                category = "Food"
            case 501:
                category = "Entertainment"
            case 502:
                category = "General"
            default:
                break
            }
        }
        
        newItem.category = category
        
        self.operations.insert(newItem, atIndex: 0)
        
        if self.operations.count == 11 {
            self.operations.removeLast()
        }
        
        var error: NSError?
        
        managedObjectContext.save(&error)
        
        self.showBalanceForAllHolders()
        
        self.tableView?.reloadData()
        
    }
    
    
    
    func tapped() {
        self.tableView?.gestureRecognizers?.removeLast()
        
        changeAppearanceOfCategoryButtons(hidden: true)
        
        self.sourceSegmentedControl?.hidden = true
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.view.layer.frame.offset(dx: 0, dy: CGFloat(30*6 + 20))
        })
        
        
        self.inputField?.resignFirstResponder()
    }
    
    
    
    
    func changeAppearanceOfCategoryButtons(#hidden: Bool) {
        
        if let buttons = self.categoryButtons {
            for button in buttons {
                button.hidden = hidden
            }
        }
        
    }
    
    
    
    // MARK: - Custom Delegates
    
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
    
    func deleteItem(item: Operation) {
        let operation = item
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
        
        let index = (self.operations as NSArray).indexOfObject(operation)
        
        if index == NSNotFound { return }
        
        
        self.operations.removeAtIndex(index)
        
        
        self.tableView?.beginUpdates()
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView?.endUpdates()
        
        
    }
    

}

