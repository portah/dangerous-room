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
        updateTask(task: Task( id: UUID().uuidString,
                  description: "going to vivarium Room 6.149",
                  date: Date(),
                  duration: 3600,
                  completed: false
            ))
        updateTask(task: Task( id: UUID().uuidString,
                  description: "going to imaging Core Room",
                  date: Date(),
                  duration: 3600,
                  completed: true
            ))
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
    
    func updateTask(task: Task) {
        if let index = savedTasks.index(of: task) {
            savedTasks[index] = task
        } else {
            addTask(task: task)
        }
    }
    
    func doneTask(task: Task) {
        updateTask(task: Task( id: task.id,
                               description: task.description,
                               date: task.date,
                               duration: task.duration,
                               completed: true))
    }
}
