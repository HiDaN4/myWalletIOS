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
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    func configure(amount: String, walletName: String, date: NSDate) {
        
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
    
    func setCellColor(color: UIColor) {
        self.backgroundColor = color
    }
    
    
    func setLabelColor(color: UIColor) {
        
        self.amountLabel?.textColor = color
        self.fromWalletLabel?.textColor = color
        self.timestampLabel?.textColor = color
    }
    
}


class DraggableOperationTableViewCell: OperationTableViewCell {
    
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var canBeDeleted = true
    var onDeleteView: UIView?
    
    var delegate: OperationTableViewCellDelegate?
    var operation: Operation?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.Began {
            originalCenter = center
            println("Begin")
            println("\(self.onDeleteView?.description)")
            if self.onDeleteView == nil {
                println("Creating: \(frame.origin.y)")
                self.onDeleteView = UIView(frame: CGRectMake(self.frame.origin.x + self.frame.width, 0, 0, self.frame.height))
                
                self.onDeleteView?.backgroundColor = UIColor(red: 249.0/255.0, green: 61.0/255.0, blue: 0, alpha: 1)
                
                self.addSubview(onDeleteView!)
                
            }
            
            
        }
        
        if recognizer.state == UIGestureRecognizerState.Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            self.onDeleteView?.frame.size.width = translation.x
            self.onDeleteView?.frame.origin.x = self.bounds.width
            
            
        }
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            if !deleteOnDragRelease {
                UIView.animateWithDuration(0.3) {
                    self.frame = originalFrame
                    self.onDeleteView?.frame.size.width = 0
                }
                
            } else {
                if delegate != nil && operation != nil {
                    delegate!.deleteItem(operation!)
                }
                self.onDeleteView?.removeFromSuperview()
                self.onDeleteView = nil
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

