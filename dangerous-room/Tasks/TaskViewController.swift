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
    @IBOutlet weak var taskTimerLabel: UILabel!
    
    var taskToEdit: Task?
    var tasksDatastore: TasksDatastore?
    
    var timer: DangerousTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.layer.cornerRadius = playButton.frame.size.width / 2
        playButton.layer.masksToBounds = true
        playButton.layer.borderWidth = 1.0
        playButton.layer.borderColor = playButton.tintColor.cgColor
        
//        let title1Font = UIFont.preferredFont(forTextStyle: .title1)
        taskTimerLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: UIFontWeightLight)
        
        if let task = taskToEdit {
            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YY" // "HH:mm"
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = DateFormatter.Style.short
            
            let formattedDate = dateFormatter.string(from: task.date)
            taskDateLabel.text = "\(formattedDate)"
            
            let startDate = dateFormatter.string(from: task.date)
            let startTime = timeFormatter.string(from: task.date)
            let endTime = timeFormatter.string(from: task.date.addingTimeInterval(TimeInterval(task.duration)))
            
            taskDateLabel.text = startDate
            taskDescriptionLabel.text = task.description
            taskTimeLabel.text = "\(startTime) - \(endTime)"
            self.timer = DangerousTimer(duration: TimeInterval(task.duration), onTick: self.tick)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.stop()
        started = false
    }
    
    func tick() {
        if let _timer = self.timer {
            taskTimerLabel.text = String(format: "%02d:%02d", Int(_timer.getRest()/60), Int(_timer.getRest())%60)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func playStopAction(_ sender: Any) {
        started = !started
        playButton.setImage(UIImage(named: started ? "Stop" : "Play"), for: UIControlState.normal)
        if(started) {
            self.timer?.start()
        } else {
            self.timer?.stop()
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //        guard let identifier = segue.identifier,
        guard let destinationController = segue.destination as? UINavigationController,
            let destinationEditController = destinationController.viewControllers.first as? TaskEditTableViewController
            else {
                return
        }
        
        destinationEditController.title = "Edit Task"
        destinationEditController.tasksDatastore = tasksDatastore
        destinationEditController.taskToEdit = taskToEdit
    }
    
}
