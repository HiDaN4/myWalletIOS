//
//  CustomButton.swift
//  WalletTracker
//
//  Created by Dmitry Sokolov on 7/11/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit

@IBDesignable

class CustomCirclularButton: UIButton {
    
    @IBInspectable var strokeColor: UIColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1)
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        let path = UIBezierPath(ovalInRect: rect)
        
        // set fill color
        UIColor.clearColor().setFill()
        path.fill()
        
        // set stroke color
        self.strokeColor.setStroke()
        
        // line width
        path.lineWidth = 1.0
        
        // draw
        path.stroke()
        
    }
    

}



class CustomPushButton : CustomCirclularButton {
    
    @IBInspectable var lineColor: UIColor = UIColor.clearColor()
    @IBInspectable var isPlus: Bool = true
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // sign parameters
        let plusHeight: CGFloat = 3.0
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.6
        
        let plusPath = UIBezierPath()
        
        plusPath.lineWidth = plusHeight
        
        // horizontal line
        plusPath.moveToPoint(CGPoint(x: bounds.width/2 - plusWidth/2 + 0.5, y: bounds.height/2 + 0.5))
        
        plusPath.addLineToPoint(CGPoint(x: bounds.width/2 + plusWidth/2 + 0.5, y: bounds.height/2 + 0.5))
        
        // draw vertical line?
        if isPlus {
        plusPath.moveToPoint(CGPoint(x: bounds.width/2 + 0.5, y: bounds.height/2 - plusWidth/2 + 0.5))
        
        plusPath.addLineToPoint(CGPoint(x: bounds.width/2 + 0.5, y: bounds.height/2 + plusWidth/2 + 0.5))
            
        }
        
        // set line stroke color
        self.lineColor.setStroke()
        
        plusPath.stroke()
    }
}


@IBDesignable
class CustomArrowButton: UIButton {
    
    
    @IBInspectable var lineColor: UIColor = UIColor.clearColor()
    @IBInspectable var LeftDirection: Bool = true
    
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // line parameters
        let lineHeight: CGFloat = 3.0
        let lineWidth: CGFloat = min(bounds.width, bounds.height) * 0.6
        
        let linePath = UIBezierPath()
        
        linePath.lineWidth = lineHeight
        
        // points to draw the arrow
        var begin: CGPoint, middle: CGPoint, end: CGPoint = CGPointZero
        
        // set points for left direction
        if self.LeftDirection {
            begin = CGPoint(x: bounds.width - 1.5, y: 1.5)
            middle = CGPoint(x: 1.5, y: bounds.height/2 + 0.5)
            end = CGPoint(x: bounds.width - 1.5, y: bounds.height - 1.5)
            
        // set points for right direction
        } else {
            begin = CGPoint(x: 1.5, y: 1.5)
            middle = CGPoint(x: bounds.width - 1.5, y: bounds.height/2 + 0.5)
            end = CGPoint(x: 1.5, y: bounds.height - 1.5)
        }
        
        // define bezier path points
        linePath.moveToPoint(begin)
        linePath.addLineToPoint(middle)
        linePath.addLineToPoint(end)
        
        // set line stroke color
        self.lineColor.setStroke()
        
        // draw line
        linePath.stroke()
    }
    
}




