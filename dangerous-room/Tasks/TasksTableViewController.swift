//
//  TasksTableViewController.swift
//  Dangerous Room
//
//  Created by Konstantin on 24/06/2017.
//  Copyright © 2017 kst404. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Meteor
import CoreData

class TasksTableViewController: FetchedResultsTableViewController {
    
    fileprivate var tasksDatastore: TasksDatastore?
    fileprivate var tasks: [Task] = []
    fileprivate var selectedTask: Task?
    
    private var listObserver: ManagedObjectObserver?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    // MARK: - Content Loading
    
    override func configureSubscriptionLoader(subscriptionLoader: SubscriptionLoader) {
        print ("DR: configureSubscriptionLoader")
        subscriptionLoader.addSubscriptionWithName(name: "dangerous-room/events")
    }
    
    override func createFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        print ("DR: createFetchedResultsController")
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    // MARK: - FetchedResultsTableViewDataSourceDelegate
    
    func dataSource(dataSource: FetchedResultsTableViewDataSource, configureCell cell: UITableViewCell, forObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
        print ("DR: dataSource")
        if let tasks = object as? Events {
            print ("DR: dataSource Events")
            print(tasks);
//            renderCellforEvent(cell, event: tasks)
        }
    }
    
    func dataSource(dataSource: FetchedResultsTableViewDataSource, deleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
        if let tasks = object as? Events {
            print(tasks)
//            managedObjectContext.deleteObject(list)
//            saveManagedObjectContext()
        }
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

    fileprivate func renderCellforEvent(_ cell:UITableViewCell, event: Events){
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY" // "HH:mm"
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        
        let startDate = dateFormatter.string(from: event.date as! Date)
        let startTime = timeFormatter.string(from: event.date as! Date)
        let endTime = timeFormatter.string(from: event.date?.addingTimeInterval(TimeInterval(event.duration)) as! Date)
        
        cell.detailTextLabel?.text = "\(startDate) \(startTime) - \(endTime)"
        cell.textLabel?.text = event.name
        
        cell.accessoryType = event.completed ? .checkmark : .none
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
