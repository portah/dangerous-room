//
//  Timer.swift
//  dangerous-room
//
//  Created by Andrey Kartashov on 8/25/17.
//  Copyright © 2017 st.porter. All rights reserved.
//

import Foundation
import QuartzCore

class DangerousTimer {
    typealias Tick = ()->Void
    var tick:Tick
    
    var beepInterval:TimeInterval = 60
    var timeInterval:TimeInterval = 0
    var lastInterval:TimeInterval = 0
    var currentInterval:TimeInterval = 0
    var duration:TimeInterval = 0
    var isRunning: Bool = false
    var isPause: Bool = false
    var beepTimes:Int = 0
    
    var timer:Timer?

    init( duration:TimeInterval, onTick:@escaping Tick){
        self.tick = onTick
        self.duration = duration
    }
    
    func start() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        self.lastInterval = self.getTime()
        print("Timer start")
    }

    func stop(){
        if(timer != nil) { timer!.invalidate() }
    }
    
    func getTime () -> TimeInterval{
        return CACurrentMediaTime() as TimeInterval
    }
    
    func getRest()->TimeInterval {
        return duration - timeInterval
    }
    
    @objc func update() {
        self.currentInterval = self.getTime()
        self.timeInterval =  self.currentInterval - self.lastInterval
        tick()
        if (self.duration <= self.timeInterval) {
            //DO BIG BEEEP
            stop()
        }
        if (self.beepTimes < Int(self.timeInterval / self.beepInterval)) {
            //DO SMALL BEEPS
            print("beep \(self.beepTimes)")
            self.beepTimes = Int(self.timeInterval / self.beepInterval)
        }
    }
}
