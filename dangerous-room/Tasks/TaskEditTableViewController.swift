//
//  TaskEditTableViewController.swift
//  Dangerous Room
//
//  Created by Konstantin on 24/06/2017.
//  Copyright © 2017 kst404. All rights reserved.
//

import UIKit

class TaskEditTableViewController: UITableViewController {
    
    @IBOutlet var dateField: UITextField!
    @IBOutlet var startTimeField: UITextField!
    @IBOutlet var durationField: UITextField!
    @IBOutlet weak var taskDescriptionField: UITextField!
    
    var datePicker = UIDatePicker(),
    startTimePicker = UIDatePicker(),
    durationPicker = UIDatePicker()
    
    var taskToEdit: Events?
    
    fileprivate var newTask:Task = Task( id: UUID().uuidString,
                                         description: "",
                                         date: Date(),
                                         duration: 3600,
                                         completed: false
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(changeFieldValue), for: .valueChanged)
        dateField.inputView = datePicker
        
        startTimePicker.datePickerMode = .time
        startTimePicker.addTarget(self, action: #selector(changeFieldValue), for: .valueChanged)
        startTimeField.inputView = startTimePicker
        
        durationPicker.datePickerMode = .countDownTimer
        durationPicker.addTarget(self, action: #selector(changeFieldValue), for: .valueChanged)
        durationField.inputView = durationPicker
        
        if let event = taskToEdit {
            
            self.datePicker.setDate(event.date!, animated: false)
            self.changeFieldValue(self.datePicker)
            
            self.startTimePicker.setDate(event.date!, animated: false)
            self.changeFieldValue(self.startTimePicker)
            
//            self.endTimePicker.setDate((task.date.addingTimeInterval(TimeInterval(task.duration))) as Date, animated: false)
            self.durationPicker.countDownDuration =  TimeInterval(event.duration)
            self.changeFieldValue(self.durationPicker)

            self.taskDescriptionField.text = event.event_description
            
            self.newTask.id = event.id!
            self.newTask.description = event.event_description!
            self.newTask.date = event.date!
            self.newTask.duration = TimeInterval(event.duration)
            self.newTask.completed = event.completed
        }
        else {
            self.datePicker.setDate(self.newTask.date, animated: false)
            self.changeFieldValue(self.datePicker)
            
            self.startTimePicker.setDate(self.newTask.date, animated: false)
            self.changeFieldValue(self.startTimePicker)

            self.durationPicker.countDownDuration =  self.newTask.duration
            self.changeFieldValue(self.durationPicker)
        }
        
        taskDescriptionField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Actions
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let descr = taskDescriptionField.text {
            newTask.description = descr
        }
//        self.tasksDatastore?.updateTask(task: newTask)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Picker View Methods
    
    @objc func changeFieldValue(_ sender: UIDatePicker) {

        let gregorian = Calendar(identifier: .gregorian)
        var sender_date = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: sender.date)
        var task_date = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newTask.date)

        switch sender {
        case datePicker:
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateField.text = dateFormatter.string(from: sender.date)

            task_date.year = sender_date.year
            task_date.month = sender_date.month
            task_date.day = sender_date.day

            newTask.date = gregorian.date(from: task_date)!
            
        case startTimePicker:
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = DateFormatter.Style.short
            startTimeField.text = timeFormatter.string(from: sender.date)

            task_date.hour = sender_date.hour
            task_date.minute = sender_date.minute
            task_date.second = sender_date.second

            newTask.date = gregorian.date(from: task_date)!

            
        case durationPicker:
            let timeFormatter = DateComponentsFormatter()
            timeFormatter.unitsStyle = .abbreviated
            timeFormatter.allowedUnits = [.hour, .minute]
            durationField.text = timeFormatter.string(from: sender.countDownDuration)
            
            //newTask.duration = sender.date.timeIntervalSince(newTask.date as Date)
            newTask.duration = sender.countDownDuration
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNonzeroMagnitude
        default:
            return 21
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
}
