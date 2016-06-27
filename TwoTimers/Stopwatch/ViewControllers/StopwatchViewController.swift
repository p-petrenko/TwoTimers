//
//  StopwatchViewController.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 05.04.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit

class StopwatchViewController: UIViewController {
    
    //    time vars for main time labels
    var minutes = Float()
    var seconds = Float()
    var centiseconds = Int()
    
    //    time var for interval labels
    var intervalMinutes = Float()
    var intervalSeconds = Float()
    var intervalCentiseconds = Int()
    
    var timer = NSTimer()
    
    let zeroTextLabel = "00:00.00"
    
    var splitNumber = Int()
    
    //    arrays for SplitResultsTVC
    var arrayOfSplitNumbers = [String]()
    var arrayOfSplitResults = [String]()
    var arrayOfDevivceTimeAndDate = [NSDate]()
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    let center = NSNotificationCenter.defaultCenter()
    
    let app = UIApplication.sharedApplication()
    
    var switchToCountdown = false
    var switchBackToStopwatch = false
    var sleepModeOff = false
    
    var startDate = NSDate() // time begins to run on pressing start
    var splitStartDate = NSDate()
    
    private var secondsFromNSDate = Double() // NSDate interval from now to start moment
    var secondsFromSplitNSDate = Double()
    
    var timeKeeper = Double() // time keeps track of latest tome when pause pressed
    var splitTimeKeeper = Double()
    
    struct TimeConstants {
        static let SecInHour: Float = 3600
        static let SecInMinute : Float = 60
    }
    
    @IBOutlet weak var runningTimeLabel: UILabel!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var startTimerButton: UIButton! // start/pause button outlet
    @IBOutlet weak var splitAndResetButton: UIButton! // split/reset button outlet
    @IBOutlet weak var sleepModeButton: UIButton!
    @IBOutlet weak var showAllResultsButton: UIButton!
    
    @IBAction func switchSleepMode(sender: UIButton) {
        if sleepModeOff == false {
            // make it true and switch off sleep of the screen
            app.idleTimerDisabled = true
            sleepModeOff = true
            sleepModeButton.setImage(UIImage(named: "SleepModeOff"), forState: .Normal)
        } else {
            app.idleTimerDisabled = false
            sleepModeOff = false
            sleepModeButton.setImage(UIImage(named: "SleepModeOn"), forState: .Normal)
        }
        defaults.setObject(sleepModeOff, forKey: Constants.KeysUsedInStopwatch.SleepMode)
    }
    
    
    @IBAction func startTimer(sender: UIButton) {
        if let appDelegate = app.delegate as? AppDelegate {
            
            if appDelegate.startPressed == false {
                //      if user press Start
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(StopwatchViewController.timerBeep), userInfo: nil, repeats: true)
                
                if timeKeeper == 0 {
                    print("timeKeeper == 0")
                    startDate = NSDate()
                } else {
                    print("timeKeeper != 0")
                    startDate = NSDate(timeIntervalSinceNow: -timeKeeper)
                }
                
                if splitTimeKeeper == 0 {
                    splitStartDate = NSDate()
                } else {
                    splitStartDate = NSDate(timeIntervalSinceNow: -splitTimeKeeper)
                }
                sender.setImage(UIImage(named: "PauseButton"), forState: .Normal)
                splitAndResetButton.setImage(UIImage(named: "SplitButton"), forState: .Normal)
                appDelegate.startPressed = true
                
            } else {
                //      if user press Pause
                timeKeeper = secondsFromNSDate // take the latest time on timer
                splitTimeKeeper = secondsFromSplitNSDate
                
                timer.invalidate()
                sender.setImage(UIImage(named: "StartButton"), forState: .Normal)
                splitAndResetButton.setImage(UIImage(named: "ResetButton"), forState: .Normal)
                appDelegate.startPressed = false
                
                defaults.setObject(splitLabel.text, forKey: Constants.KeysUsedInStopwatch.SplitTimeLabel)
                
                defaults.setObject(runningTimeLabel.text, forKey: Constants.KeysUsedInStopwatch.MainTimeLabel)
                
                defaults.setObject(timeKeeper, forKey: Constants.KeysUsedInStopwatch.TimeKeeperKey)
                defaults.setObject(splitTimeKeeper, forKey: Constants.KeysUsedInStopwatch.SplitTimeKeeperKey)
            }
        }
    }

    @IBAction func resetOrMakeSplit(sender: UIButton) {
        if let appDelegate = app.delegate as? AppDelegate {
            if appDelegate.startPressed == true {
                //  Split mode of split/reset button (if Start button is pressed, there can only be Split mode for split/reset button)
                //  add new data to array
                splitNumber += 1
                arrayOfSplitNumbers.append("\(splitNumber)")
                showAllResultsButton.setTitle("#\(splitNumber) \(splitLabel.text!)", forState: UIControlState.Normal)
                
                arrayOfSplitResults.append("\(splitLabel.text!) ")
                arrayOfDevivceTimeAndDate.append(NSDate()) // NSDate() is taken from the computer, and it is current date and time
                splitStartDate = NSDate()
                
                defaults.setObject(arrayOfSplitNumbers , forKey: Constants.KeysUsedInStopwatch.SplitNumber)
                defaults.setObject(arrayOfSplitResults, forKey: Constants.KeysUsedInStopwatch.IntervalTimeResult)
                defaults.setObject(arrayOfDevivceTimeAndDate, forKey: Constants.KeysUsedInStopwatch.DateAndTime)
                
            } else if appDelegate.startPressed == false {
                // Reset mode of split/reset button
                minutes = 0 ; seconds = 0 ; centiseconds = 0
                timeKeeper = 0
                splitTimeKeeper = 0
                
                runningTimeLabel.text = zeroTextLabel
                showAllResultsButton.setTitle("", forState: .Normal)
                
                automaticPressPauseButton()
                resetValuesAndDefaults()
            }
            //  change interval time to zero
            splitLabel.text = zeroTextLabel
            intervalMinutes = 0 ; intervalSeconds = 0 ; intervalCentiseconds = 0
        }
    }
    
    @IBAction func showAllResults(sender: UIButton) {
    }

    
    func resetValuesAndDefaults() {
        splitNumber = 0
        arrayOfSplitNumbers = []
        arrayOfSplitResults = []
        arrayOfDevivceTimeAndDate = []
        showAllResultsButton.setTitle("", forState: .Normal)
        
        defaults.setObject(nil , forKey: Constants.KeysUsedInStopwatch.SplitNumber)
        
//        defaults.setObject(nil, forKey: Constants.KeysUsedInStopwatch.IntervalTimeResult)
//        defaults.setObject(nil, forKey: Constants.KeysUsedInStopwatch.DateAndTime)
//        self.defaults.setObject(nil, forKey: Constants.KeysUsedInStopwatch.SplitEventName)
        
        defaults.setObject(zeroTextLabel, forKey: Constants.KeysUsedInStopwatch.SplitTimeLabel)
        defaults.setObject(zeroTextLabel, forKey: Constants.KeysUsedInStopwatch.MainTimeLabel)
        
        defaults.setObject(nil, forKey: Constants.KeysUsedInStopwatch.TimeKeeperKey)
        defaults.setObject(nil, forKey: Constants.KeysUsedInStopwatch.SplitTimeKeeperKey)
        
        defaults.setObject([Bool](), forKey: Constants.KeysUsedInStopwatch.ArrayToCheckIfResultIsSaved)
        
        defaults.setObject(nil, forKey: Constants.KeysUsedInStopwatch.DatesOfDeletedCells)
        defaults.setObject(nil, forKey: Constants.KeysUsedInStopwatch.DataOfCellsWithEditedNames)
        
    }
    

    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "Split Results Segue" && splitNumber != 0 {
            automaticPressPauseButton()
            return true
        }
            
        else if identifier == "Folder in StopwatchVC Segue" {
            if let arrayOfIntls = defaults.objectForKey(Constants.KeysUsedInStopwatch.IntervalTimeSavedArray) as? [String] {
                if !arrayOfIntls.isEmpty {
                    automaticPressPauseButton()
                    return true
                }
            }
        }
        return false
    }
    
    func automaticPressPauseButton() {
        timer.invalidate()
        if let appDelegate = app.delegate as? AppDelegate {
            if appDelegate.startPressed == true {
                appDelegate.startPressed = false
                
                startTimerButton.setImage(UIImage(named: "StartButton"), forState: .Normal)
                splitAndResetButton.setImage(UIImage(named: "ResetButton"), forState: .Normal)
                
                timeKeeper = secondsFromNSDate
                splitTimeKeeper = secondsFromSplitNSDate
                
                defaults.setObject(splitLabel.text, forKey: Constants.KeysUsedInStopwatch.SplitTimeLabel)
                
                defaults.setObject(runningTimeLabel.text, forKey: Constants.KeysUsedInStopwatch.MainTimeLabel)
                
                defaults.setObject(timeKeeper, forKey: Constants.KeysUsedInStopwatch.TimeKeeperKey)
                defaults.setObject(splitTimeKeeper, forKey: Constants.KeysUsedInStopwatch.SplitTimeKeeperKey)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        center.addObserver(self, selector: #selector(StopwatchViewController.actOnSwitchToCountdown), name: Constants.StopwatchNotificationKey.TabToCountdown, object: nil)
        center.addObserver(self, selector: #selector(StopwatchViewController.actOnSwitchBackToStopwatch), name: Constants.StopwatchNotificationKey.TabBackToStopwatch, object: nil)
        
    }
    
    func actOnSwitchToCountdown() {
        switchToCountdown = true
    }
    
    func actOnSwitchBackToStopwatch() {
        switchBackToStopwatch = true
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        center.postNotificationName(Constants.StopwatchNotificationKey.TabToStopwatch, object: self)
        
        center.addObserver(app.delegate!,
            selector: #selector(AppDelegate.timeIntervalForStopwatch),
            name: UIApplicationWillEnterForegroundNotification,
            object: nil)
        
        if switchBackToStopwatch == false {
            if let numberArray = defaults.objectForKey(Constants.KeysUsedInStopwatch.SplitNumber) as? [String] {
                arrayOfSplitNumbers = numberArray
                splitNumber = numberArray.count
            }
            
            if let intervalArray = defaults.objectForKey(Constants.KeysUsedInStopwatch.IntervalTimeResult) as? [String] {
                arrayOfSplitResults = intervalArray
                if arrayOfSplitResults != [] {
                    showAllResultsButton.setTitle("#\(splitNumber) \(arrayOfSplitResults.last!)", forState: .Normal)
                }
            }
            
            if let dateTime = defaults.objectForKey(Constants.KeysUsedInStopwatch.DateAndTime) as? [NSDate] {
                arrayOfDevivceTimeAndDate = dateTime
            }
            
            if let splTLabel = defaults.objectForKey(Constants.KeysUsedInStopwatch.SplitTimeLabel) as? String {
                
                splitLabel.text = splTLabel
            }
            
            if let mainTLabel = defaults.objectForKey(Constants.KeysUsedInStopwatch.MainTimeLabel) as? String {
                
                runningTimeLabel.text = mainTLabel
            }
            
            if let mainLablTimeKeeper = defaults.objectForKey(Constants.KeysUsedInStopwatch.TimeKeeperKey) as? Double {
                timeKeeper = mainLablTimeKeeper
            }
            
            if let splLablTimeKeeper = defaults.objectForKey(Constants.KeysUsedInStopwatch.SplitTimeKeeperKey) as? Double {
                splitTimeKeeper = splLablTimeKeeper
            }
        }
        switchToCountdown = false
        switchBackToStopwatch = false
        
        var imageFolderFilled = UIImage(named: "FolderFilled")
        imageFolderFilled = imageFolderFilled?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        if let arrayOfIntls = defaults.objectForKey(Constants.KeysUsedInStopwatch.IntervalTimeSavedArray) as? [String] {
            if arrayOfIntls != [String]() {
                self.navigationItem.rightBarButtonItem?.image = imageFolderFilled
            } else {
                self.navigationItem.rightBarButtonItem?.image = UIImage()
            }
        } else {
            self.navigationItem.rightBarButtonItem?.image = UIImage()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let sleepMode = defaults.objectForKey(Constants.KeysUsedInStopwatch.SleepMode) as? Bool {
            sleepModeOff = sleepMode
            if sleepModeOff == false {
                app.idleTimerDisabled = false
                sleepModeOff = false
                sleepModeButton.setImage(UIImage(named: "SleepModeOn"), forState: .Normal)
            } else {
                app.idleTimerDisabled = true
                sleepModeOff = true
                sleepModeButton.setImage(UIImage(named: "SleepModeOff"), forState: .Normal)
            }
        } else {
            app.idleTimerDisabled = false
            sleepModeOff = false
            sleepModeButton.setImage(UIImage(named: "SleepModeOn"), forState: .Normal)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        center.postNotificationName(Constants.StopwatchNotificationKey.TabBackToCountdown, object: self)
        
        if switchToCountdown == false {
            defaults.setObject(splitLabel.text, forKey: Constants.KeysUsedInStopwatch.SplitTimeLabel)
            defaults.setObject(runningTimeLabel.text, forKey: Constants.KeysUsedInStopwatch.MainTimeLabel)
        }
        
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        center.removeObserver(app.delegate!)
        app.cancelAllLocalNotifications()
    }
    
    func timerBeep() {
        
        if let timeIntlWhileBgr = defaults.valueForKey(Constants.KeysUsedInStopwatch.StopwatchTimeInterval) as? Float {
            // take existing min, sec and convert it to only seconds
            var min = Int()
            var sec = Int()
            let secondsFromCurrentTime = Int(TimeConstants.SecInMinute) * Int(minutes) + Int(seconds)
            let secondsAfterComeBack = Float(secondsFromCurrentTime) + timeIntlWhileBgr
            
            min = (Int(secondsAfterComeBack) - Int(secondsAfterComeBack / TimeConstants.SecInHour)) / Int(TimeConstants.SecInMinute)
            sec = (Int(secondsAfterComeBack) - Int(secondsAfterComeBack / TimeConstants.SecInHour)) % Int(TimeConstants.SecInMinute)
            
            minutes = Float(min)
            seconds = Float(sec)
            //       for interval
            
            let secondsFromCurrentInterval = Int(TimeConstants.SecInMinute) * Int(intervalMinutes) + Int(intervalSeconds)
            let intervalSecondsAfterComeBack = Float(secondsFromCurrentInterval) + timeIntlWhileBgr
            
            min = (Int(intervalSecondsAfterComeBack) - Int(intervalSecondsAfterComeBack / TimeConstants.SecInHour)) / Int(TimeConstants.SecInMinute) % Int(TimeConstants.SecInMinute)
            sec = (Int(intervalSecondsAfterComeBack) - Int(intervalSecondsAfterComeBack / TimeConstants.SecInHour)) % Int(TimeConstants.SecInMinute)
            
            intervalMinutes = Float(min)
            intervalSeconds = Float(sec)
        }
        secondsFromNSDate = -(startDate.timeIntervalSinceNow)
        secondsFromSplitNSDate = -(splitStartDate.timeIntervalSinceNow)
        
        runningTimeLabel.text = timerForMinutesAndSeconds(startDate , secFromNSDate : secondsFromNSDate)
        splitLabel.text = timerForMinutesAndSeconds(splitStartDate, secFromNSDate : secondsFromSplitNSDate)
        
        defaults.setValue(nil, forKey: Constants.KeysUsedInStopwatch.StopwatchTimeInterval)
    }
    
    
    func timerForMinutesAndSeconds(startNSDate : NSDate , secFromNSDate : Double ) -> String {
        
        var min = (Float(secFromNSDate)) / (TimeConstants.SecInMinute)  //I have no hours, so I can make more than 60 minutes // % Int(TimeConstants.SecInMinute)
        var sec = (Float(secFromNSDate)) % (TimeConstants.SecInMinute)
        var cs = Float(secFromNSDate) * 100 % 100
        
        let timeLabl = UILabel()
        
        
        //   timer isn't supposed to work more than 99 minutes, so after this time stop stopwatch and make it zero
        if min > 99 {
            // reset timer
            timer.invalidate()
            min = 0 ; sec = 0 ; cs = 0
            
            timeKeeper = 0
            splitTimeKeeper = 0
            
            runningTimeLabel.text = zeroTextLabel
            showAllResultsButton.setTitle("", forState: .Normal)
            
            automaticPressPauseButton()
            resetValuesAndDefaults()
        }
        
        if min < 10 {
            timeLabl.text = "0\(Int(min))"
        } else {
            timeLabl.text = "\(Int(min))"
        }
        
        if sec < 10 {
            
            timeLabl.text = timeLabl.text! + ":" + "0\(Int(sec))"
        } else {
            timeLabl.text = timeLabl.text! + ":" + "\(Int(sec))"
        }
        
        if cs > 99 {
            cs = 0
        }
        if cs < 10 {
            timeLabl.text = timeLabl.text! + ".0\(Int(cs))"
        } else {
            timeLabl.text = timeLabl.text! + ".\(Int(cs))"
        }
        return timeLabl.text!
    }
    
    
}
