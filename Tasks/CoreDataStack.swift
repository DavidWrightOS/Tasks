//
//  CoreDataStack.swift
//  Tasks
//
//  Created by Steven Berard on 2/11/20.
//  Copyright © 2020 Steven Berard. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var container: NSPersistentContainer = {
        let newContainer = NSPersistentContainer(name: "Tasks")
        newContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return newContainer
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
}
