//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Steven Berard on 2/11/20.
//  Copyright © 2020 Steven Berard. All rights reserved.
//

import Foundation
import CoreData

extension Task {
    @discardableResult
    convenience init(name: String, notes: String? = nil, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.notes = notes
    }
}
