//
//  PhonesTableViewController.swift
//  dangerous-room
//
//  Created by Konstantin on 25/10/2017.
//  Copyright © 2017 st.porter. All rights reserved.
//

import UIKit
import ContactsUI
import CoreData
import SwiftDDP
import SwiftyBeaver

class PhonesTableViewController: MeteorCoreDataTableViewController, CNContactPickerDelegate {
    
    var collection:MeteorCoreDataCollection = (UIApplication.shared.delegate as! AppDelegate).contacts
    var contactPicker: CNContactPickerViewController?

    lazy var fetchedResultsController: NSFetchedResultsController<Contacts> = {
        let fetchRequest: NSFetchRequest<Contacts> = Contacts.fetchRequest()
        let primarySortDescriptor = NSSortDescriptor(key: "priority", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.collection.managedObjectContext,
                                             sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.leftBarButtonItem = self.editButtonItem
//        collection.delegate = self
        
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    func renderCell(_ cell:UITableViewCell, contact: Contacts) {
        cell.textLabel?.text = "\(contact.lastName ?? "") \(contact.firstName ?? "")"
        cell.detailTextLabel?.text = contact.telephone
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        log.debug("Phones: sections.count \(sections.count)")
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Phones"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }

        log.debug("Phones: section \(section), numberOfObjects \(sections[section].numberOfObjects)")

        return sections[section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath)

        renderCell(cell, contact: fetchedResultsController.object(at: indexPath))

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = fetchedResultsController.object(at: indexPath)
            if let meteorId = contact.id {
                collection.remove(withId: meteorId)
            }
            else {
                if let moc = contact.managedObjectContext {
                    moc.delete(contact)
                    do {
                        try moc.save()
                    }
                    catch let error {
                        log.error("Error saving managedObjectContext: \(error.localizedDescription)")
                    }
                }
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
     */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Actions
    @IBAction func addTapped(_ sender: Any) {
        contactPicker = CNContactPickerViewController()
        contactPicker?.displayedPropertyKeys = [CNContactFamilyNameKey, CNContactMiddleNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey]
        contactPicker?.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0", argumentArray: nil)
        contactPicker?.predicateForSelectionOfProperty = NSPredicate(format: "key == 'phoneNumbers'", argumentArray: nil)
        contactPicker?.delegate = self

        if let contactPicker = contactPicker {
            present(contactPicker, animated: true, completion: nil)
        }
    }
    
    // MARK: Contact Picker Delegate
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        contactPicker?.dismiss(animated: true, completion: nil)

        log.debug(contactProperty)

        guard let phone = contactProperty.value as? CNPhoneNumber else {
            log.error("Selected CNContactProperty is nil or not a CNPhoneNumber: \(contactProperty)")
            // FIXME: inform user about this problem
            return
        }
        
        guard let section = fetchedResultsController.sections?.first else {
            log.error("No sections in PhonesTableViewController.fetchedResultsController")
            return
        }
        
        let contactInfo: [String: Any] = ["lastName": contactProperty.contact.familyName, "firstName": contactProperty.contact.givenName, "telephone": phone.stringValue, "priority": section.numberOfObjects]
        
        log.debug("collection.insert, fields: \(contactInfo)")
        collection.insert(fields: contactInfo as NSDictionary)
    }
}

