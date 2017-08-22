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
    
    var taskToEdit: Task?
    var tasksDatastore: TasksDatastore?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playButton.layer.cornerRadius = playButton.frame.size.width / 2
        playButton.layer.masksToBounds = true
        playButton.layer.borderWidth = 1.0
        playButton.layer.borderColor = playButton.tintColor.cgColor
        
        if let task = taskToEdit {
            print("Task: \(taskToEdit)")
            taskDescriptionLabel.text = task.description

            let dateFormatter:DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YY" // "HH:mm"

            let formattedDate = dateFormatter.string(from: task.date as Date)
                taskDateLabel.text = "\(formattedDate)"
        }

        // playButton.tintColor = UIColor.white
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func playStopAction(_ sender: Any) {
        started = !started
        playButton.setImage(UIImage(named: started ? "Stop" : "Play"), for: UIControlState.normal)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
