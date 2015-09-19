//
//  FlipSegue.swift
//  WalletTracker
//
//  Created by Dmitry Sokolov on 9/17/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import UIKit

@objc(FlipSegue)

class FlipSegue: UIStoryboardSegue {
    
    override func perform() {
        let source = self.sourceViewController as! UIViewController
        let destination = self.destinationViewController as! UIViewController
        
        source.navigationController?.pushViewController(destination, animated: false)
        
        UIView.transitionFromView(source.view, toView: destination.view, duration: 0.7, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion: nil)
        
    }
   
}
