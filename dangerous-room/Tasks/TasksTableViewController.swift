//
//  TasksTableViewController.swift
//  Dangerous Room
//
//  Created by Konstantin on 24/06/2017.
//  Copyright © 2017 kst404. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class TasksTableViewController: UITableViewController {
    
    fileprivate var tasksDatastore: TasksDatastore?
    fileprivate var tasks: [Task] = []
    fileprivate var selectedTask: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        print("viewWillAppear")
        for i in tasks {
            print("\(i.id)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Configure
    
    func configure(tasksDatastore: TasksDatastore) {
        self.tasksDatastore = tasksDatastore
    }
    
    
    // MARK: - Internal Functions
    fileprivate func refresh() {
        if let tasksDatastore = tasksDatastore {
            tasks = tasksDatastore.tasks().sorted{ $0.date.compare($1.date) ==
                ComparisonResult.orderedAscending
            }
            tableView.reloadData()
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath) as! MGSwipeTableCell
        
        let _task = tasks[indexPath.row]
        renderCell(cell, task: _task)
        setupButtonsForCell(cell: cell, task: _task)
        
        
        return cell
    }
    
    /*
     // method to run when table view cell is tapped
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     if let _task = tasks?[indexPath.row] {
     selectedTask = _task
     print("Tapped")
     }
     
     // Segue to the second view controller
     //        self.performSegue(withIdentifier: "yourSegue", sender: self)
     }
     */
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    private func setupButtonsForCell(cell: MGSwipeTableCell, task: Task) {
        cell.rightButtons = [
            MGSwipeButton(title: "Edit",
                          backgroundColor: UIColor.blue,
                          padding: 30) {
                            [weak self] sender in self?.editButtonPressed(task: task)
                            return true
            },
            MGSwipeButton(title: "Delete",
                          backgroundColor: UIColor.red,
                          padding: 30) {
                            [weak self] sender in self?.deleteButtonPressed(task: task)
                            return true
            }
        ]
        
        cell.rightExpansion.buttonIndex = 0
        cell.leftButtons = [
            MGSwipeButton(title: "Done",
                          backgroundColor: UIColor.green,
                          padding: 30) {
                            [weak self] sender in self?.doneButtonPressed(task: task)
                            return true
            } ]
        cell.leftExpansion.buttonIndex = 0
    }
    
    fileprivate func renderCell(_ cell:UITableViewCell, task: Task){
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY" // "HH:mm"
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        
        let startDate = dateFormatter.string(from: task.date)
        let startTime = timeFormatter.string(from: task.date)
        let endTime = timeFormatter.string(from: task.date.addingTimeInterval(TimeInterval(task.duration)))
        
        cell.detailTextLabel?.text = "\(startDate) \(startTime) - \(endTime)"
        cell.textLabel?.text = task.description
        
        cell.accessoryType = task.completed ? .checkmark : .none
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            switch identifier {
            case "addTask":
                if let destinationController = segue.destination as? UINavigationController,
                    let destinationEditController = destinationController.viewControllers.first as? TaskEditTableViewController {
                    if let _task = selectedTask {
                        destinationEditController.title = "Edit Task"
                        destinationEditController.taskToEdit = _task
                        destinationEditController.tasksDatastore = tasksDatastore
                    } else {
                        destinationEditController.title = "New Task"
                        destinationEditController.tasksDatastore = tasksDatastore
                    }
                }
            case "viewTask":
                if let destinationViewController = segue.destination as? TaskViewController {
                    if let cell = sender as? UITableViewCell,
                        let indexPath = tableView.indexPath(for: cell) {
                        let _task = tasks[indexPath.row]
                        destinationViewController.taskToEdit = _task
                    }
                    destinationViewController.tasksDatastore = tasksDatastore
                }
            default: break
            }
        }
        selectedTask = nil
    }
    
}

// MARK: Actions
extension TasksTableViewController {
    
    func editButtonPressed(task: Task) {
        selectedTask = task
        performSegue(withIdentifier: "addTask", sender: self)
        print("editButtonPressed")
    }
    
    func deleteButtonPressed(task: Task) {
        tasksDatastore?.deleteTask(task: task)
        refresh()
    }
    
    func doneButtonPressed(task: Task) {
        tasksDatastore?.doneTask(task: task)
        refresh()
    }
}
