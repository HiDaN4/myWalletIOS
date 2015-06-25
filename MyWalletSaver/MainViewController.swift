//
//  FirstViewController.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 6/21/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Properties

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var holder: Holder!
    
    
    //MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSFetchRequest(entityName: "Holder")
        
        if let results = managedObjectContext.executeFetchRequest(request, error: nil) as? [Holder] {
            
            if results.count > 0 {
                holder = results[0]
            } else {
                let hold = NSEntityDescription.insertNewObjectForEntityForName("Holder", inManagedObjectContext: managedObjectContext) as! Holder
                
                holder = hold
                
                hold.name = "Main"
                hold.unique_id = 01
                
                var error: NSError?
                managedObjectContext.save(&error)
            }
        }
        
        
        let value = 0 - holder.totalExpense
        
        
        self.balanceLabel.text = String(format: "%.2f", value)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: - Buttons
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        println("Save pressed")
        createRecordInCoreData("Expense")
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @IBAction func rightButtonPressed(sender: AnyObject) {
        let settings = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsVC") as? SettingsViewController
        
        if let vs = settings {
            self.presentViewController(vs, animated: true, completion: nil)
        }
    }
    
    
    func createRecordInCoreData(type: String) {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Operation", inManagedObjectContext: managedObjectContext) as! Operation
        
        newItem.amount = (inputField.text as NSString).doubleValue
        
        newItem.timestamp = NSDate().timeIntervalSinceReferenceDate
        
        newItem.wallet = holder
        
        
        switch type {
        case "Expense":
            print("Expense")
            var operations_ = holder!.expenses.mutableCopy() as! NSMutableSet
            operations_.addObject(newItem)
            
            holder.expenses = NSSet(set: operations_ as NSSet)
            holder.totalExpense += newItem.amount
            
        case "Income":
            var operations_ = holder!.incomes.mutableCopy() as! NSMutableSet
            operations_.addObject(newItem)
            
            holder.incomes = NSSet(set: operations_ as NSSet)
            holder.totalIncome += newItem.amount
            
        default:
            print("error switch")
        }
        
        
        var error: NSError?
        
        managedObjectContext.save(&error)
        
        let value = holder.totalIncome - holder.totalExpense
        
        
        self.balanceLabel.text = String(format: "%.2f", value)
        
    }

}

