//
//  RecentOperationTableViewCell.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 6/29/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit

class RecentOperationTableViewCell: UITableViewCell {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var fromWalletLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    let calendar = NSCalendar.currentCalendar()
    let dateFormatter = NSDateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.backgroundColor = UIColor.redColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


        // Configure the view for the selected state
    }
    
    
    func configure(amount: String, walletName: String, date: NSDate) {
        self.backgroundColor = UIColor.blueColor()
        
        self.amountLabel.textColor = UIColor.whiteColor()
        self.fromWalletLabel.textColor = UIColor.whiteColor()
        self.timestampLabel.textColor = UIColor.whiteColor()
        
        self.amountLabel.text = amount
        self.fromWalletLabel.text = walletName
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeZone = calendar.timeZone
        
        let timestamp = dateFormatter.stringFromDate(date)

        
        self.timestampLabel.text = timestamp
    }
    
}
