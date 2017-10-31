//
//  TasksTableViewController.swift
//  Dangerous Room
//
//  Created by Konstantin on 24/06/2017.
//  Copyright © 2017 kst404. All rights reserved.

import UIKit
import CoreData
import SwiftDDP
import UserNotifications

protocol ConfigurationViewControllerDelegate {
    func configurationCompleted(newNotifications new: Bool)
}

class TasksTableViewController: MeteorCoreDataTableViewController {
    
    var collection:MeteorCoreDataCollection = (UIApplication.shared.delegate as! AppDelegate).events
    //notification delegate!
    var delegate: ConfigurationViewControllerDelegate?
        
    lazy var fetchedResultsController: NSFetchedResultsController<Events> = {
        let fetchRequest = NSFetchRequest<Events>(entityName: "Events")
        let primarySortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [secondarySortDescriptor, primarySortDescriptor]
        let frc = fetchedResultsControllerFor(fetchRequest: fetchRequest, managedObjectContext: self.collection.managedObjectContext)
//            NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.collection.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self

        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            log.debug(error)
        }
        
//        UNUserNotificationCenter.current()
//            .requestAuthorization(options: [.alert, .sound]) { (granted, error) in
//                if granted {
//                    let content = UNMutableNotificationContent()
//                    content.title = "Dangerous Room!"
//                    content.subtitle = "Event started!"
//                    content.body = "It's dangerous be carefull!"
//
//                    let notiIdentifier = "notiIdentifier1"
//                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//                    let request = UNNotificationRequest(identifier: notiIdentifier, content: content, trigger: trigger)
//
//                    UNUserNotificationCenter.current()
//                        .add(request, withCompletionHandler: { (error) in
//                            if let error = error {
//                                print(error)
//                            } else {
//                                DispatchQueue.main.async(execute: {
//                                    self.delegate?.configurationCompleted(newNotifications: true)
//                                })
//                            }
//                        })
//                } else {
//                    print("UNUserNotificationCenter: \(String(describing: error?.localizedDescription))")
//                }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            log.debug(error)
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
        let eventItem = fetchedResultsController.object(at: indexPath)
        
        renderCell(cell, event: eventItem)
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
        if (editingStyle == .delete) {
            let object = fetchedResultsController.object(at: indexPath)
            let id = object.value(forKey: "id") as! String
            log.debug("going to delete id: \(id)")
            self.collection.remove(withId: id)
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
            case "viewTask":
                if let destinationViewController = segue.destination as? TaskViewController {
                    if let cell = sender as? UITableViewCell,
                        let indexPath = tableView.indexPath(for: cell) {
                        let event = fetchedResultsController.object(at: indexPath)
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
    
}

