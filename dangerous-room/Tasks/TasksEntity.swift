//
//  TaskEntity.swift
//  dangerous-room
//
//  Created by Andrey Kartashov on 8/16/17.
//  Copyright © 2017 st.porter. All rights reserved.
//

import Foundation

struct Task: Equatable {
    var id:String = UUID().uuidString
    var description: String = ""
    var date: Date
    var duration: TimeInterval = 60
    var completed: Bool = false
}

func == (task1: Task, task2: Task) -> Bool {
//    return task1.description == task2.description && task1.date == task2.date
    return task1.id == task2.id
}
