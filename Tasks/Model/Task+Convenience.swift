//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Steven Berard on 2/11/20.
//  Copyright © 2020 Steven Berard. All rights reserved.
//

import Foundation
import CoreData

enum TaskPriority: String {
    case low // = "Low"
    case normal // = "Normal"
    case high // = "High"
    case critical // = "Critical"
    
    static var allPriorities: [TaskPriority] {
        return [.low, .normal, .high, .critical]
    }
}

extension Task {
    @discardableResult
    convenience init(name: String,
                     notes: String? = nil,
                     priority: TaskPriority = .normal,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.notes = notes
        self.priority = priority.rawValue
    }
}
