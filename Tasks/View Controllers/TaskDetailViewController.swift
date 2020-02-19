//
//  TaskDetailViewController.swift
//  Tasks
//
//  Created by Steven Berard on 2/11/20.
//  Copyright © 2020 Steven Berard. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    
    var taskController: TaskController!
    
    var task: Task? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

    // MARK: - Actions

    @IBAction func saveTask(_ sender: Any) {
        guard let name = nameTextField.text,
            !name.isEmpty else { return }
        let notes = notesTextView.text
        let priorityIndex = priorityControl.selectedSegmentIndex
        let priority = TaskPriority.allPriorities[priorityIndex]
        
        if let task = task {
            // Editing existing task
            task.name = name
            task.notes = notes
            task.priority = priority.rawValue
            taskController.sendTaskToServer(task: task)
        } else {
            // Create new task
            let task = Task(name: name, notes: notes, priority: priority)
            taskController.sendTaskToServer(task: task)
        }
        
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            print("Error saving task: \(error)")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Update Views

    private func updateViews() {
        guard isViewLoaded else { return }
        
        title = task?.name ?? "Create Task"
        nameTextField.text = task?.name
        notesTextView.text = task?.notes
        
        let priority: TaskPriority
        if let taskPriority = task?.priority {
            priority = TaskPriority(rawValue: taskPriority)!
        } else {
            priority = .normal
        }
        priorityControl.selectedSegmentIndex = TaskPriority.allPriorities.firstIndex(of: priority) ?? 1
    }
}

