//
//  SettingsViewController.swift
//  dangerous-room
//
//  Created by Konstantin on 19/10/2017.
//  Copyright © 2017 st.porter. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet var phoneFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        debugPrint(phoneFields)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func addContactsTapped(_ sender: UIButton) {
        debugPrint(sender.tag)
    }
    
    @IBAction func phoneFieldEdited(_ sender: UITextField) {
        
    }
}
