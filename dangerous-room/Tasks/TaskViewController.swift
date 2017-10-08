//
//  TaskViewController.swift
//  Dangerous Room
//
//  Created by Konstantin on 24/06/2017.
//  Copyright © 2017 kst404. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {
    var started = false
    
    @IBOutlet var playButton: UIButton!
    
    @IBOutlet weak var taskDescriptionLabel: UILabel!
    @IBOutlet weak var taskDateLabel: UILabel!
    @IBOutlet weak var taskTimeLabel: UILabel!
    
    var taskToEdit: Events?
    
    var timer: DangerousTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.layer.cornerRadius = playButton.frame.size.width / 2
        playButton.layer.masksToBounds = true
        playButton.layer.borderWidth = 1.0
        playButton.layer.borderColor = playButton.tintColor.cgColor
        
        self.updateUI()
    }
    
    func updateUI() {
        if let event = taskToEdit {
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
        }
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
                    taskTimerController.aliveTimeinterval = 2 * 60
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
