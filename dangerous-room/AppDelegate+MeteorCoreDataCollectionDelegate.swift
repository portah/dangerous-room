//
//  AppDelegate+MeteorCoreDataCollectionDelegate.swift
//  dangerous-room
//
//  Created by Konstantin on 28/10/2017.
//  Copyright © 2017 st.porter. All rights reserved.
//
import UIKit
import SwiftDDP
import CoreData

extension AppDelegate: MeteorCoreDataCollectionDelegate {
    func document(willBeCreatedWith fields: NSDictionary?, forObject object: NSManagedObject) -> NSManagedObject {
        if let data = fields {
            for (key, value) in data {
                setObjValue(value, forKey: key as! String, forObject: object)
            }
        }
        log.debug("appDelegate willBeCreatedWith: \(object), fields: \(String(describing: fields))")
        return object
    }
    
    
    func document(willBeUpdatedWith fields: NSDictionary?, cleared: [String]?, forObject object: NSManagedObject) -> NSManagedObject {
        if let _ = fields {
            for (key, value ) in fields! {
                setObjValue(value, forKey: key as! String, forObject: object)
            }
        }
        
        if let _ = cleared {
            for field in cleared! {
                object.setNilValueForKey(field)
            }
        }
        log.debug("appDelegate willBeUpdatedWith: \(object), fields: \(String(describing: fields))")
        return object
    }
    
    func setObjValue(_ value: Any?, forKey key: String, forObject object: NSManagedObject) {
        if (key as AnyObject).isEqual("date") {
            if value as? Date != nil {
                object.setValue(EJSON.convertToEJSONDate(value as! Date), forKey: key )
            } else {
                object.setValue(EJSON.convertToNSDate(value as! [String : Any]), forKey: key )
            }
        } else
            if !(key as AnyObject).isEqual("_id") {
                object.setValue(value, forKey: key )
        }
    }
}
