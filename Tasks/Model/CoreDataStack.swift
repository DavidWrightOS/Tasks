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
    static let shared = CoreDataStack() // this is a "singleton"
    
    private init() {}
    
    // Container can be used to generate child contexts
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tasks")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // This is the primary or "parent" context
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        var saveError: Error?
        
        context.performAndWait {
            do {
                try context.save()
            } catch {
                saveError = error
            }
        }
        
        if let saveError = saveError { throw saveError }
    }
}
