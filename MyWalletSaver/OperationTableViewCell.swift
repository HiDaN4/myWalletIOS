//
//  RecentOperationTableViewCell.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 6/29/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit

protocol OperationTableViewCellDelegate {
    func deleteItem(item: Operation)
}

class OperationTableViewCell: UITableViewCell {
    @IBOutlet weak var amountLabel: UILabel?
    @IBOutlet weak var fromWalletLabel: UILabel?
    @IBOutlet weak var timestampLabel: UILabel?
    
    let calendar = NSCalendar.currentCalendar()
    let dateFormatter = NSDateFormatter()
    
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var canBeDeleted = true
    
    var delegate: OperationTableViewCellDelegate?
    var operation: Operation?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.backgroundColor = UIColor.redColor()
        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func configure(amount: String, walletName: String, date: NSDate) {
//        self.backgroundColor = UIColor(red: 193.0/255.0, green: 189.0/255.0, blue: 183.0/255.0, alpha: 1)
        //self.backgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1)
        self.backgroundColor = UIColor(red: 25.0/255.0, green: 165.0/255.0, blue: 180.0/255.0, alpha: 1)
            //UIColor(red: 43.0/255.0, green: 70.0/255.0, blue: 77.0/255.0, alpha: 1)
        
        self.amountLabel?.text = amount
        self.fromWalletLabel?.text = walletName
        
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeZone = calendar.timeZone
        
        let timestamp = dateFormatter.stringFromDate(date)
        
        self.timestampLabel?.text = timestamp
        
        if self.respondsToSelector(Selector("setLayoutMargins:")) == true {
            self.layoutMargins = UIEdgeInsetsZero
        }
        
    }
    
    
    func setFontColor(color: UIColor) {
        
        self.amountLabel?.textColor = color
        self.fromWalletLabel?.textColor = color
        self.timestampLabel?.textColor = color
    }
    
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.Began {
            originalCenter = center
        }
        
        if recognizer.state == UIGestureRecognizerState.Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0 && canBeDeleted
            
        }
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            if !deleteOnDragRelease {
                UIView.animateWithDuration(0.3) {
                    self.frame = originalFrame
                    }
            } else {
                if delegate != nil && operation != nil {
                    delegate!.deleteItem(operation!)
                }
            }
        }
        
    }
    
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGesture.translationInView(superview!)
            
            if fabs(translation.x) > fabs(translation.y) && translation.x < 0 {
                return true
            }
            return false
            
        }
        return false
    }
    
    
    
}
