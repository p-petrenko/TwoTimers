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
    private var timeKeeper : Double = 0 // time keeps track of latest tome when pause pressed
    
    var secondsFromChosenTime = Int() // time , chosen by user in PickerView , in seconds
    var timeLeftInTimer = Int() // time, left in timer , in seconds
    
    var startTextForTime : String? // string for time labels which is set while segue from Settings to Run VC
    
    var appDelegate: AppDelegate!
    
    private struct TimeConstants {
        static let SecInHour = 3600
        static let SecInMinute = 60
    }
    
    private struct StringsForAlert {
        struct TimeIsUpAlert {
            static let Title = NSLocalizedString("Time is up!", comment: "Time is up - message")
            static let ActionButton = NSLocalizedString("+1min", comment: "action to add one more minute")
        }
    }
    
    private struct TimeLabelConstants {
        static let ZeroTimeLabel = "00:00:00"
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
        plusMinusMinute(-1)
    }

    @IBAction func plusOneMinuteButton(sender: UIButton) {
        plusMinusMinute(1)
    }

    @IBAction func startOrPauseButton(sender: UIButton) {
        startTimer(sender)
    }

    @IBAction func stopButton(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        // convert start time from hr, min, sec into seconds.Must be done to count number of hr, min, sec in changeTimeLabel() and totalTimeEvaluate()
        secondsFromChosenTime = TimeConstants.SecInHour * startHr + TimeConstants.SecInMinute * startMin + startSec

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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if app.idleTimerDisabled == true {
            app.idleTimerDisabled = false
        }
        
        notificationCenter.postNotificationName(Constants.CountdownNotificationKeys.TabToCountdown, object: self)
        
        // prepare time labels to be synchronized with time in seconds
        changeTimeLabel()
        totalTimeEvaluate()
        
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
        notificationCenter.postNotificationName(Constants.CountdownNotificationKeys.TabBackToStopwatch, object: self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(false)
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
//        print("switchBackToCountdown = true")
        switchBackToCountdown = true
    }
    
    func plusMinusMinute(delta : Int) {
        switch delta {
        case 1:
            self.plusMinute = false
            self.minutesDelta += 1
        case -1:
            self.plusMinute = true
            self.minutesDelta -= 1
        default:
            print("Delta value for minutes must be -1 or 1.")
        }
        totalTimeEvaluate()
        changeTimeLabel()
    }
    
    func timeToString(selectedTime : Int!) -> String {
        if selectedTime < 10 {
            return "0\(selectedTime)"
        } else {
            return "\(selectedTime)"
        }
    }

    func startTimer(nameOfButton : UIButton) {
        
        if appDelegate.oneTimerStarted == false {
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("changeTimeLabel"), userInfo: nil, repeats: true)
            
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
            timer.invalidate()
            nameOfButton.setImage(UIImage(named: "StartButton"), forState: .Normal)
            appDelegate.oneTimerStarted = false
        }
    }
    
    func stopTimer() {

        if appDelegate.oneTimerStarted {
            timer.invalidate()
        }
        appDelegate.oneTimerStarted = false

    }

    
    func pushAlert() {
        let alert = UIAlertController (title: StringsForAlert.TimeIsUpAlert.Title,
            message: "",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(title: StringsForAlert.TimeIsUpAlert.ActionButton , style: UIAlertActionStyle.Default , handler: { (action: UIAlertAction) -> Void in
    //        add +1 minute
            self.plusMinusMinute(1)
    // changeTimeLabel() is for updating time label, because with timer start it will be called in 2 seconds, not in 1 second like I want. Will be shown 00:00:59 instead 00:00:58.
            self.changeTimeLabel()

            self.appDelegate.oneTimerStarted = true

    //        stop playing sound after alert is closed
            self.audioPlayer.stop()
            
    //        start timer
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("changeTimeLabel"), userInfo: nil, repeats: true)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default , handler: { (action: UIAlertAction) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
            self.audioPlayer.stop()
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func changeTimeLabel() {
        if startDate != nil {
            timeKeeper = startDate!.timeIntervalSinceNow
        // timeKeeper always < 0. For example, timer started at 12:00:00. So in the future at 12:00:15 we must subtract 15 seconds (-15 sec) to get that past 12:00:00. Or user pressed pause, then pressed Start and it was 13:00:00 at the moment of pressing Start. In a second timeKeeper will be -1 , and time will be 13:00:01. That's why we need to set startDate at the moment of Start.
        }

        timeLeftInTimer = secondsFromChosenTime + Int(timeKeeper) + minutesDelta * TimeConstants.SecInMinute
        
    //Set this value here for case of going to the background. So Local Notification will come in time, left in timer.
        appDelegate.secondsForFireDate = Double(timeLeftInTimer)

        if timeLeftInTimer <= 0 {
            if timeLeftInTimer == 0 {
        //    play audio if it wasn't played in background state
                audioPlayer.play()
            }
        // the label of time must be fixed NOT to show smth like 00:0-10:0-11 (negative time)
            runningTimeLabel.text = TimeLabelConstants.ZeroTimeLabel
            stopTimer()
            pushAlert()
        } else {
            if timeLeftInTimer < TimeConstants.SecInMinute {
                minusOneMinuteOutlet.enabled = false
            } else {
                minusOneMinuteOutlet.enabled = true
            }
            let hours = timeLeftInTimer / TimeConstants.SecInHour
            let minutes = (timeLeftInTimer - (hours * TimeConstants.SecInHour)) / TimeConstants.SecInMinute % TimeConstants.SecInMinute
            let seconds = (timeLeftInTimer - (hours * TimeConstants.SecInHour)) % TimeConstants.SecInMinute

            //  text for displaying on the screen
            runningTimeLabel.text = timeToString(hours) + ":" + timeToString(minutes) + ":" + timeToString(seconds)
        }
    }
    
    func totalTimeEvaluate() {
        
        var hoursFromStart = Int(startHr)
        let minutesFromStart = Int(startMin)
        
        minutesForTotalTime = (minutesFromStart + minutesDelta) % TimeConstants.SecInMinute
        print("minutesForTotalTime = \(minutesForTotalTime)")
        
        let leftOver = (minutesFromStart + minutesDelta) - (minutesFromStart + minutesDelta) % TimeConstants.SecInMinute
        
        if leftOver != 0 {
            hoursFromStart += leftOver / TimeConstants.SecInMinute as Int!
        }
        
        if minutesForTotalTime < 0 {
            hoursFromStart -= 1
            minutesForTotalTime = TimeConstants.SecInMinute + minutesForTotalTime
        }
        
        if !plusMinute && hoursFromStart < 0 {
            hoursFromStart = 0
            minutesForTotalTime = 0
            minutesDelta = 0
        }
        
        totalTimeLabel.text = totalTimeText // This is NSLocalizedString , so the start of text for label will be availible for 2 languages
        totalTimeLabel.text = totalTimeLabel.text! + timeToString(startHr) + ":" + timeToString(minutesForTotalTime) + ":" + timeToString(startSec)
    }
}


