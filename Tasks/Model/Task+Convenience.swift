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
    case low
    case normal
    case high
    case critical
    
    static var allPriorities: [TaskPriority] {
        return [.low, .normal, .high, .critical]
    }
}

extension Task {
    var taskRepresentation: TaskRepresentation? {
        guard let name = name,
            let priority = priority else { return nil }
        
        return TaskRepresentation(name: name,
                                  notes: notes,
                                  priority: priority,
                                  identifier: identifier?.uuidString ?? "")
    }
    
    @discardableResult
    convenience init(name: String,
                     notes: String? = nil,
                     priority: TaskPriority = .normal,
                     identifier: UUID = UUID(),
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.notes = notes
        self.identifier = identifier
        self.priority = priority.rawValue
    }
    
    @discardableResult
    convenience init?(taskRepresentation: TaskRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let priority = TaskPriority(rawValue: taskRepresentation.priority),
            let identifierString = taskRepresentation.identifier,
            let identifier = UUID(uuidString: identifierString) else { return nil }
        
        self.init(name: taskRepresentation.name,
                  notes: taskRepresentation.notes,
                  priority: priority,
                  identifier: identifier,
                  context: context)
    }
}
