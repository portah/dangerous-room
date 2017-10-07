//
//  TasksTableViewController.swift
//  Dangerous Room
//
//  Created by Konstantin on 24/06/2017.
//  Copyright © 2017 kst404. All rights reserved.

import UIKit
import MGSwipeTableCell
import CoreData
import SwiftDDP

// Allows us to attach the list _id to the cell
public class EventCell:UITableViewCell {
    var _id:String?
}


class TasksTableViewController: MeteorCoreDataTableViewController, MeteorCoreDataCollectionDelegate {
    
    var collection:MeteorCoreDataCollection = (UIApplication.shared.delegate as! AppDelegate).events
    
    //    fileprivate var tasksDatastore: TasksDatastore?
    //    fileprivate var tasks: [Task] = []
    //    fileprivate var selectedTask: Task?
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Events")
        let primarySortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [secondarySortDescriptor, primarySortDescriptor]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.collection.managedObjectContext,
                                             sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        collection.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let sections = fetchedResultsController.sections {
            log.debug("sections: \(sections.count)")
            return sections.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            log.debug("numberOfRowsInSection: \(currentSection.numberOfObjects)")
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath) as! MGSwipeTableCell
        let eventItem = fetchedResultsController.object(at: indexPath) as! Events
        
        renderCell(cell, event: eventItem)
        setupButtonsForCell(cell: cell, event: eventItem)
        //                log.debug("Event: -> \(String(describing: eventItem.date))")
        
        return cell
    }
    
    fileprivate func renderCell(_ cell:UITableViewCell, event: Events) {
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY" // "HH:mm"
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        
        let startDate = dateFormatter.string(from: event.date!)
        let startTime = timeFormatter.string(from: event.date!)
        let endTime = timeFormatter.string(from: event.date!.addingTimeInterval(TimeInterval(event.duration)))
        
        cell.detailTextLabel?.text = "\(startDate) \(startTime) - \(endTime)"
        cell.textLabel?.text = event.event_description
        
        cell.accessoryType = event.completed ? .checkmark : .none
    }
    
    // MARK: - MGSwipeTableCell
    
    private func setupButtonsForCell(cell: MGSwipeTableCell, event: Events) {
        cell.rightButtons = [
            MGSwipeButton(title: "Edit",
                          backgroundColor: UIColor.blue,
                          padding: 30) {
                            [weak self] sender in self?.editButtonPressed(event: event)
                            return true
            },
            MGSwipeButton(title: "Delete",
                          backgroundColor: UIColor.red,
                          padding: 30) {
                            [weak self] sender in self?.deleteButtonPressed(event: event)
                            return true
            }
        ]
        
        cell.rightExpansion.buttonIndex = 0
        cell.leftButtons = [
            MGSwipeButton(title: "Done",
                          backgroundColor: UIColor.green,
                          padding: 30) {
                            [weak self] sender in self?.doneButtonPressed(event: event)
                            return true
            } ]
        cell.leftExpansion.buttonIndex = 0
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        /*
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
         */
    }
    
    
    // MARK: - Not used!!!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: Documents data

extension TasksTableViewController {
    
    func document(willBeCreatedWith fields: NSDictionary?, forObject object: NSManagedObject) -> NSManagedObject {
        log.debug("MeteorCoreDataCollectionDelegate document willBeCreatedWith")
        if let data = fields {
            for (key, value) in data {
                log.debug("document willBeCreatedWith: \(key) \(value)")
                setObjValue(value, forKey: key as! String, forObject: object)
            }
        }
        //        self.tableView.reloadData()
        return object
    }
    
    func document(willBeUpdatedWith fields: NSDictionary?, cleared: [String]?, forObject object: NSManagedObject) -> NSManagedObject {
        print("MeteorCoreDataCollectionDelegate document willBeUpdatedWith")
        if let _ = fields {
            for (key, value ) in fields! {
                log.debug("document willBeUpdatedWith: \(key) \(value)")
                setObjValue(value, forKey: key as! String, forObject: object)
            }
        }
        
        if let _ = cleared {
            for field in cleared! {
                object.setNilValueForKey(field)
            }
        }
        return object
    }
    
    func setObjValue(_ value: Any?, forKey key: String, forObject object: NSManagedObject) {
        if (key as AnyObject).isEqual("date") {
            object.setValue(EJSON.convertToNSDate(value as! [String : Any]), forKey: key )
        } else
            if !(key as AnyObject).isEqual("_id") {
                object.setValue(value, forKey: key )
        }
    }
}

// MARK: Actions
extension TasksTableViewController {
    
    func editButtonPressed(event: Events) {
        performSegue(withIdentifier: "addTask", sender: self)
        print("editButtonPressed")
    }
    
    func deleteButtonPressed(event: Events) {
        //        tasksDatastore?.deleteTask(task: task)
    }
    
    func doneButtonPressed(event: Events) {
        //        tasksDatastore?.doneTask(task: task)
    }
}
