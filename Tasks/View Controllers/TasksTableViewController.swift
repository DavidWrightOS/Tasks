//
//  TasksTableViewController.swift
//  Tasks
//
//  Created by Steven Berard on 2/11/20.
//  Copyright © 2020 Steven Berard. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController {
    
    // WARNING! This is incredibly inefficient!!!
    var tasks: [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let moc = CoreDataStack.shared.mainContext
        
        do {
            return try moc.fetch(fetchRequest)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            let moc = CoreDataStack.shared.mainContext
            moc.delete(task)
            
            do {
                try moc.save()
            } catch {
                moc.reset()
                print("Error saving deleted task: \(error)")
            }
            
            tableView.reloadData()
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTaskDetailSegue" {
            guard let detailVC = segue.destination as? TaskDetailViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            detailVC.task = tasks[indexPath.row]
        }
    }
}
