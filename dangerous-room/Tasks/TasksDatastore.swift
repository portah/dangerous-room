//
//  TasksDatastore.swift
//  dangerous-room
//
//  Created by Andrey Kartashov on 8/16/17.
//  Copyright © 2017 st.porter. All rights reserved.
//

import Foundation

class TasksDatastore {
    fileprivate var savedTasks = [Task]()
    
    init() {
        savedTasks = [
            Task( description: "going to vivarium Room 6.149",
                  date: NSDate(),
                  startTime: NSDate(),
                  duration: 3600,
                  completed: false
            ),
            Task( description: "going to imaging Core Room",
                  date: NSDate(),
                  startTime: NSDate(),
                  duration: 3600,
                  completed: true
            )
        ]
    }
    
    func tasks() -> [Task] {
        return savedTasks
    }
}

// MARK: Actions
extension TasksDatastore {
    func addTask(task: Task) {
        savedTasks = savedTasks + [task]
    }
    
    func deleteTask(task: Task?) {
        if let task = task {
            savedTasks = savedTasks.filter({$0 != task})
        }
        
    }
    
    func doneTask(task: Task) {
        deleteTask(task: task)
        addTask(task: Task( description: task.description,
                            date: task.date,
                            startTime: task.startTime,
                            duration: task.duration,
                            completed: true))
    }
}
