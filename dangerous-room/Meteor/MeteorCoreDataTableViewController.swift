// Copyright (c) 2015 Peter Siegesmund <peter.siegesmund@icloud.com>
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

public class MeteorCoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .move: print("> Move"); if indexPath != newIndexPath {
            self.tableView.moveRow(at: indexPath! as IndexPath, to: newIndexPath! as IndexPath)
        } else {
            self.tableView.reloadRows(at: [indexPath! as IndexPath], with: UITableViewRowAnimation.fade)
            }
        case .delete: print("> Delete"); self.tableView.deleteRows(at: [indexPath! as IndexPath], with: UITableViewRowAnimation.fade)
        case .insert: print("> Insert"); self.tableView.insertRows(at: [newIndexPath! as IndexPath], with: UITableViewRowAnimation.fade)
        case .update: print("> Update"); self.tableView.reloadRows(at: [indexPath! as IndexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
}

extension MeteorCoreDataTableViewController {
    func fetchedResultsControllerFor<T:NSManagedObject>(fetchRequest: NSFetchRequest<T>, managedObjectContext: NSManagedObjectContext) -> NSFetchedResultsController<T> {
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext,
                                             sectionNameKeyPath: nil, cacheName: nil)

        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: nil, queue: nil, using: { [weak self] notification in
            log.debug("NSManagedObjectContextObjectsDidChange: \(String(describing: notification.userInfo?.keys))")
            if (notification.userInfo?.keys.contains(NSInvalidatedAllObjectsKey))! {
                do {
                    try frc.performFetch()
                    self?.tableView.reloadData()
                }
                catch let error {
                    log.error(error.localizedDescription)
                }
            }
        })

        return frc
    }
}
