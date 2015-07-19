//
//  CExtensions.swift
//  WalletTracker
//
//  Created by Dmitry Sokolov on 7/18/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import Foundation
import UIKit


extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        let redColor: CGFloat = CGFloat(r)/255.0
        let greenColor: CGFloat = CGFloat(g)/255.0
        let blueColor: CGFloat = CGFloat(b)/255.0
        
        self.init(red: redColor, green: greenColor, blue: blueColor, alpha: a)
        
    }
}