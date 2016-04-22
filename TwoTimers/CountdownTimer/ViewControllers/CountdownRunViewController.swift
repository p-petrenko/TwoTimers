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
    
    var plusMinute = false
    
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
    var audioData : NSData?
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
            soundOff()
        } else {
            soundIsOff = false
            soundOn()
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
        startOrPauseTimer(sender)
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
        takeChosenMelody()
        
        notificationCenter.addObserver(self, selector: #selector(CountdownRunViewController.actOnSwitchToStopwatch), name: Constants.CountdownNotificationKeys.TabToStopwatch, object: nil)
        notificationCenter.addObserver(self, selector: #selector(CountdownRunViewController.actOnSwitchBackToCountdown), name: Constants.CountdownNotificationKeys.TabBackToCountdown, object: nil)
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

        if let soundVol = defaults.objectForKey(Constants.KeysUsedInCountdownTimer.SoundOnOff) as? Bool {
            soundIsOff = soundVol
            if soundIsOff == true {
                soundOff()
            } else {
                soundOn()
            }
        } else {
            soundOn()
        }
        audioPlayer.prepareToPlay()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    //    add observer
        notificationCenter.addObserver(app.delegate!,
            selector: #selector(AppDelegate.doLocalNotification),
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil)
        
    //   start timer and set start data for labels
        if switchBackToCountdown == false {
            startOrPauseTimer(startOrPauseOutlet)
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
//        print("-- recieved message of going to Stopwatch")
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
            secondsFromChosenTime += 60
        case -1:
            self.plusMinute = true
            secondsFromChosenTime -= 60
        default:
            print("Delta value for minutes must be -1 or +1 minute.")
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

    func startOrPauseTimer(nameOfButton : UIButton) {
        if appDelegate.oneTimerStarted == false {
            startTimer()
            nameOfButton.setImage(UIImage(named: "PauseButton"), forState: .Normal)
        } else {
            // press pause
            stopTimer()
            nameOfButton.setImage(UIImage(named: "StartButton"), forState: .Normal)
        }
    }
    
    func startTimer() {
        // changeTimeLabel() function will implement itself in 0.2 seconds. The code in current function will be already implemented.
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(CountdownRunViewController.changeTimeLabel), userInfo: nil, repeats: true)
    //      Calculate startDate only for calculating timeKeeper. For more comments look into changeTimeLabel().
        if timeKeeper != 0 {
            // time of start recalculates, as if I started timer <a number = timeKeeper> seconds before now. For example, First time I started timer at 100 seconds (timeKeeper was = 0). At 115 seconds I pressed Pause (timeKeeper was = -15). At 200 seconds I restarted timer. startDate became NSDate() + timeKeeper = NSDate(timeIntervalSinceNow: timeKeeper) = 200 - 15 = 185 seconds.
            startDate = NSDate(timeIntervalSinceNow: timeKeeper)
        } else {
            startDate = NSDate()
        }
        appDelegate.oneTimerStarted = true
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
            // Action: add +1 minute
            // update startDate, because I need to add 1 minute to 0 , and not to -(time,waiting for pressing button in alert)
            self.audioPlayer.stop() // stops playing sound after button is pressed
            // First recalculate startDate in startTimer(), only then can add 1 minute to refreshed startDate.
            self.startTimer()
            self.plusMinusMinute(1)
            
        }))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default , handler: { (action: UIAlertAction) -> Void in
            // Action: Stop timer and return to timer settings
            self.navigationController?.popViewControllerAnimated(true)
            self.audioPlayer.stop()
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Changing time labels
    
    func changeTimeLabel() {
        // timeKeeper always < 0 after the moment of start. For example, timer started at 1000 sec (startDate). So in the future at 1015 sec (NSDate()) we must subtract 15 seconds (-15 sec = startDate.timeIntervalSinceNow) to get that past 1000 sec. That's why we need to set startDate at the moment of Start.
        if startDate != nil {
            timeKeeper = startDate!.timeIntervalSinceNow
        }
        timeLeftInTimer = secondsFromChosenTime + Int(timeKeeper)
        // Set this value here for case of going to the background. So Local Notification will come in time, left in timer.
        appDelegate.secondsForFireDate = Double(timeLeftInTimer)

        if timeLeftInTimer <= 0 {
            // play audio if it wasn't played in background state
            if timeLeftInTimer == 0 {
                audioPlayer.play()
            }
            // timeKeeper is used further if I choose "+1min" action in alert. If an app was in background and I didn't open notification immidiately, (NSDate() - startDate) will be -(secondsFromChosenTime + Time_of_Waiting_To_Open_the_App), and I change it to be -(secondsFromChosenTime) which is correct.
            timeKeeper = -Double(secondsFromChosenTime)
            // the label of time must be fixed NOT to show smth like 00:0-10:0-11 (negative time)
            timeLeftInTimer = 0
            stopTimer()
            pushAlert()
        }
        // if time < 61 sec , lock pressing "-1m" button
        if timeLeftInTimer < (TimeConstants.SecInMinute + 1) {
            minusOneMinuteOutlet.enabled = false
        } else {
            minusOneMinuteOutlet.enabled = true
        }
        calculateTimeAndSetTimeLabel(runningTimeLabel, timeInSeconds: timeLeftInTimer)
    }
    
    func totalTimeEvaluate() {
        calculateTimeAndSetTimeLabel(totalTimeLabel, timeInSeconds: secondsFromChosenTime)
    }
    
    // for seconds input must be secondsFromChosenTime (for totalTimeEvaluate) or timeLeftInTimer (for changeTimeLabel)
    func calculateTimeAndSetTimeLabel(timeLabel : UILabel , timeInSeconds : Int) {
        
        let hours = timeInSeconds / TimeConstants.SecInHour
        let minutes = (timeInSeconds - (hours * TimeConstants.SecInHour)) / TimeConstants.SecInMinute % TimeConstants.SecInMinute
        let seconds = (timeInSeconds - (hours * TimeConstants.SecInHour)) % TimeConstants.SecInMinute
        
        // add NSLocalizedString , so the start of text for total time label will be availible for 2 languages
        if timeLabel == totalTimeLabel {
            timeLabel.text = totalTimeText
        } else {
            timeLabel.text = ""
        }
        timeLabel.text = timeLabel.text! + timeToString(hours) + ":" + timeToString(minutes) + ":" + timeToString(seconds)
    }
    
    // MARK: - Audio functions
    
    func soundOff() {
        soundOnOffOutlet.setImage(UIImage(named : "SoundOff"), forState: .Normal)
        audioPlayer.volume = 0
    }
    
    func soundOn() {
        soundOnOffOutlet.setImage(UIImage(named : "SoundOn"), forState: .Normal)
        audioPlayer.volume = 1
    }
    
    func takeChosenMelody() {
        
        if let chosMelodyNum = defaults.objectForKey(Constants.DefaultKeys.AudioKeyForChosenMelody) as? Int {
            numOfChosenMelody = chosMelodyNum
            audioData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(Constants.arrayOfFileNames[numOfChosenMelody!], ofType: "mp3")!)
        } else {
            // no melody was chosen, put the default audio file
            audioData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(Constants.MelodyFileNames.SimpleSoundFileName, ofType: "mp3")!)
        }
        do {
            audioPlayer = try AVAudioPlayer(data: audioData!)
        } catch let error as NSError {
            print("An error occured , trying to take data from \(audioData) ,\(error.localizedDescription)")
        }
    }
    
}


