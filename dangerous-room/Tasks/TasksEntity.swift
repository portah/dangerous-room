//
//  TaskEntity.swift
//  dangerous-room
//
//  Created by Andrey Kartashov on 8/16/17.
//  Copyright © 2017 st.porter. All rights reserved.
//

import Foundation

struct Task: Equatable {
    let description: String
    let date: NSDate
    let startTime: NSDate
    let duration: NSNumber
    let completed: Bool
}

func == (task1: Task, task2: Task) -> Bool {
    return task1.description == task2.description && task1.date == task2.date
}
