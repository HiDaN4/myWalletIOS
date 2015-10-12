//
//  Stack.swift
//  WalletTracker
//
//  Created by Dmitry Sokolov on 8/5/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import Foundation


struct Stack<T> {
    private var items_ = [T]()
    
    var count: Int {
        get {
            return self.items_.count
        }
    }
    
    mutating func push(item: T) {
        self.items_.append(item)
    }
    
    mutating func pop() -> T? {
        return self.isEmpty() ? nil: self.items_.removeLast()
    }
    
    func isEmpty() -> Bool {
        return self.items_.isEmpty
    }
    
    
    func getTop() -> T? {
        return self.isEmpty() ? nil : self.items_[self.items_.count - 1]
    }
}