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
    
    var startDate = NSDate() // time begins to run on pressing start
    var secondsFromNSDate = Double() // NSDate interval from now to start moment
    var timeKeeper = Double() // time keeps track of latest tome when pause pressed
    
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
//        if soundIsOff == false || soundIsOff == nil {
//            
//            soundIsOff = true
//            soundOnOffOutlet.setImage(UIImage(named : "SoundOff"), forState: .Normal)
//            audioPlayer.volume = 0
//        } else {
//            soundIsOff = false
//            soundOnOffOutlet.setImage(UIImage(named : "SoundOn"), forState: .Normal)
//            audioPlayer.volume = 1
//        }
//        defaults.setObject(soundIsOff, forKey: Constants.KeysUsedInCountdownTimer.SoundOnOff)
    }
    
    @IBAction func minusOneMinuteButton(sender: UIButton) {
//        //  can work only under conditions
//        if timeLeftInTimer > 60 { // more than 1 minute
//            
//            plusMinute = false
//            minutesDelta -= 1
//            totalTimeEvaluate()
//            
//            changeTimeLabel()
//            
//        } else {
//            minusOneMinuteOutlet.enabled = false
//        }
    }

    @IBAction func plusOneMinuteButton(sender: UIButton) {
//        plusOneMinute()
//
//        changeTimeLabel()
//        
//        if minusOneMinuteOutlet.enabled == false {
//            minusOneMinuteOutlet.enabled = true
//        }
        
    }


    @IBAction func startOrPauseButton(sender: UIButton) {
//        startTimer(sender)
    }

    @IBAction func stopButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    // don't need to stop timer, because it stops in viewDidDisappear()
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
                
                if timeKeeper == 0 {
                    startDate = NSDate()
                } else {
                    startDate = NSDate(timeIntervalSinceNow: timeKeeper)
                }
                
                nameOfButton.setImage(UIImage(named: "PauseButton"), forState: .Normal)
                appDelegate.oneTimerStarted = true
            } else {
                // press pause
                
                timeKeeper = secondsFromNSDate // = -1 , -2, -3 ... with time ticking
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
//        timeKeeper = 0
//        minutesDelta = 0
        if let appDelegate = app.delegate as? AppDelegate {
            appDelegate.oneTimerStarted = false
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTextForTime = timeToString(startHr) + ":" + timeToString(startMin) + ":" + timeToString(startSec)
        
        // convert start time from hr, min, sec into seconds
        secondsFromChosenTime = TimeConstants.secInHour * startHr + TimeConstants.secInMinute * startMin + startSec

    // if user chose less than 60 seconds, disable "-1m" button
        if secondsFromChosenTime < 60 {
            minusOneMinuteOutlet.enabled = false
        } else {
            minusOneMinuteOutlet.enabled = true
        }
//
//        // take chosen melody
//        if let chosMelodyNum = defaults.objectForKey(Constants.DefaultKeys.AudioKeyForChosenMelody) as? Int {
//            numOfChosenMelody = chosMelodyNum
//            audioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(Constants.arrayOfFileNames[numOfChosenMelody!], ofType:"mp3")!)
//        } else {
//            audioURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(Constants.MelodyFileNames.SimpleSoundFileName, ofType: "mp3")!)
//        }
//        audioPlayer = try! AVAudioPlayer(contentsOfURL: audioURL!)
//        
//        notificationCenter.addObserver(self, selector: "actOnSwitchToStopwatch", name: Constants.CountdownNotificationKeys.TabBackToStopwatch, object: nil)
//        notificationCenter.addObserver(self, selector: "actOnSwitchBackToCountdown", name: Constants.CountdownNotificationKeys.TabBackToCountdown, object: nil)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 6/255, green: 167/255, blue: 244/255, alpha: 1)
        
    }
    
    func actOnSwitchToStopwatch() {
        //        println("-- recieved message of going to Stopwatch")
        switchToStopwatch = true
        startTextForTime = nil
    }
    
    func actOnSwitchBackToCountdown() {
        //        println("switchBackToCountdown = true")
        switchBackToCountdown = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if app.idleTimerDisabled == true {
            app.idleTimerDisabled = false
        }
        
//        notificationCenter.postNotificationName(Constants.CountdownNotificationKeys.TabToCountdown, object: self)
        
        // prepare time labels to be synchronized with time, user choose
        if startTextForTime != nil {
            runningTimeLabel.text = startTextForTime!
            totalTimeLabel.text = totalTimeText + startTextForTime!
        }
        

        
        //    MARK: -Audio
//        audioPlayer = try! AVAudioPlayer(contentsOfURL: audioURL!)
//        
//        if let soundVol = defaults.objectForKey(Constants.KeysUsedInCountdownTimer.SoundOnOff) as? Bool {
//            soundIsOff = soundVol
//            if soundIsOff == true {
//                soundOnOffOutlet.setImage(UIImage(named : "SoundOff"), forState: .Normal)
//                audioPlayer.volume = 0
//            } else {
//                soundOnOffOutlet.setImage(UIImage(named : "SoundOn"), forState: .Normal)
//                audioPlayer.volume = 1
//            }
//        } else {
//            soundOnOffOutlet.setImage(UIImage(named : "SoundOn"), forState: .Normal)
//            audioPlayer.volume = 1
//        }
//        
//        audioPlayer.prepareToPlay()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    //    add observer
//        notificationCenter.addObserver(app.delegate!,
//            selector: Selector("doLocalNotification"),
//            name: UIApplicationDidEnterBackgroundNotification,
//            object: nil)
//        
    //   start timer and set start data for labels
        if switchBackToCountdown == false {
            startTimer(startOrPauseOutlet)
        }
//
//    //    if return from StopwatchVC to RunVC :
//        switchToStopwatch = false
//        switchBackToCountdown = false
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        notificationCenter.postNotificationName(Constants.CountdownNotificationKeys.TabBackToStopwatch, object: self) 
//        defaults.setObject(timeLeftInTimer, forKey: Constants.KeysUsedInCountdownTimer.TimeLeft)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(false)
//        
//        notificationCenter.removeObserver(app.delegate!)
//        app.cancelAllLocalNotifications()
        
        if !switchToStopwatch {
            stopTimer()
            notificationCenter.removeObserver(self)
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
//            self.audioPlayer.stop()
        }))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default , handler: { (action: UIAlertAction) -> Void in
            self.stopTimer()
            self.navigationController?.popViewControllerAnimated(true)
    //        self.audioPlayer.stop()
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    

    
    func changeTimeLabel() {
        
        
        secondsFromNSDate = startDate.timeIntervalSinceNow // will be < 0 because in future is more time than in past , like 12:00 is Now , and 12:15 is future. So in the future at 12:15 we must subtract 15 seconds (-15 sec) to get that past 12:00.
        print("timeLeftInTimer: ")
        timeLeftInTimer = secondsFromChosenTime + Int(secondsFromNSDate) + minutesDelta * 60
        if timeLeftInTimer < 60 {
            minusOneMinuteOutlet.enabled = false
        } else {
            minusOneMinuteOutlet.enabled = true
        }
        
        var hours = timeLeftInTimer / TimeConstants.secInHour
        var minutes = ( timeLeftInTimer - (hours * TimeConstants.secInHour)) / TimeConstants.secInMinute % TimeConstants.secInMinute
        var seconds = ( timeLeftInTimer - (hours * TimeConstants.secInHour)) % TimeConstants.secInMinute
        
        print("hours : \(hours) minutes : \(minutes) seconds : \(seconds)")
        
        //  text for displaying on the screen
        runningTimeLabel.text = timeToString(hours) + ":" + timeToString(minutes) + ":" + timeToString(seconds)

 
        if  timeLeftInTimer == 0 {
            timer.invalidate()
            // or stopTimer()
    //    play audio if it wasn't played at background state
//            audioPlayer.play()
            
    //     alert action
            pushAlert()
        } else if timeLeftInTimer < 0 {
            hours = 0
            minutes = 0
            seconds = 0
            runningTimeLabel.text = timeToString(hours) + ":" + timeToString(minutes) + ":" + timeToString(seconds)
            
 /* do I realy need this variables? Looks a bit strange */
//            hourString = "00" ; minutesString = ":00" ; secondsString = ":00"
            stopTimer()
            pushAlert()
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


