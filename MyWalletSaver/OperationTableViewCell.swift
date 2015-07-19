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


class DraggableTableViewCell : OperationTableViewCell {
    
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    
    var onDeleteView: UIView?
    var swipeLeftLabel: UILabel?
    
    var activeFullSwipeLeftColor: UIColor?
    var inactiveSwipeLeftColor: UIColor?
    
    var textOnSwipe: String = "Action" {
        didSet {
            self.swipeLeftLabel?.text = textOnSwipe
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    
    private func createCView() {
        
        self.onDeleteView = UIView(frame: CGRectMake(self.frame.origin.x + self.frame.width, 0, 0, self.frame.height))
        
        if let color = self.inactiveSwipeLeftColor {
            self.onDeleteView?.backgroundColor = color
        } else {
            self.inactiveSwipeLeftColor = UIColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1)
            self.onDeleteView?.backgroundColor = self.inactiveSwipeLeftColor
        }
        
        if self.activeFullSwipeLeftColor == nil {
            self.activeFullSwipeLeftColor = UIColor(red: 249.0/255.0, green: 61.0/255.0, blue: 0, alpha: 1)
        }
        
        
        self.swipeLeftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 80, height: self.onDeleteView!.frame.height))
        self.swipeLeftLabel?.adjustsFontSizeToFitWidth = true
        
        self.swipeLeftLabel?.textColor = UIColor.whiteColor()
        self.swipeLeftLabel?.textAlignment = NSTextAlignment.Center
        self.swipeLeftLabel?.font = UIFont(name: "Avenir", size: 15.0)
        self.swipeLeftLabel?.text = self.textOnSwipe
        
        
        self.addSubview(onDeleteView!)
        self.onDeleteView!.addSubview(self.swipeLeftLabel!)
        
    }
    
    
    
    
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == UIGestureRecognizerState.Began {
            originalCenter = center
            
            if self.onDeleteView == nil {
                self.createCView()
            }
            
            
        }
        
        if recognizer.state == UIGestureRecognizerState.Changed {
            let translation = recognizer.translationInView(self)
            
            if abs(translation.x) < self.bounds.width / 3.0  {
                center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
                
                deleteOnDragRelease = frame.origin.x < -frame.size.width / 4.0
                
                self.onDeleteView?.frame.size.width = translation.x
                self.onDeleteView?.frame.origin.x = self.bounds.width
                
                if deleteOnDragRelease {
                    self.onDeleteView?.backgroundColor = self.activeFullSwipeLeftColor
                } else {
                    self.onDeleteView?.backgroundColor = self.inactiveSwipeLeftColor
                }
                
                self.swipeLeftLabel?.frame.size.height = self.onDeleteView!.frame.height
                self.swipeLeftLabel?.frame.size.width = abs(self.onDeleteView!.frame.width)
                
                //                self.onDeleteView?.layoutIfNeeded()
                //                self.swipeLeftLabel?.layoutIfNeeded()
                
            }
            
        }
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            
            if !deleteOnDragRelease {
                UIView.animateWithDuration(0.3) {
                    self.frame = originalFrame
                    self.onDeleteView?.frame.size.width = 0
                }
                
            } else {
                self.onDeleteCell()
            }
        }
        
    }
    
    
    
    
    func onDeleteCell() {
        self.swipeLeftLabel?.removeFromSuperview()
        self.swipeLeftLabel = nil
        self.onDeleteView?.removeFromSuperview()
        self.onDeleteView = nil
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





class DraggableOperationTableViewCell: DraggableTableViewCell {
    
    var delegate: OperationTableViewCellDelegate?
    var operation: Operation?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func onDeleteCell() {
        super.onDeleteCell()
        
        if delegate != nil && operation != nil {
            delegate!.deleteItem(operation!)
        }
    }
    
    
}


