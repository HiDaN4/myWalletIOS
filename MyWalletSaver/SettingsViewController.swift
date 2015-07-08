//
//  SettingsViewController.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 6/24/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit

protocol HolderDelegate {
    func setWalletValues(details: [String: String]?)
}

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var rightButton: UIButton!

    @IBOutlet weak var currencyField: UITextField!
    
    var holderDelegate: HolderDelegate?
    
    var currencyPicker: UIPickerView = UIPickerView()
    var currentSymbol: String!
    
    let currencies = ["$", "€", "£", "₽"]
    
    var didChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.currencyField.delegate = self
        
        self.configureView()
        
        self.rightButton.addTarget(self, action: Selector("rightButtonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if didChange {
            
            let details = [
                "currency": self.currencyField.text!
            ]
            holderDelegate?.setWalletValues(details)
        }
    }
    
    
    func configureView() {
        
        self.currencyPicker.delegate = self
        self.currencyPicker.dataSource = self
        
        self.currencyField.inputView = self.currencyPicker
        
        let toolbar = UIToolbar()
        toolbar.barStyle = UIBarStyle.Default
        toolbar.translucent = true
        toolbar.tintColor = UIColor.greenColor()
        toolbar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelPicker:"))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("donePicker:"))
        
        toolbar.setItems([cancelButton, space, doneButton], animated: false)
        toolbar.userInteractionEnabled = true
        
        self.currencyField.inputAccessoryView = toolbar
        
        self.currencyField.text = self.currentSymbol
    }
    
    func rightButtonPressed(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Picker Methods
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return currencies[row]
    }
    
    
    // MARK: - Function Helpers
    
    func donePicker(sender: AnyObject!) {
        let index = self.currencyPicker.selectedRowInComponent(0)
        
        self.didChange = self.currentSymbol != currencies[index] ? true : false
        
        self.currencyField.text = currencies[index]
        
        self.currencyField.resignFirstResponder()
    }
    
    
    func cancelPicker(sender: AnyObject!) {
        self.currencyField.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
