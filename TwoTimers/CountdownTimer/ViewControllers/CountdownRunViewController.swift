//
//  CountdownRunViewController.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 29.03.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit
import AVFoundation

class CountdownRunViewController: UIViewController  {
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var timer = NSTimer()
    
    //    var for buttons +1min , -1min
    var minutesDelta = Int()
    var minutesForTotalTime = Int()
    
    var plusMinute = false
    var copyMinutes = Int()
    
    //  time data from CountdownSettingsVC (sec, min, hours)
    var startHr : Int!
    var startMin : Int!
    var startSec : Int!
    
    let app = UIApplication.sharedApplication()
    var notificationCenter = NSNotificationCenter.defaultCenter()
    
    
    var switchToStopwatch = false
    var switchBackToCountdown = false
    
    var soundIsOff : Bool?
    
    var startDate : NSDate? // time begins to run on pressing start , and it's value is set in viewDidAppear (first time)
//    var secondsFromNSDate = Double() // NSDate interval from now to start moment
    var timeKeeper : Double = 0 // time keeps track of latest tome when pause pressed
    
    var secondsFromChosenTime = Int() // time , chosen by user in PickerView , in seconds
    var timeLeftInTimer = Int() // time, left in timer , in seconds
    
    var startTextForTime : String? // string for time labels which is set while segue from Settings to Run VC
    
    private struct TimeConstants {
        static let secInHour = 3600
        static let secInMinute = 60
    }
    
    private struct StringsForAlert {
        struct TimeIsUpAlert {
            static let Title = NSLocalizedString("Time is up!", comment: "Time is up - message")
            static let ActionButton = NSLocalizedString("+1min", comment: "action to add one more minute")
        }
    }
    
    let totalTimeText = NSLocalizedString("Total time ", comment: "text before numbers of Total Time label")
    
    //   audio
    var audioURL : NSURL?
    var audioPlayer = AVAudioPlayer()
    
    var numOfChosenMelody : Int?
    

    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var runningTimeLabel: UILabel!

    @IBOutlet weak var startOrPauseOutlet: UIButton!
   
    @IBOutlet weak var soundOnOffOutlet: UIButton!
    
    @IBOutlet weak var minusOneMinuteOutlet: UIButton!
    
    
    @IBAction func soundOnOffButton(sender: UIButton) {
        if soundIsOff == false || soundIsOff == nil {
            
            soundIsOff = true
            soundOnOffOutlet.setImage(UIImage(named : "SoundOff"), forState: .Normal)
            audioPlayer.volume = 0
        } else {
            soundIsOff = false
            soundOnOffOutlet.setImage(UIImage(named : "SoundOn"), forState: .Normal)
            audioPlayer.volume = 1
        }
        defaults.setObject(soundIsOff, forKey: Constants.KeysUsedInCountdownTimer.SoundOnOff)
    }
    
    @IBAction func minusOneMinuteButton(sender: UIButton) {
        //  can work only under conditions
        if timeLeftInTimer > TimeConstants.secInMinute { // more than 1 minute
            plusMinute = false
            minutesDelta -= 1
            totalTimeEvaluate()
            
            changeTimeLabel()
            
        } else {
            minusOneMinuteOutlet.enabled = false
        }
    }

    @IBAction func plusOneMinuteButton(sender: UIButton) {
        plusOneMinute()

        changeTimeLabel()
        
        if minusOneMinuteOutlet.enabled == false {
            minusOneMinuteOutlet.enabled = true
        }
    }

    @IBAction func startOrPauseButton(sender: UIButton) {
        startTimer(sender)
    }

    @IBAction func stopButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTextForTime = timeToString(startHr) + ":" + timeToString(startMin) + ":" + timeToString(startSec)
        
        // convert start time from hr, min, sec into seconds
        secondsFromChosenTime = TimeConstants.secInHour * startHr + TimeConstants.secInMinute * startMin + startSec

    // if user chose less than 60 seconds, disable "-1m" button
        if secondsFromChosenTime < TimeConstants.secInMinute {
            minusOneMinuteOutlet.enabled = false
        } else {
            minusOneMinuteOutlet.enabled = true
        }

        // take chosen melody
        if let chosMelodyNum = defaults.objectForKey(Constants.DefaultKeys.AudioKeyForChosenMelody) as? Int {
            numOfChosenMelody = chosMelodyNum
            audioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(Constants.arrayOfFileNames[numOfChosenMelody!], ofType:"mp3")!)
        } else {
            audioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(Constants.MelodyFileNames.SimpleSoundFileName, ofType: "mp3")!)
        }
        audioPlayer = try! AVAudioPlayer(contentsOfURL: audioURL!)
        
        notificationCenter.addObserver(self, selector: "actOnSwitchToStopwatch", name: Constants.CountdownNotificationKeys.TabToStopwatch, object: nil)
        notificationCenter.addObserver(self, selector: "actOnSwitchBackToCountdown", name: Constants.CountdownNotificationKeys.TabBackToCountdown, object: nil)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 6/255, green: 167/255, blue: 244/255, alpha: 1)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if app.idleTimerDisabled == true {
            app.idleTimerDisabled = false
        }
        
        notificationCenter.postNotificationName(Constants.CountdownNotificationKeys.TabToCountdown, object: self)
        
        // prepare time labels to be synchronized with time, user choose
        if startTextForTime != nil {
            runningTimeLabel.text = startTextForTime!
            totalTimeLabel.text = totalTimeText + startTextForTime!
        }
        
        //    MARK: -Audio
        audioPlayer = try! AVAudioPlayer(contentsOfURL: audioURL!)
        
        if let soundVol = defaults.objectForKey(Constants.KeysUsedInCountdownTimer.SoundOnOff) as? Bool {
            soundIsOff = soundVol
            if soundIsOff == true {
                soundOnOffOutlet.setImage(UIImage(named : "SoundOff"), forState: .Normal)
                audioPlayer.volume = 0
            } else {
                soundOnOffOutlet.setImage(UIImage(named : "SoundOn"), forState: .Normal)
                audioPlayer.volume = 1
            }
        } else {
            soundOnOffOutlet.setImage(UIImage(named : "SoundOn"), forState: .Normal)
            audioPlayer.volume = 1
        }
        
        audioPlayer.prepareToPlay()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    //    add observer
        notificationCenter.addObserver(app.delegate!,
            selector: Selector("doLocalNotification"),
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil)
        
    //   start timer and set start data for labels
        if switchBackToCountdown == false {
            startTimer(startOrPauseOutlet)
        }

    //    if return from StopwatchVC to RunVC :
        switchToStopwatch = false
        switchBackToCountdown = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        
        notificationCenter.postNotificationName(Constants.CountdownNotificationKeys.TabBackToStopwatch, object: self)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(false)
        print("viewDidDisappear")
        notificationCenter.removeObserver(app.delegate!)
        app.cancelAllLocalNotifications()
        
        if !switchToStopwatch {
            stopTimer()
            notificationCenter.removeObserver(self)
        }
    }
    
    
    func actOnSwitchToStopwatch() {
        print("-- recieved message of going to Stopwatch")
        switchToStopwatch = true
        startTextForTime = nil
    }
    
    func actOnSwitchBackToCountdown() {
        //        println("switchBackToCountdown = true")
        switchBackToCountdown = true
    }
    
    func timeToString(selectedTime : Int!) -> String {
        if selectedTime < 10 {
            return "0\(selectedTime)"
        } else {
            return "\(selectedTime)"
        }
    }
    
    func plusOneMinute() {
        self.plusMinute = true
        self.minutesDelta += 1
        self.totalTimeEvaluate()
    }
    
    func startTimer(nameOfButton : UIButton) {
        
        if let appDelegate = app.delegate as? AppDelegate {
            if appDelegate.oneTimerStarted == false {
                
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("changeTimeLabel"), userInfo: nil, repeats: true)
                
                //      Calculate startDate only for calculating timeKeeper. For more comments look into changeTimeLabel().
                if timeKeeper != 0 {
                    startDate = NSDate(timeIntervalSinceNow: timeKeeper)
                } else {
                    startDate = NSDate()
                }
                
                nameOfButton.setImage(UIImage(named: "PauseButton"), forState: .Normal)
                appDelegate.oneTimerStarted = true
            } else {
                // press pause
                
                //                timeKeeper = secondsFromNSDate //for example, it is -15 if 15 sec passed startDate.timeIntervalSinceNow
                timer.invalidate()
                nameOfButton.setImage(UIImage(named: "StartButton"), forState: .Normal)
                appDelegate.oneTimerStarted = false
            }
        }
    }
    
    func stopTimer() {
        if let appDelegate = app.delegate as? AppDelegate {
            if appDelegate.oneTimerStarted {
                timer.invalidate()
            }
        }
        if let appDelegate = app.delegate as? AppDelegate {
            appDelegate.oneTimerStarted = false
        }
    }

    
    func pushAlert() {
        let alert = UIAlertController (title: StringsForAlert.TimeIsUpAlert.Title,
            message: "",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(title: StringsForAlert.TimeIsUpAlert.ActionButton , style: UIAlertActionStyle.Default , handler: { (action: UIAlertAction) -> Void in
    //        add +1 minute
            self.plusOneMinute()

    //        start timer
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("changeTimeLabel"), userInfo: nil, repeats: true)
            if let appDelegate = self.app.delegate as? AppDelegate {
                appDelegate.oneTimerStarted = true
            }
    //        stop playing sound after alert is closed
            self.audioPlayer.stop()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default , handler: { (action: UIAlertAction) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
            self.audioPlayer.stop()
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    

    
    func changeTimeLabel() {
        print("timer")
        if startDate != nil {
            timeKeeper = startDate!.timeIntervalSinceNow
        // timeKeeper always < 0. For example, timer started at 12:00:00. So in the future at 12:00:15 we must subtract 15 seconds (-15 sec) to get that past 12:00:00. Or user pressed pause, then pressed Start and it was 13:00:00 at the moment of pressing Start. In a second timeKeeper will be -1 , and time will be 13:00:01. That's why we need to set startDate at the moment of Start.
        }

        timeLeftInTimer = secondsFromChosenTime + Int(timeKeeper) + minutesDelta * TimeConstants.secInMinute
        
    //Set this value here for case of going to the background. So Local Notification will come in time, left in timer.
        if let appDelegate = self.app.delegate as? AppDelegate {
            appDelegate.secondsForFireDate = Double(timeLeftInTimer)
        }
        
        if timeLeftInTimer <= 0 {
            if timeLeftInTimer == 0 {
        //    play audio if it wasn't played in background state
                audioPlayer.play()
            }
        // the label of time must be fixed NOT to show smth like 00:0-10:0-11 (negative time)
            runningTimeLabel.text = "00:00:00"
            stopTimer()
            pushAlert()
        } else {
            if timeLeftInTimer < TimeConstants.secInMinute {
                minusOneMinuteOutlet.enabled = false
            } else {
                minusOneMinuteOutlet.enabled = true
            }
            let hours = timeLeftInTimer / TimeConstants.secInHour
            let minutes = (timeLeftInTimer - (hours * TimeConstants.secInHour)) / TimeConstants.secInMinute % TimeConstants.secInMinute
            let seconds = (timeLeftInTimer - (hours * TimeConstants.secInHour)) % TimeConstants.secInMinute

            //  text for displaying on the screen
            runningTimeLabel.text = timeToString(hours) + ":" + timeToString(minutes) + ":" + timeToString(seconds)
        }
    }
    
    func totalTimeEvaluate() {
        
        var localHoursFromDefaults = Int(startHr)
        let localMinutesFromDefaults = Int(startMin)
        
        minutesForTotalTime = (localMinutesFromDefaults + minutesDelta) % TimeConstants.secInMinute
        
        let leftOver = (localMinutesFromDefaults + minutesDelta) - (localMinutesFromDefaults + minutesDelta) % TimeConstants.secInMinute
        
        if leftOver != 0 {
            localHoursFromDefaults += leftOver / TimeConstants.secInMinute as Int!
        }
        
        if minutesForTotalTime < 0 {
            localHoursFromDefaults -= 1
            minutesForTotalTime = TimeConstants.secInMinute + minutesForTotalTime
        }
        
        if !plusMinute && localHoursFromDefaults < 0 {
            localHoursFromDefaults = 0
            minutesForTotalTime = 0
            minutesDelta = 0
        }
        
        totalTimeLabel.text = totalTimeText // This is NSLocalizedString , so the start of text for label will be availible for 2 languages
        totalTimeLabel.text = totalTimeLabel.text! + timeToString(startHr) + ":" + timeToString(minutesForTotalTime) + ":" + timeToString(startSec)
    }
}


