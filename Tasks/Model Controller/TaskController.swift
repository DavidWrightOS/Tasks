//
//  TaskController.swift
//  Tasks
//
//  Created by David Wright on 2/17/20.
//  Copyright © 2020 Steven Berard. All rights reserved.
//

import Foundation
import CoreData

let baseURL = URL(string: "https://tasks-8d69f.firebaseio.com/")!

class TaskController {
    
    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
    
    typealias CompletionHandler = (Error?) -> Void
    
    init() {
        fetchTasksFromServer()
    }
    
    // MARK: - Task Actions

    func fetchTasksFromServer(completion: @escaping CompletionHandler = { _ in  }) {
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            guard error == nil else {
                print("Error fetching tasks from server: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            guard let data = data else {
                print("No data returned by data task.")
                DispatchQueue.main.async {
                    completion(NSError())
                }
                return
            }
            
            do {
                let taskRepresentations = Array(try JSONDecoder().decode([String : TaskRepresentation].self, from: data).values)
                self.updateTasks(with: taskRepresentations)
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print("Error decoding task representations: \(error)")
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }.resume()
    }
    
    func sendTaskToServer(task: Task, completion: @escaping CompletionHandler = { _ in }) {
        let uuid = task.identifier ?? UUID()
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            guard var representation = task.taskRepresentation else {
                completion(NSError())
                return
            }
            representation.identifier = uuid.uuidString
            task.identifier = uuid
            try CoreDataStack.shared.save(context: CoreDataStack.shared.mainContext)
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding task: \(error)")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil else {
                print("Error PUTting task to server: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    // A better name for this method would be "deleteTask"
    func deleteTaskFromServer(_ task: Task, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = task.identifier else {
            completion(NSError())
            return
        }
        
        let context = CoreDataStack.shared.mainContext
        
        context.perform {
            do {
                context.delete(task)
                try CoreDataStack.shared.save(context: context)
            } catch {
                context.reset()
                print("Error deleting object from managed object context: \(error)")
            }
        }
        
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            guard error == nil else {
                print("Error deleting task: \(error!)")
                DispatchQueue.main.async {
                    completion(error)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }.resume()
    }
    
    // MARK: - Private Methods
    
    private func updateTasks(with representations: [TaskRepresentation]) {
        let tasksWithID = representations.filter { $0.identifier != nil }
        let identifiersToFetch = tasksWithID.compactMap { UUID(uuidString: $0.identifier!) }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, tasksWithID))
        var tasksToCreate = representationsByID
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        
        let context = CoreDataStack.shared.container.newBackgroundContext()
        
        context.perform {
            do {
                let existingTasks = try context.fetch(fetchRequest)
                
                for task in existingTasks {
                    guard let id = task.identifier,
                        let representation = representationsByID[id] else { continue }
                    
                    self.update(task: task, with: representation)
                    tasksToCreate.removeValue(forKey: id)
                }
                
                for representation in tasksToCreate.values {
                    Task(taskRepresentation: representation, context: context)
                }
            } catch {
                print("Error fetching task for UUIDs: \(error)")
            }
        }
        
        do {
            try CoreDataStack.shared.save(context: context)
        } catch {
            print("Error saving task to database: \(error)")
        }
    }
    
    private func update(task: Task, with representation: TaskRepresentation) {
        task.name = representation.name
        task.notes = representation.notes
        task.priority = representation.priority
    }
}
