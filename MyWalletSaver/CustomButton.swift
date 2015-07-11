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
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        var path = UIBezierPath(ovalInRect: rect)
        UIColor.clearColor().setFill()
        path.fill()
        
        UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1).setStroke()
        
        path.lineWidth = 1.0
        
        path.stroke()
        
    }
    

}



class CustomPushButton : CustomCirclularButton {
    
    @IBInspectable var lineColor: UIColor = UIColor.clearColor()
    @IBInspectable var isPlus: Bool = true
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let plusHeight: CGFloat = 3.0
        let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.6
        
        var plusPath = UIBezierPath()
        
        plusPath.lineWidth = plusHeight
        
        plusPath.moveToPoint(CGPoint(x: bounds.width/2 - plusWidth/2 + 0.5, y: bounds.height/2 + 0.5))
        
        plusPath.addLineToPoint(CGPoint(x: bounds.width/2 + plusWidth/2 + 0.5, y: bounds.height/2 + 0.5))
        
        if isPlus {
        plusPath.moveToPoint(CGPoint(x: bounds.width/2 + 0.5, y: bounds.height/2 - plusWidth/2 + 0.5))
        
        plusPath.addLineToPoint(CGPoint(x: bounds.width/2 + 0.5, y: bounds.height/2 + plusWidth/2 + 0.5))
            
        }
        
        lineColor.setStroke()
        
        plusPath.stroke()
    }
}





