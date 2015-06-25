//
//  Operation.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 6/24/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import Foundation
import CoreData

class Operation: NSManagedObject {

    @NSManaged var amount: Double
    @NSManaged var timestamp: NSTimeInterval
    @NSManaged var category: String
    @NSManaged var wallet: Holder

}
