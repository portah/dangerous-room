//
//  TaskTimerViewControllerExtensions.swift
//  dangerous-room
//
//  Created by Andrey Kartashov on 10/8/17.
//  Copyright © 2017 st.porter. All rights reserved.
//

import Foundation
import SwiftDDP

extension TaskTimerViewController {
    
    func notifyServerAboutEvent ( status: String, for id: String) {
        let uuid = (UIApplication.shared.delegate as! AppDelegate).uuid
        log.debug("notifyServerAboutEvent \(status) for id \(id)")
        Meteor.call("dangerous-room/event/status", params: [id, status, uuid]) { result, error in
            print("result: \(String(describing: result)), error:\(String(describing: error))")
        }
    }

}
