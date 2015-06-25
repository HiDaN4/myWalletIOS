//
//  Holder.swift
//  MyWalletSaver
//
//  Created by Dmitry Sokolov on 6/24/15.
//  Copyright (c) 2015 Dmitry Sokolov. All rights reserved.
//

import Foundation
import CoreData

class Holder: NSManagedObject {

    @NSManaged var created: NSTimeInterval
    @NSManaged var name: String
    @NSManaged var unique_id: Int16
    @NSManaged var totalExpense: Double
    @NSManaged var totalIncome: Double
    @NSManaged var expenses: Operation
    @NSManaged var incomes: Operation

}
