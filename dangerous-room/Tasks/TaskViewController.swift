//
//  TaskViewController.swift
//  Dangerous Room
//
//  Created by Konstantin on 24/06/2017.
//  Copyright © 2017 kst404. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UIViewController {
    var started = false
    
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskTimeLabel: UILabel!
    
    var taskToEdit: Events? {
        didSet {
            updateViewsContent()
        }
    }
    
    func updateViewsContent() {
        guard let event = taskToEdit else { return }
        guard let _ = taskDateLabel else { return }

        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY" // "HH:mm"
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        
        let formattedDate = dateFormatter.string(from: event.date!)
        taskDateLabel.text = "\(formattedDate)"
        
        let startDate = dateFormatter.string(from: event.date!)
        let startTime = timeFormatter.string(from: event.date!)
        let endTime = timeFormatter.string(from: event.date!.addingTimeInterval(TimeInterval(event.duration)))
        
        taskDateLabel.text = startDate
        taskDescriptionLabel.text = event.event_description
        taskTimeLabel.text = "\(startTime) - \(endTime)"
        //            self.timer = DangerousTimer(duration: TimeInterval(task.duration), onTick: self.tick)
    }
    
    var timer: DangerousTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.layer.cornerRadius = playButton.frame.size.width / 2
        playButton.layer.masksToBounds = true
        playButton.layer.borderWidth = 1.0
        playButton.layer.borderColor = playButton.tintColor.cgColor
<<<<<<< HEAD

//        if let event = taskToEdit {
//            let dateFormatter:DateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MM/dd/YY" // "HH:mm"
//
//            let timeFormatter = DateFormatter()
//            timeFormatter.timeStyle = DateFormatter.Style.short
//
//            let formattedDate = dateFormatter.string(from: event.date!)
//            taskDateLabel.text = "\(formattedDate)"
//
//            let startDate = dateFormatter.string(from: event.date!)
//            let startTime = timeFormatter.string(from: event.date!)
//            let endTime = timeFormatter.string(from: event.date!.addingTimeInterval(TimeInterval(event.duration)))
//
//            taskDateLabel.text = startDate
//            taskDescriptionLabel.text = event.event_description
//            taskTimeLabel.text = "\(startTime) - \(endTime)"
////            self.timer = DangerousTimer(duration: TimeInterval(task.duration), onTick: self.tick)
//        }

        updateViewsContent()
        print("!!! !!! !!! viewDidLoad")
=======
        
        self.updateUI()
    }
    
    func updateUI() {
>>>>>>> master
        if let event = taskToEdit {
            print("!!! !!! !!! event = taskToEdit", event)
            
<<<<<<< HEAD
            NotificationCenter.default.addObserver(self, selector: #selector(respondToMOCChanges(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
            ContextObserver.debugOutput = true
            let observer = ContextObserver(context: event.managedObjectContext!)
            NotificationCenter.default.addObserver(observer, selector: #selector(observer.managedObjectDidChange(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
            observer.add().block { [weak self] object, type, keys in //.filter(taskToEdit)
                print("!!! !!! !!! ContextObserver !!! !!! !!!", object)
                self?.taskToEdit = object as? Events
            }
=======
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = DateFormatter.Style.short
            
            let formattedDate = dateFormatter.string(from: event.date!)
            taskDateLabel.text = "\(formattedDate)"
            
            let startDate = dateFormatter.string(from: event.date!)
            let startTime = timeFormatter.string(from: event.date!)
            let endTime = timeFormatter.string(from: event.date!.addingTimeInterval(TimeInterval(event.duration)))
            
            taskDateLabel.text = startDate
            taskDescriptionLabel.text = event.event_description
            taskTimeLabel.text = "\(startTime) - \(endTime)"
>>>>>>> master
        }
    }
    
    @objc
    func respondToMOCChanges(_ notification: Notification) {
        guard let changedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> else { return }
        
        print("respondToMOCChanges", changedObjects.first?.managedObjectContext === MeteorCoreData.stack.managedObjectContext, changedObjects.first?.managedObjectContext === MeteorCoreData.stack.backgroundContext, changedObjects.first?.managedObjectContext === MeteorCoreData.stack.managedObjectContext)
//        detailItem = changedObjects.first as? Event
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.stop()
        started = false
    }
    
    // MARK: - Actions
    @IBAction func playStopAction(_ sender: Any) {
        started = !started
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let segueIdentifier = segue.identifier else { return }
        
        switch segueIdentifier {
            case "editTask":
                if let destinationController = segue.destination as? UINavigationController,
                    let destinationEditController = destinationController.viewControllers.first as? TaskEditTableViewController {
                    destinationEditController.title = "Edit Task"
                    destinationEditController.taskToEdit = taskToEdit
                }
            case "countdown":
                segue.destination.modalPresentationStyle = .custom
                segue.destination.transitioningDelegate = self
                
                if let taskTimerController = segue.destination as? TaskTimerViewController {
                    taskTimerController.task = taskToEdit
                    taskTimerController.aliveTimeinterval = 10//2 * 60
                    taskTimerController.betweenAliveTimeinterval = 10
                }
            default:
                return
        }
    }
    
    @IBAction func unwindToViewControllerTaskView(segue: UIStoryboardSegue) {
        print("Unwind View")
        self.updateUI()
    }

    // MARK: - Unused
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
