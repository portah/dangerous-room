//
//  AppDelegate.swift
//  Dangerous Room
//
//  Created by Konstantin on 24/06/2017.
//  Copyright © 2017 kst404. All rights reserved.
//

import UIKit
import SwiftDDP
import CoreData
import SwiftyBeaver
import UserNotifications

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let events = MeteorCoreDataCollection(collectionName: "Events", entityName: "Events")
    let contacts = MeteorCoreDataCollection(collectionName: "Contacts", entityName: "Contacts")
    var uuid:String = "unknown"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        if let _uuid = UIDevice.current.identifierForVendor?.uuidString {
            self.uuid = _uuid
            print("device? \(self.uuid)")
        }

        let console = ConsoleDestination()  // log to Xcode Console
        console.format = "$DHH:mm:ss$d $L $M"
        log.addDestination(console)
        
        let url = "ws://localhost:3000/websocket"
        // let url = "wss://dangerous-room.porter.st/websocket"

        Meteor.connect(url) {
            Meteor.subscribe("dangerous-room/events", params: [self.uuid])
            Meteor.subscribe("dangerous-room/contacts", params: [self.uuid])
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}


