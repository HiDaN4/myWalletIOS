//
//  SettingsViewController.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 6/24/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit

protocol HolderDelegate {
    var currentCurrency: String {get}
    func setWalletValues(details: [String: String]?)
}



class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var rightButton: UIButton?

    @IBOutlet weak var currencyField: UITextField?
    
    @IBOutlet weak var tableView: UITableView?
    
    let reuseIdentifier = "Cell"
    
    
    var holderDelegate: HolderDelegate?
    
    var currentSymbol: String!
    
    var didChange = false
    
    let dataToPresent = [["GENERAL", "Currency", "Passcode"], ["DATA", "Delete All Data"], ["INFO", "About"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.currencyField.delegate = self
        
//        self.configureView()
        
        self.rightButton?.addTarget(self, action: Selector("rightButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        // Do any additional setup after loading the view.
        
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        
        self.view.backgroundColor = kkbackgroundColor
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if didChange {
//            let text = self.currencyField!.text!
//            let lchar = Array(text).last!
//            let details = [
//                "currency": String(lchar)
//            ]
//            holderDelegate?.setWalletValues(details)
//        }
//    }
    
    
//    func configureView() {
//        
//        self.currencyPicker.delegate = self
//        self.currencyPicker.dataSource = self
//        
//        self.currencyField?.inputView = self.currencyPicker
//        
//        let toolbar = UIToolbar()
//        toolbar.barStyle = UIBarStyle.Default
//        toolbar.translucent = true
//        toolbar.tintColor = UIColor.blueColor()
//        toolbar.sizeToFit()
//        
//        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelPicker:"))
//        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
//        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("donePicker:"))
//        
//        toolbar.setItems([cancelButton, space, doneButton], animated: false)
//        toolbar.userInteractionEnabled = true
//        
//        self.currencyField?.inputAccessoryView = toolbar
//        
//        self.currencyField?.text = self.currentSymbol
//    }
    
    
    
    func rightButtonPressed(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Table View Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataToPresent.count
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataToPresent[section].count - 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.dataToPresent[section][0]
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(r: 43, g: 70, b: 85, a: 1)
        
        header.textLabel.textColor = UIColor.whiteColor()
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! UITableViewCell
        
        let section = indexPath.section
        let row = indexPath.row
        let text = self.dataToPresent[section][row+1]
        cell.textLabel?.text = text
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        let bview = UIView(frame: CGRect(origin: cell.frame.origin, size: cell.frame.size))
        bview.backgroundColor = UIColor(r: 43, g: 70, b: 85, a: 1)
        cell.selectedBackgroundView = bview
        
        return cell
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView?.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cellData = self.dataToPresent[indexPath.section][indexPath.row + 1]
        
        var vc: UIViewController?
        
        switch cellData {
            case "Currency":
                if let detailTableVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailTableVC") as? DetailTableViewController {
                    
                    let currencies = ["Dollar $", "Euro €", "Pound £", "Ruble ₽"]
                    
                    detailTableVC.titleText = "Choose Currency"
                    detailTableVC.dataToPresent = currencies
                    detailTableVC.holderDelegate = self.holderDelegate
                    
                    vc = detailTableVC
            }
            
            case "Passcode":
                if let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailVC") as? DetailViewController {
                    
                    detailVC.titleText = "Passcode"
                    detailVC.textToShow = "Passcode"
                    
                    vc = detailVC
            }
            
            case "About":
                if let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("detailVC") as? DetailViewController {
                    detailVC.titleText = "About"
                    detailVC.textToShow = "Created By Independed Developer: Dmitry Sokolov\n\n Folow:\n\n @nazik78"
                    
                    vc = detailVC
            }
            
            case "Delete All Data":
                let title = "Warning!"
                let message = "Are you sure you want to delete all data?"
                if objc_getClass("UIAlertController") != nil {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
                        if let delegate = self.holderDelegate {
                            delegate.setWalletValues(["deleteAll": "Yes"])
                        }
                        
                        
                    })
                    
                    let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
                    
                    
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "No", otherButtonTitles: "Yes")
                    
            }
        default:
            break
        }
        if vc != nil {
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
    
    
    // MARK: - Picker Methods
    
    
//    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return currencies.count
//    }
//    
//    
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
//        return currencies[row]
//    }
    
    
    // MARK: - Function Helpers
    
//    func donePicker(sender: AnyObject!) {
//        let index = self.currencyPicker.selectedRowInComponent(0)
//        
//        self.didChange = self.currentSymbol != currencies[index] ? true : false
//        
//        let text = currencies[index]
//        let lchar = Array(text).last!
//        self.currencyField?.text = String(lchar)
//        
//        self.currencyField?.resignFirstResponder()
//    }
//    
//    
//    func cancelPicker(sender: AnyObject!) {
//        self.currencyField?.resignFirstResponder()
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
