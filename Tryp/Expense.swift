//
//  Expense.swift
//  Tryp
//
//  Created by Chris Fetterolf on 10/18/16.
//  Copyright © 2016 DeepHause. All rights reserved.
//

import UIKit

class Expense {
    
    var objID = ""
    var name:String = ""
    var users = [String]()
    var whoOwesWho = [[Double]]()
    var trackExpenses = [[AnyObject]]() // [0] is label (string), [1] is cost (int)

}
