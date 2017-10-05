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

@objc public protocol FetchedResultsTableViewDataSourceDelegate: NSObjectProtocol {
    @objc optional func dataSource(dataSource: FetchedResultsTableViewDataSource, didFailWithError error: NSError)
    @objc optional func dataSource(dataSource: FetchedResultsTableViewDataSource, cellReuseIdentifierForObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) -> String
    @objc optional func dataSource(dataSource: FetchedResultsTableViewDataSource, configureCell cell: UITableViewCell, forObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    @objc optional func dataSource(dataSource: FetchedResultsTableViewDataSource, deleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
}

public class FetchedResultsTableViewDataSource: FetchedResultsDataSource, UITableViewDataSource {
    weak var tableView: UITableView!
    weak var delegate: FetchedResultsTableViewDataSourceDelegate?
    
    init(tableView: UITableView, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView = tableView
        
        super.init(fetchedResultsController: fetchedResultsController)
    }
    
    override func didFailWithError(error: NSError) {
        delegate?.dataSource?(dataSource: self, didFailWithError: error)
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItemsInSection(section: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = objectAtIndexPath(indexPath: indexPath)
        let reuseIdentifier = cellReuseIdentifierForObject(object: object, atIndexPath: indexPath as NSIndexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath as IndexPath)
        configureCell(cell: cell, forObject: object, atIndexPath: indexPath)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let object = objectAtIndexPath(indexPath: indexPath as IndexPath)
            delegate?.dataSource?(dataSource: self, deleteObject: object, atIndexPath: indexPath as NSIndexPath)
        }
    }
    
    // MARK: Cell Configuration
    
    func cellReuseIdentifierForObject(object: NSManagedObject, atIndexPath indexPath: NSIndexPath) -> String {
        return delegate?.dataSource?(dataSource: self, cellReuseIdentifierForObject: object, atIndexPath: indexPath) ?? "Cell"
    }
    
    func configureCell(cell: UITableViewCell, forObject object: NSManagedObject, atIndexPath indexPath: IndexPath) {
        delegate?.dataSource?(dataSource: self, configureCell: cell, forObject: object, atIndexPath: indexPath as NSIndexPath)
    }
    
    // MARK: - Change Notification
    
    override func reloadData() {
        print ("DR: reload data")
        tableView.reloadData()
    }
    
    override func didChangeContent(changes: [ChangeDetail]) {
        // Don't perform incremental updates when the table view is not currently visible
        if tableView.window == nil {
            reloadData()
            return;
        }
        
        tableView.beginUpdates()
        
        for change in changes {
            switch(change) {
            case .SectionInserted(let sectionIndex):
                tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
            case .SectionDeleted(let sectionIndex):
                tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
            case .ObjectInserted(let newIndexPath):
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            case .ObjectDeleted(let indexPath):
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .ObjectUpdated(let indexPath):
                if let cell = tableView.cellForRow(at: indexPath) {
                    let object = objectAtIndexPath(indexPath: indexPath)
                    configureCell(cell: cell, forObject: object, atIndexPath: indexPath)
                }
            case .ObjectMoved(let indexPath, let newIndexPath):
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        
        tableView.endUpdates()
    }
    
    // MARK: - Selection
    
    var selectedObject: NSManagedObject? {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            return objectAtIndexPath(indexPath: selectedIndexPath)
        } else {
            return nil
        }
    }
}
