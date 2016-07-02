//
//  StopwatchViewController.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 05.04.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit

class StopwatchViewController: UIViewController {
    let app = UIApplication.sharedApplication()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var timer: NSTimer!
    var startDate: NSDate! // time begins to run on pressing start
    var splitStartDate: NSDate!
    var secondsFromNSDate: Double! // NSDate interval from now to start moment
    var secondsFromSplitNSDate: Double!
    var timeKeeper: Double = 0  // time keeps track of latest tome when pause pressed
    var splitTimeKeeper: Double! = 0
    var splitNumber = 0
    
    private struct TimeConstants {
        static let SecInHour:Int = 3600
        static let SecInMinute:Int = 60
    }
    
    @IBOutlet weak var runningTimeLabel: UILabel!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var startTimerButton: UIButton! // start/pause button outlet
    @IBOutlet weak var splitAndResetButton: UIButton! // split/reset button outlet
    @IBOutlet weak var sleepModeButton: UIButton!
    @IBOutlet weak var showAllResultsButton: UIButton!
    
    @IBAction func switchSleepMode(sender: UIButton) {
        
    }
    
    @IBAction func startTimer(sender: UIButton) {
        if appDelegate.startPressed == false {
            // the user pressed Start
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(timerBeep), userInfo: nil, repeats: true)
            startDate = evaluateStartTime(timeKeeper)
            splitStartDate = evaluateStartTime(splitTimeKeeper)
            sender.setImage(UIImage(named: "PauseButton"), forState: .Normal)
            splitAndResetButton.setImage(UIImage(named: "SplitButton"), forState: .Normal)
            appDelegate.startPressed = true
        } else {
            // the user pressed Pause
            automaticPressPauseButton()
        }
    }
    
    @IBAction func resetOrMakeSplit(sender: UIButton) {
        if appDelegate.startPressed == false {
            // the user pressed Reset
            showAllResultsButton.setTitle("", forState: .Normal)
            startDate = NSDate(); splitStartDate = NSDate()
            timeKeeper = 0 ; splitTimeKeeper = 0 ; splitNumber = 0
            timerBeep()
            
        } else {
            // the user pressed Split
            splitStartDate = NSDate()
            splitNumber += 1
            showAllResultsButton.setTitle("#\(splitNumber) \(splitLabel.text!)", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func showAllResults(sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func automaticPressPauseButton() {
        if appDelegate.startPressed == true {
            startTimerButton.setImage(UIImage(named: "StartButton"), forState: .Normal)
            splitAndResetButton.setImage(UIImage(named: "ResetButton"), forState: .Normal)
            timeKeeper = secondsFromNSDate // take the latest time on timer
            splitTimeKeeper = secondsFromSplitNSDate
            appDelegate.startPressed = false
            timer.invalidate()
        }
    }
    
    func evaluateStartTime(timeDifferenceBetweenNowAndTimeOfPause: Double) -> NSDate {
        if timeDifferenceBetweenNowAndTimeOfPause == 0 {
            return NSDate()
        } else {
            return NSDate(timeIntervalSinceNow: -timeDifferenceBetweenNowAndTimeOfPause)
        }
    }
    
    func timerBeep() {
        secondsFromNSDate = -(startDate.timeIntervalSinceNow)
        secondsFromSplitNSDate = -(splitStartDate.timeIntervalSinceNow)
        runningTimeLabel.text = getTimeLabelFromTimeNumbers(secondsFromNSDate)
        splitLabel.text = getTimeLabelFromTimeNumbers(secondsFromSplitNSDate)
    }
    
    func getTimeLabelFromTimeNumbers(secFromNSDate : Double ) -> String {
        let min = ((secFromNSDate) / Double(TimeConstants.SecInMinute))  //I have no hours, so I can make more than 60 minutes // % Int(TimeConstants.SecInMinute)
        let sec = (secFromNSDate) % Double(TimeConstants.SecInMinute)
        let cs = ((secFromNSDate)) * 10 % 10
        let timeLabl = UILabel()
        timeLabl.text = timeToString(Int(min)) + ":" + timeToString(Int(sec)) + "." + "\(Int(cs))"
        return timeLabl.text!
    }
    
    func timeToString(selectedTime : Int!) -> String {
        if selectedTime < 10 {
            return "0\(selectedTime)"
        } else {
            return "\(selectedTime)"
        }
    }
}
