//
//  HistoryTableViewController.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 7/9/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController, OperationTableViewCellDelegate {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var allOperations: [Operation] = [Operation]()
    
    let reuseIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "OperationTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        
//        self.edgesForExtendedLayout = UIRectEdge.None
//        self.extendedLayoutIncludesOpaqueBars = false
//        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        self.tableView.backgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1)
        
        self.tableView.rowHeight = 55
        
//        configureOperations()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureOperations()
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
                    return
                }
                
                for var count = results.count - 1; count >= 0; --count {
                    self.allOperations.insert(results[count], atIndex: 0)
                }
                
//                self.allOperations.extend(results)
//                self.allOperations.sort {$0.timestamp>$1.timestamp}
                
            }
            
            
        } else {
            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let doneButton = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(doneButton)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.allOperations.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! RecentOperationTableViewCell        // Configure the cell...
        
        let row = indexPath.row
        let operation = self.allOperations[row]
        
        cell.configure("\(operation.currency)\(operation.amount)", walletName: "\(operation.wallet.name)", date: NSDate(timeIntervalSinceReferenceDate: operation.timestamp))
        
        cell.delegate = self
        cell.operation = operation
        
        cell.selectionStyle = .None

        return cell
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
        
        
        let index = (self.allOperations as NSArray).indexOfObject(operation)
        
        if index == NSNotFound { return }
        
        
        self.allOperations.removeAtIndex(index)
        
        self.tableView?.beginUpdates()
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView?.endUpdates()
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
