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
    @IBOutlet var endTimeField: UITextField!

    var datePicker = UIDatePicker(),
        startTimePicker = UIDatePicker(),
        endTimePicker = UIDatePicker()
    

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
        
        endTimePicker.datePickerMode = .time
        endTimePicker.addTarget(self, action: #selector(changeFieldValue), for: .valueChanged)
        endTimeField.inputView = endTimePicker
        
        dateField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Picker View Methods
    
    func changeFieldValue(_ sender: UIDatePicker) {
        switch sender {
        case datePicker:
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateField.text = dateFormatter.string(from: sender.date)
            
        case startTimePicker:
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = DateFormatter.Style.short
            startTimeField.text = timeFormatter.string(from: sender.date)
            
        case endTimePicker:
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = DateFormatter.Style.short
            endTimeField.text = timeFormatter.string(from: sender.date)
            
        default:
            break
        }
    }
    
    


    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return CGFloat.leastNonzeroMagnitude
        default:
            return 21
        }
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
