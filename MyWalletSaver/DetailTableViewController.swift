//
//  DetailTableViewController.swift
//  WalletTracker
//
//  Created by Dmitry Sokolov on 7/22/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit

class DetailTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView?
    
    @IBOutlet weak var titleLabel: UILabel?
    
    var titleText = ""
    
    let reuseIdentifier = "Cell"
    
    var dataToPresent = [""]
    
    var holderDelegate: HolderDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        if self.tableView?.respondsToSelector(Selector("setLayoutMargins:")) == true {
            if #available(iOS 8.0, *) {
                self.tableView?.layoutMargins = UIEdgeInsetsZero
            } else {
                // Fallback on earlier versions
            }
        }
        
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: 204.0/255.0, green: 104.0/255.0, blue: 39.0/255.0, alpha: 1)
        
        self.titleLabel?.text = self.titleText
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.navigationController?.navigationBar.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.dataToPresent.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) 

        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.text = self.dataToPresent[indexPath.row]
        
        cell.backgroundColor = UIColor.clearColor()
        
        cell.selectionStyle = UITableViewCellSelectionStyle.Gray
        
        let bview = UIView(frame: CGRect(origin: cell.frame.origin, size: cell.frame.size))
        bview.backgroundColor = UIColor(r: 43, g: 70, b: 85, a: 1)
        cell.selectedBackgroundView = bview

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let text = self.dataToPresent[indexPath.row]
        let lchar = Array(text.characters).last!
        if let currentCurrency = holderDelegate?.currentCurrency {
            if Character(currentCurrency) != lchar {
                let details = [
                    "currency": String(lchar)
                ]
                holderDelegate?.setWalletValues(details)
                let time: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
                dispatch_after(time, dispatch_get_main_queue(), { () -> Void in
                    self.backButtonPressed(self)
                })
                
            } else {
                self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
