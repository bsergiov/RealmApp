//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Alexey Efimov on 02.07.2018.
//  Copyright © 2018 Alexey Efimov. All rights reserved.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    var taskList: TaskList!
    
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
        currentTasks = taskList.tasks.filter("isComplete = false")
        completedTasks = taskList.tasks.filter("isComplete = true")
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        showAlert(with: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        var doneAction: UIContextualAction!
        if indexPath.section == 0 {
             doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
                self.doneTask(with: task, action: true)
                self.tableView.reloadData()
                isDone(true)
            }
            doneAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            
        } else {
            doneAction = UIContextualAction(style: .normal, title: "Repet") { _, _, isDone in
                self.doneTask(with: task, action: false)
                self.tableView.reloadData()
                isDone(true)
            }
            doneAction.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        }
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        deleteAction.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, deleteAction])
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }

}

extension TasksViewController {
    
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit Task" : "New Task"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")
        
        alert.action(with: task) { newValue, note in
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task, name: newValue, note: note)
                completion()
            } else {
                self.saveTask(withName: newValue, andNote: note)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func saveTask(withName name: String, andNote note: String) {
        let task = Task(value: [name, note])
        StorageManager.shared.save(task, to: taskList)
        
        let rowIndex = IndexPath(row: currentTasks.index(of: task) ?? 0, section: 0)
        tableView.insertRows(at: [rowIndex], with: .automatic)
    }

    
    private func doneTask(with task: Task, action: Bool) {
        StorageManager.shared.done(task, action: action)
    }
}
