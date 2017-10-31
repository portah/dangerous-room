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
import SwiftDDP
import SwiftyBeaver

public protocol MeteorCoreDataCollectionDelegate {
    func document(willBeCreatedWith fields:NSDictionary?, forObject object:NSManagedObject) -> NSManagedObject
    func document(willBeUpdatedWith fields:NSDictionary?, cleared:[String]?, forObject object:NSManagedObject) -> NSManagedObject
}

public class MeteorCoreDataCollection: AbstractCollection {
    let log = SwiftyBeaver.self
    
    private let entityName:String
    private let stack:MeteorCoreDataStack
    private var changeLog = [Int:MeteorCollectionChange]()
    
    private lazy var mainContext:NSManagedObjectContext = { return self.stack.mainContext }()
    private lazy var backgroundContext:NSManagedObjectContext = { return self.stack.backgroundContext }()
    
    public var delegate:MeteorCoreDataCollectionDelegate?
    
    public init(collectionName:String, entityName:String) {
        self.entityName = entityName
        self.stack = MeteorCoreData.stack
        super.init(name: collectionName)
    }
    
    public init(collectionName:String, entityName:String, stack:MeteorCoreDataStack) {
        self.entityName = entityName
        self.stack = stack
        super.init(name: collectionName)
    }
    
    public var managedObjectContext:NSManagedObjectContext {
        return stack.managedObjectContext
    }
    
    internal func newObject() -> NSManagedObject {
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
        let object = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
        return object
    }
    
    // Retrieves all results for a given entity name
    public func find() -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let results = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
            return results!
        } catch let error {
            print("Error fetching results \(error)")
        }
        return []
    }
    
    
    // Retrieves a single result by name
    public func findOne(id:String) -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == '\(id)'")
        let results = try! managedObjectContext.fetch(fetchRequest)
        if results.count > 0 {
            return results[0] as? NSManagedObject
        }
        return nil
    }
    
    public func exists(id:String) -> Bool {
        //        let error = NSErrorPointer()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == '\(id)'")
        do {
            let count = try managedObjectContext.count(for: fetchRequest)
            return count > 0
        } catch let error as NSError {
            print("Error fetching results \(error)")
            return false
        }
        
    }
    
    public func exists(collection:String, id:String) -> Bool {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == '\(id)' AND collection == '\(collection)'")
        print("Managed object context \(managedObjectContext) id == '\(id)' AND collection == '\(collection)'")
        do {
            let count = try managedObjectContext.count(for: fetchRequest)
            return count > 0
        }
        catch let error as NSError {
            print("Error fetching results \(error)")
            return false
        }
    }
    
    //
    //
    //
    // INSERT
    //
    //
    //
    
    public func insert(fields:NSDictionary) {
        backgroundContext.perform() {
            let _fields = NSMutableDictionary()
            let object = self.newObject()
            
            if let id = fields.object(forKey: "_id") {
                object.setValue(id, forKey: "id")
            } else {
                let id = self.client.getId()
                _fields["_id"] = id
                object.setValue(id, forKey: "id")
            }
            object.setValue(self.name, forKey: "collection")
            
            for (key, value) in fields {
                _fields[key] = value
            }

            _ = self.delegate?.document(willBeCreatedWith: _fields, forObject: object)
            try! self.managedObjectContext.save()

            self.log.debug("MeteorCoreDataCollection insert fields: \(fields) into: \(self.name)")
            
            let result = self.client.insert(sync: self.name, document: [_fields])
            if result.error != nil {
                self.managedObjectContext.delete(object)
                try! self.managedObjectContext.save()
            }
            
        }
    }
    
    //
    //
    //
    // UPDATE
    //
    //
    //
    public func update(id:String, fields:NSDictionary, action:String, local:Bool) {
        backgroundContext.perform() {
            
            if let document = self.findOne(id: id) {
                
                let cache = document.dictionary
                
                let change = MeteorCollectionChange(id: id, collection: self.name, fields: fields, cleared: nil)
                self.changeLog[change.hashValue] = change
                
                var cleared:[String]!
                
                if action == "$unset" {
                    cleared = []
                    for (key, value) in fields {
                        if (((value as? String) == "true") || ((value as? Bool) == true)) {
                            cleared.append(key as! String)
                        }
                    }
                }
                
                _ = self.delegate?.document(willBeUpdatedWith: fields, cleared: cleared, forObject: document)
                try! self.managedObjectContext.save()
                
                if local == false {
                    let result = self.client.update(sync: self.name, document: [["_id":id], [action:fields]])
                    if result.error != nil {
                        self.log.debug("Update rejected. Attempting to rollback changes")
                        for (key, _) in fields {
                            document.setValue(cache.object(forKey: key), forKey: key as! String)
                        }
                        try! self.managedObjectContext.save()
                    }
                }
            }
        }
    }
    
    public func update(id:String, fields:NSDictionary, local:Bool) {
        update(id: id, fields:fields, action:"$set", local:false)
    }
    
    public func update(id:String, fields:NSDictionary, action:String) {
        update(id: id, fields:fields, action:action, local:false)
    }
    
    
    public func update(id:String, fields:NSDictionary) {
        update(id: id, fields:fields, action:"$set", local:false)
    }
    
    //
    //
    //
    // REMOVE
    //
    //
    //
    
    public func remove(withId id:String) {
        remove(withId: id, local:false)
    }
    
    // Local delete signals when the delete originates from the server; 
    // In that case, the delete should only be processed locally, and no 
    // message regarding the delete should be sent to the server
    public func remove(withId id:String, local:Bool) {
        backgroundContext.perform() {
            
            if let document = self.findOne(id: id) {
                
                let cache = document.dictionary
                
                let id = document.value(forKey: "id")
                self.managedObjectContext.delete(document)
                try! self.managedObjectContext.save()
                
                if local == false {
                    if let _ = id {
                        let result = self.client.remove(sync: self.name, document: NSArray(arrayLiteral: ["_id":id!]) as! [Any])
                        if result.error != nil {
                            let replacement = self.newObject()
                            _ = self.delegate?.document(willBeCreatedWith: cache, forObject: replacement)
                            self.managedObjectContext.insert(replacement)
                            try! self.managedObjectContext.save()
                        }
                    }
                }
            }
        }
    }

    override public func documentWasAdded(_ collection: String, id: String, fields: [String: Any]?) {
        backgroundContext.perform() {
            if !self.exists(collection: collection, id:id) {
                let object = self.newObject()
                object.setValue(id, forKey: "id")
                object.setValue(collection, forKey: "collection")
                
                if let _ = self.delegate?.document(willBeCreatedWith: fields! as NSDictionary, forObject: object) {
                    do {
                        try self.managedObjectContext.save()
                    } catch let error {
                        self.log.error("MeteorCoreDataCollection documentWasAdded: \(error)")
                    }
                }
            } else {
                self.log.info("Object \(collection) \(id) already exists in the database")
            }
        }
    }
    
    
    
    override public func documentWasChanged(_ collection: String, id: String, fields: [String: Any]?, cleared:[String]?) {
        backgroundContext.perform() {
            let currentChange = MeteorCollectionChange(id: id, collection: collection, fields: fields! as NSDictionary, cleared: cleared)
            
            if let priorChange = self.changeLog[currentChange.hashValue], (priorChange.hashValue == currentChange.hashValue) {
                self.changeLog[currentChange.hashValue] = nil
                return
            }
            
            if let object = self.findOne(id: id) {
                if let _ = self.delegate?.document(willBeUpdatedWith: fields! as NSDictionary, cleared: cleared, forObject: object) {
                    do {
                        try self.managedObjectContext.save()
                    } catch let error  {
                        self.log.error("\(error)")
                    }
                }
            }
            
            self.changeLog[currentChange.hashValue] = nil // Deregister the change
        }
    }
    
    override public func documentWasRemoved(_ collection: String, id: String) {
        if self.exists(collection: collection, id:id) {
            self.remove(withId:id, local: true)
        } else {
            self.log.debug("document \(id) not found")
        }
    }
    
    
}
