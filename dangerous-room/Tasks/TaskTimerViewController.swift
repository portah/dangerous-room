//
//  TaskTimerViewController.swift
//  dangerous-room
//
//  Created by Konstantin on 26/09/2017.
//  Copyright © 2017 st.porter. All rights reserved.
//

import UIKit

class TaskTimerViewController: UIViewController {
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var mainCountdownLabel: UILabel?
    @IBOutlet var infoView: UIView!
    @IBOutlet var aliveCountdownLabel: UILabel?
    @IBOutlet var aliveTimerView: UIView!
    
    //MARK: Variables
    
    lazy var aliveCircleLayer:CAShapeLayer = {
        let circle = CAShapeLayer()
        circle.frame = self.aliveTimerView.bounds
        
        var transform = CGAffineTransform(rotationAngle: CGFloat.pi / -2.0).translatedBy(x: -self.aliveTimerView.bounds.size.height, y: 0)
        
        let circlePath = CGPath(ellipseIn: self.aliveTimerView.bounds.insetBy(dx: 4, dy: 4), transform: &transform)
        
        circle.path = circlePath
        circle.strokeColor = UIColor(red:0.95, green:0.53, blue:0.63, alpha:1.0).cgColor
        circle.lineWidth = 2
        circle.fillColor = nil
        
        return circle
    }()
    
    lazy var aliveWhiteDiskLayer: CAShapeLayer = {
        let disk = CAShapeLayer()
        disk.frame = self.aliveTimerView.bounds
        
        let circlePath = CGPath(ellipseIn: self.aliveTimerView.bounds, transform: nil)
        
        disk.path = circlePath
        disk.strokeColor = nil
        disk.fillColor = UIColor.white.cgColor
        
        return disk
    }()
    
    var task: Events?
    var aliveTimeinterval: TimeInterval = 0
    var betweenAliveTimeinterval: TimeInterval = 0
    
    var mainTime: TimeInterval = 0 {
        didSet {
            let interval = Int(mainTime)
            let seconds = interval % 60
            let minutes = (interval / 60) % 60
            let hours = (interval / 3600)
            mainCountdownLabel?.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    var aliveTime: TimeInterval = 0 {
        didSet {
            let interval = Int(aliveTime)
            let seconds = interval % 60
            let minutes = (interval / 60) % 60
            aliveCountdownLabel?.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }

    //MARK: View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear
        
        aliveTimerView.backgroundColor = UIColor.clear
        aliveTimerView.alpha = 0.0
        aliveTimerView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        aliveTimerView.layer.insertSublayer(aliveCircleLayer, at: 0)
        aliveTimerView.layer.insertSublayer(aliveWhiteDiskLayer, at: 0)
        
        aliveCountdownLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 69, weight: UIFont.Weight.thin)
        mainCountdownLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 49, weight: UIFont.Weight.light)

        stopButton.layer.cornerRadius = stopButton.bounds.size.width / 2.0
        stopButton.layer.borderColor = UIColor.white.cgColor
        stopButton.layer.borderWidth = 1.0
        
        descriptionLabel.text = task?.description
        mainTime = TimeInterval(task?.duration ?? 0)
        mainTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(proccessMainTick), userInfo: nil, repeats: true)
        aliveSetupTimer = Timer.scheduledTimer(timeInterval: betweenAliveTimeinterval, target: self, selector: #selector(setupAliveCountdown), userInfo: nil, repeats: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        mainTimer?.invalidate()
        aliveTimer?.invalidate()
        aliveSetupTimer?.invalidate()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func stopButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func aliveTimerTapped(_ sender: Any) {
        self.isAliveTimerStarted = false
    }
    
    //MARK: Alive Timer
    func showAliveTimer() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = self.aliveTime
        
        self.aliveCircleLayer.removeAnimation(forKey: "countdownAnimation")
        self.aliveCircleLayer.add(animation, forKey: "countdownAnimation")
        
        let pulse = CAKeyframeAnimation(keyPath: "transform")
        pulse.values = [
            CATransform3DMakeScale(1.0, 1.0, 0.0),
            CATransform3DMakeScale(1.08, 1.08, 0.0),
            CATransform3DMakeScale(1.0, 1.0, 0.0),
        ]
        pulse.keyTimes = [0.001, 0.1, 0.3]
        pulse.duration = 1.0
        pulse.repeatDuration = self.aliveTime
        
        self.aliveCircleLayer.removeAnimation(forKey: "pulseAnimation")
        self.aliveWhiteDiskLayer.removeAnimation(forKey: "pulseAnimation")
        self.aliveCircleLayer.add(pulse, forKey: "pulseAnimation")
        self.aliveWhiteDiskLayer.add(pulse, forKey: "pulseAnimation")

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4.0, options: [], animations: {
            self.aliveTimerView.alpha = 1.0
            self.aliveTimerView.transform = CGAffineTransform.identity
            
            self.infoView.alpha = 0.0
            self.infoView.transform = CGAffineTransform(translationX: 0, y: -50)
            
            self.stopButton.alpha = 0.0
            self.stopButton.transform = CGAffineTransform(translationX: 0, y: 50)
        }, completion: nil)
    }
    
    func hideAliveTimer() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 4.0, options: [], animations: {
            self.aliveTimerView.alpha = 0.0
            self.aliveTimerView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            
            self.infoView.alpha = 1.0
            self.infoView.transform = CGAffineTransform.identity
            
            self.stopButton.alpha = 1.0
            self.stopButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    //MARK: Timers
    var mainTimer: Timer?
    var aliveSetupTimer: Timer?
    var aliveTimer: Timer?
    var isAliveTimerStarted = false {
        didSet {
            if isAliveTimerStarted {
                aliveTime = aliveTimeinterval
                aliveTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(proccessAliveTick), userInfo: nil, repeats: true)
                showAliveTimer()
            } else {
                hideAliveTimer()
                aliveTimer?.invalidate()
                aliveSetupTimer = Timer.scheduledTimer(timeInterval: betweenAliveTimeinterval, target: self, selector: #selector(setupAliveCountdown), userInfo: nil, repeats: false)
            }
        }
    }

    @objc(proccessMainTick)
    func proccessMainTick() {
        if self.mainTime == 0 {
            print("Main time is over")
        }
        
        self.mainTime -= 1
    }
    
    @objc(proccessAliveTick)
    func proccessAliveTick() {
        if self.aliveTime == 0 {
            print("Alarm! Alarm!")
            return
        }
        
        self.aliveTime -= 1
    }
    
    @objc(setupAliveCountdown)
    func setupAliveCountdown() {
        self.isAliveTimerStarted = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
