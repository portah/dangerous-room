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


import Foundation
import CoreData
import SwiftyBeaver

public protocol MeteorCoreDataStack {
    var mainContext: NSManagedObjectContext { get }
    var backgroundContext: NSManagedObjectContext { get }
    var managedObjectContext:NSManagedObjectContext { get }
}

class MeteorCoreDataStackPersisted:NSObject, MeteorCoreDataStack {
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: Selector("mergeCoreDataChanges:"),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundContext)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "MeteorCoreData", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        return coordinator
    }
    
    var managedObjectContext:NSManagedObjectContext {
        if (OperationQueue.current == OperationQueue.main) {
            return self.mainContext
        }
        return backgroundContext
    }
    
    
    lazy var mainContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        context.stalenessInterval = 0
        return context
        }()
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        context.stalenessInterval = 0
        return context
        }()
    
    func mergeCoreDataChanges(notification: NSNotification) {
        let context = notification.object as! NSManagedObjectContext
        if context === mainContext {
            log.debug("Merging changes mainQueue > privateQueue")
            backgroundContext.perform() {
                self.backgroundContext.mergeChanges(fromContextDidSave: notification as Notification)
            }
        } else if context === backgroundContext {
            log.debug("Merging changes privateQueue > mainQueue")
            mainContext.perform() {
                self.mainContext.mergeChanges(fromContextDidSave: notification as Notification)
            }
        } else {
            log.debug("Merging changes mainQueue <> privateQueue")
            backgroundContext.perform() {
                self.backgroundContext.mergeChanges(fromContextDidSave: notification as Notification)
            }
            
            mainContext.perform() {
                self.mainContext.mergeChanges(fromContextDidSave: notification as Notification)
            }
            
        }
    }
}
