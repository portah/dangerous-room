//
//  TasksTableViewController.swift
//  Dangerous Room
//
//  Created by Konstantin on 24/06/2017.
//  Copyright © 2017 kst404. All rights reserved.

import UIKit
import CoreData
import SwiftDDP

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        let eventItem = fetchedResultsController.object(at: indexPath) as! Events
        
        renderCell(cell, event: eventItem)
        // log.debug("Event: -> \(String(describing: eventItem.date))")
        
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // handle delete (by removing the data from your array and updating the tableview)
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let object = fetchedResultsController.object(at: indexPath) as! NSManagedObject
            let id = object.value(forKey: "id") as! String
            log.debug("going to delete id: \(id)")
            self.collection.remove(withId: id)
//            Meteor.call("dangerous-room/events/delete", params: [id], callback: nil)
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            log.debug("UIStoryboardSegue identifier \(identifier)")
            switch identifier {
//            case "addTask":
//                if let destinationController = segue.destination as? UINavigationController,
//                    let destinationEditController = destinationController.viewControllers.first as? TaskEditTableViewController {
//                    if let _task = selectedTask {
//                        destinationEditController.title = "Edit Task"
//                        destinationEditController.taskToEdit = _task
//                        destinationEditController.tasksDatastore = tasksDatastore
//                    } else {
//                        destinationEditController.title = "New Task"
//                        destinationEditController.tasksDatastore = tasksDatastore
//                    }
//                }
            case "viewTask":
                if let destinationViewController = segue.destination as? TaskViewController {
                    if let cell = sender as? UITableViewCell,
                        let indexPath = tableView.indexPath(for: cell) {
                        let event = fetchedResultsController.object(at: indexPath)  as! Events
                        destinationViewController.taskToEdit = event
                    }
                }
            default: break
            }
        }
    }
    
    @IBAction func unwindToViewControllerTaskView(segue: UIStoryboardSegue) {
        print("Unwind Tasks")
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
        if let data = fields {
            for (key, value) in data {
                setObjValue(value, forKey: key as! String, forObject: object)
            }
        }
        return object
    }
    
    
    func document(willBeUpdatedWith fields: NSDictionary?, cleared: [String]?, forObject object: NSManagedObject) -> NSManagedObject {
        if let _ = fields {
            for (key, value ) in fields! {
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
            print("setObjValue:  value: \(String(describing: value))")
            print("setObjValue:    key: \(key)")
            print("setObjValue: object: \(object)")
//            var tvalue = nil
            if value as? Date != nil {
//                tvalue = EJSON.convertToEJSONDate(value as! Date)
                print("setObjValue: object.setValue convertToEJSONDate")
                object.setValue(EJSON.convertToEJSONDate(value as! Date), forKey: key )
            } else {
                print("setObjValue: object.setValue")
                object.setValue(EJSON.convertToNSDate(value as! [String : Any]), forKey: key )
            }
        } else
            if !(key as AnyObject).isEqual("_id") {
                object.setValue(value, forKey: key )
        }
    }
}

