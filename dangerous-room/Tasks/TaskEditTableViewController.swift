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
    
    var taskDate: Date = Date()
    var duration: TimeInterval = TimeInterval(3600)
    
    var newTask:Bool = true
    
    var collection:MeteorCoreDataCollection = (UIApplication.shared.delegate as! AppDelegate).events
    
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
            self.newTask = false
            
            self.taskDate = event.date!
            self.duration = TimeInterval(event.duration)
            
            self.taskDescriptionField.text = event.event_description
        } else {
            self.newTask = true
        }
        
        self.datePicker.setDate(self.taskDate, animated: false)
        self.changeFieldValue(self.datePicker)
        
        self.startTimePicker.setDate(self.taskDate, animated: false)
        self.changeFieldValue(self.startTimePicker)
        
        self.durationPicker.countDownDuration =  TimeInterval(self.duration)
        self.changeFieldValue(self.durationPicker)
        
        taskDescriptionField.becomeFirstResponder()
    }
    
    // MARK: - Actions
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let description = taskDescriptionField.text ?? "";
        // TODO: add update or insert into DATABASE!!!
        //            todos.insert(["_id":_id, "listId":listId!, "text":task] as NSDictionary)
        //        let update = ["checked":!checked]
        //        todos.update(id, fields: update)
        if(self.newTask) {
            
        } else {
            let update = ["event_description":description, "duration":self.duration ] as [String : Any]
            self.collection.update(id: (self.taskToEdit?.id)!, fields: update as NSDictionary)
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Picker View Methods
    
    @objc func changeFieldValue(_ sender: UIDatePicker) {
        
        let gregorian = Calendar(identifier: .gregorian)
        var sender_date = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: sender.date)
        var task_date = sender_date
        
        switch sender {
        case datePicker:
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateField.text = dateFormatter.string(from: sender.date)
            
            task_date.year = sender_date.year
            task_date.month = sender_date.month
            task_date.day = sender_date.day
            
            self.taskDate = gregorian.date(from: task_date)!
            
        case startTimePicker:
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = DateFormatter.Style.short
            startTimeField.text = timeFormatter.string(from: sender.date)
            
            task_date.hour = sender_date.hour
            task_date.minute = sender_date.minute
            task_date.second = sender_date.second
            
            self.taskDate = gregorian.date(from: task_date)!
            
            
        case durationPicker:
            let timeFormatter = DateComponentsFormatter()
            timeFormatter.unitsStyle = .abbreviated
            timeFormatter.allowedUnits = [.hour, .minute]
            durationField.text = timeFormatter.string(from: sender.countDownDuration)
            
            self.duration = sender.countDownDuration
            
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
    
    // MARK: - Unused
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
