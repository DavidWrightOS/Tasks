//
//  TaskDetailViewController.swift
//  Tasks
//
//  Created by Steven Berard on 2/11/20.
//  Copyright © 2020 Steven Berard. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet weak var priorityControl: UISegmentedControl!
    
    var task: Task? {
        didSet {
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

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
        } else {
            // Create new task
            Task(name: name, notes: notes)
        }
        
        do {
            let moc = CoreDataStack.shared.mainContext
            try moc.save()
        } catch {
            print("Error saving task: \(error)")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
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

