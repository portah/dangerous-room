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

import CoreData

public class ManagedObjectObserver: NSObject {
    private(set) var managedObject: NSManagedObject
    
    public enum ChangeType: CustomStringConvertible {
        case Inserted
        case Updated
        case Deleted
        case Refreshed
        case Invalidated
        
        public var description: String {
            switch self {
            case .Inserted:
                return "Inserted"
            case .Updated:
                return "Updated"
            case .Deleted:
                return "Deleted"
            case .Refreshed:
                return "Refreshed"
            case .Invalidated:
                return "Invalidated"
            }
        }
    }
    
    typealias ChangeHandler = (_ changeType: ChangeType) -> Void
    private var handler: ChangeHandler
    
    init(_ managedObject: NSManagedObject, handler: @escaping ChangeHandler) {
        self.managedObject = managedObject
        self.handler = handler
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: Selector(("objectsDidChange:")), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObject.managedObjectContext)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func objectsDidChange(notification: NSNotification) {
        func notificationContainsObjectForUserInfoKey(userInfoKey: NSString) -> Bool {
            if let objects = notification.userInfo![userInfoKey] as? NSSet {
                return objects.contains(managedObject)
            }
            return false
        }
        
        if notificationContainsObjectForUserInfoKey(userInfoKey: NSInsertedObjectsKey as NSString) {
            handler(.Inserted)
        } else if notificationContainsObjectForUserInfoKey(userInfoKey: NSUpdatedObjectsKey as NSString) {
            handler(.Updated)
        } else if notificationContainsObjectForUserInfoKey(userInfoKey: NSDeletedObjectsKey as NSString) {
            handler(.Deleted)
        } else if notificationContainsObjectForUserInfoKey(userInfoKey: NSRefreshedObjectsKey as NSString) {
            handler(.Refreshed)
        } else if notificationContainsObjectForUserInfoKey(userInfoKey: NSInvalidatedObjectsKey as NSString) || notification.userInfo![NSInvalidatedAllObjectsKey] != nil {
            handler(.Invalidated)
        }
    }
}
