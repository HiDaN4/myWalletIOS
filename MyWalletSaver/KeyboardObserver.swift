//
//  KeyboardObserver.swift
//  WalletTracker
//
//  Created by Dmitry Sokolov on 10/18/15.
//  Copyright © 2015 Dmitry Sokolov. All rights reserved.
//

import Foundation
import UIKit

enum KeyboardEventType: CustomStringConvertible {
    case WillShow
    case WillHide
    case WillChangeFrame
    case DidShow
    case DidHide
    case DidChangeFrame
    
    private var notificationKey: String {
        switch self {
        case .WillShow: return UIKeyboardWillShowNotification
        case .WillHide: return UIKeyboardWillHideNotification
        case .WillChangeFrame: return UIKeyboardWillChangeFrameNotification
        case .DidShow: return UIKeyboardDidShowNotification
        case .DidHide: return UIKeyboardDidHideNotification
        case .DidChangeFrame: return UIKeyboardDidChangeFrameNotification
        }
    }

    
    var description: String {
        switch self {
        case .WillShow: return "keyboard will show"
        case .WillHide: return "keyboard will hide"
        case .WillChangeFrame: return "keyboard will change frame"
        case .DidShow: return "keyboard did show"
        case .DidHide: return "keyboard did hide"
        case .DidChangeFrame: return "keyboard did change frame"
        }
    }
}





struct KeyboardEvent: CustomStringConvertible {
    let type: KeyboardEventType
    let keyboardFrame: CGRect?
    let keyboardAnimationCurve: UIViewAnimationOptions?
    let keyboardAnimationDuration: NSTimeInterval?
    
    var description: String {
        return "Event Type: \(type)\n"
        + "Keyboard Frame: \(keyboardFrame)\n"
        + "Keyboard Animation Curve: \(keyboardAnimationCurve)\n"
        + "Keyboard Animation Duration: \(keyboardAnimationDuration)"
    }
    
    
    private init?(fromNotification notification: NSNotification) {
        
        switch notification.name {
        case UIKeyboardWillShowNotification: self.type = .WillShow
        case UIKeyboardWillHideNotification: self.type = .WillHide
        case UIKeyboardWillChangeFrameNotification: self.type = .WillChangeFrame
        case UIKeyboardDidShowNotification: self.type = .DidShow
        case UIKeyboardDidHideNotification: self.type = .DidHide
        case UIKeyboardDidChangeFrameNotification: self.type = .DidChangeFrame
        default: return nil
        }
        
        if let userInfo = notification.userInfo {
            self.keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
            if let animationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.unsignedLongValue {
                self.keyboardAnimationCurve = UIViewAnimationOptions(rawValue: animationCurve)
            } else { self.keyboardAnimationCurve = nil }
            
            self.keyboardAnimationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval
        } else {
            self.keyboardAnimationCurve = nil
            self.keyboardFrame = nil
            self.keyboardAnimationDuration = nil
        }
    }
    
}



protocol KeyboardObserverDelegate: class {
    func keyboardObserverDidReceiveKeyboardEvent(event: KeyboardEvent)
}


class KeyboardObserver: NSObject {
    weak var delegate: KeyboardObserverDelegate?
    private let eventTypes: [KeyboardEventType]
    
    init(delegate: KeyboardObserverDelegate, eventTypes: [KeyboardEventType]) {
        self.delegate = delegate
        self.eventTypes = eventTypes
        super.init()
    }
    
    deinit {
        self.endObservingEvents()
    }
    
    func beginObservingEvents() {
        for event in eventTypes {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didReceiveNotification:"), name: event.notificationKey, object: nil)
        }
    }
    
    func endObservingEvents() {
        for event in eventTypes {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: event.notificationKey, object: nil)
        }
    }
    
    func didReceiveNotification(notification: NSNotification) {
        if let event = KeyboardEvent(fromNotification: notification) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate?.keyboardObserverDidReceiveKeyboardEvent(event)
            })
        }
    }
    
}










