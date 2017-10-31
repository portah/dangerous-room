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
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            log.debug(error)
        }
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
    func renderCell(_ cell:UITableViewCell, contact: Contacts) {
        cell.textLabel?.text = "\(contact.firstName ?? "") \(contact.lastName ?? "")"
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
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = fetchedResultsController.object(at: indexPath)
            if let meteorId = contact.id {
                collection.remove(withId: meteorId)
            } else {
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
        let cache = fetchedResultsController.object(at: fromIndexPath)
        var newOrder = fetchedResultsController.fetchedObjects!
        let uuid = (UIApplication.shared.delegate as! AppDelegate).uuid
        newOrder.remove(at: fromIndexPath.row)
        newOrder.insert(cache, at: to.row)
        for (index,obj) in newOrder.enumerated() {
            collection.update(id: obj.id!,fields: ["priority": index, "phoneID": uuid] as NSDictionary)
        }
    }
    
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
        
        if section.numberOfObjects >= 3 {
            let alert = UIAlertController(title: "Emergency contatacts", message: "Just three emergency contacts are allowed. Please remove someone first.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            log.error("3 contacts is enough!")
            return
        }
        let uuid = (UIApplication.shared.delegate as! AppDelegate).uuid

        let contactInfo: [String: Any] = ["lastName": contactProperty.contact.familyName, "firstName": contactProperty.contact.givenName, "telephone": phone.stringValue, "priority": section.numberOfObjects, "phoneID":uuid]
        
        log.debug("collection.insert, fields: \(contactInfo)")
        collection.insert(fields: contactInfo as NSDictionary)
    }
}


