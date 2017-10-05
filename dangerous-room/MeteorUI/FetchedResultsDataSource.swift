// Copyright (c) 2014-2015 Martijn Walraven
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import CoreData

public class FetchedResultsDataSource: NSObject, NSFetchedResultsControllerDelegate, UIDataSourceModelAssociation {
    
    private(set) var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    
    var managedObjectContext: NSManagedObjectContext {
        return fetchedResultsController.managedObjectContext
    }
    
    public init(fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.fetchedResultsController = fetchedResultsController
        super.init()
    }
    
    public func performFetch() {
        var error: NSError?
        do {
            print ("DR: performFetch try")
            try fetchedResultsController.performFetch()
            print ("DR: performFetch complete")
            reloadData()
            fetchedResultsController.delegate = self
        } catch let error1 as NSError {
            error = error1
            if error != nil {
                didFailWithError(error: error!)
            }
        }
    }
    
    func didFailWithError(error: NSError) {
        print ("DR: did fail with error: \(error.domain)")
    }
    
    // MARK: - Accessing Results
    
    public var numberOfSections: Int {
        let t = 1 //fetchedResultsController.sections?.count ?? 1
        print ("DR: numberOfSections \(t)")

        return t
    }
    
    public func numberOfItemsInSection(section: Int) -> Int {
        let t = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        print ("DR: numberOfItemsInSection \(t)")

        return t
    }
    
    public var objects: [NSManagedObject] {
        let t = fetchedResultsController.fetchedObjects as! [NSManagedObject]
        print ("DR: get objects?")
        print (t)
        return t //fetchedResultsController.fetchedObjects as! [NSManagedObject]
    }
    
    public func objectAtIndexPath(indexPath: IndexPath) -> NSManagedObject {
        return fetchedResultsController.object(at: indexPath) as! NSManagedObject
    }
    
    public func indexPathForObject(object: NSManagedObject) -> IndexPath? {
        return fetchedResultsController.indexPath(forObject: object)
    }
    
    // MARK: - Observing Changes
    
    enum ChangeDetail: CustomStringConvertible {
        case SectionInserted(Int)
        case SectionDeleted(Int)
        case ObjectInserted(IndexPath)
        case ObjectDeleted(IndexPath)
        case ObjectUpdated(IndexPath)
        case ObjectMoved(indexPath: IndexPath, newIndexPath: IndexPath)
        
        var description: String {
            switch self {
            case .SectionInserted(let sectionIndex):
                return "SectionInserted(\(sectionIndex))"
            case .SectionDeleted(let sectionIndex):
                return "SectionDeleted(\(sectionIndex))"
            case .ObjectInserted(let indexPath):
                return "ObjectInserted(\(indexPath))"
            case .ObjectDeleted(let indexPath):
                return "ObjectDeleted(\(indexPath))"
            case .ObjectUpdated(let indexPath):
                return "ObjectUpdated(\(indexPath))"
            case let .ObjectMoved(indexPath, newIndexPath):
                return "ObjectMoved(\(indexPath) -> \(newIndexPath))"
            }
        }
    }
    
    private var changes: [ChangeDetail]?
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        changes = [ChangeDetail]()
    }
    
    public func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type) {
        case .insert:
            changes!.append(.SectionInserted(sectionIndex))
        case .delete:
            changes!.append(.SectionDeleted(sectionIndex))
        default:
            break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange object: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case .insert:
            changes!.append(.ObjectInserted(newIndexPath!))
        case .delete:
            changes!.append(.ObjectDeleted(indexPath!))
        case .update:
            changes!.append(.ObjectUpdated(indexPath!))
        case .move:
            changes!.append(.ObjectMoved(indexPath: indexPath!, newIndexPath: newIndexPath!))
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        didChangeContent(changes: changes!)
        changes = nil
    }
    
    // MARK: - Change Notification
    
    func reloadData() {
    }
    
    func didChangeContent(changes: [ChangeDetail]) {
    }
    
    // MARK: - UIDataSourceModelAssociation
    
    public func modelIdentifierForElement(at idx: IndexPath, in view: UIView) -> String? {
        let object = objectAtIndexPath(indexPath: idx)
        return object.objectID.uriRepresentation().absoluteString
    }
    
    public func indexPathForElement(withModelIdentifier identifier: String, in view: UIView) -> IndexPath? {
        let URIRepresentation = NSURL(string: identifier)!
        let objectID = managedObjectContext.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: URIRepresentation as URL)!
        let object = managedObjectContext.object(with: objectID)
        return indexPathForObject(object: object)
    }
}
