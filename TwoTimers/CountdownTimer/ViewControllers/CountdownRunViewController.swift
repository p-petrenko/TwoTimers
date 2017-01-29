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

    fileprivate let app = UIApplication.shared
    fileprivate var appDelegate: AppDelegate!
    fileprivate let notificationCenter = NotificationCenter.default
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate var timer = Timer()
    fileprivate var plusMinute = false
    fileprivate var soundIsOff = false
    fileprivate var timerIsOnPause = false
    var openFirstTime = false
    fileprivate var timeWithPauseEvaluated = false
    fileprivate var moreThanOneMinute = true
    var secondsFromChosenTime = 0 // time, chosen by user in PickerView, converted to seconds
    fileprivate var startDate : Date? // time begins to run on pressing start, and it's value is set in viewDidAppear (first time)
    fileprivate var timeKeeper : Double = 0.0 // time keeps track of latest time
    fileprivate var timeKeeperForPause : Double = 0.0 // remembers the timekeeper at the moment of pressing pause
    fileprivate var timeOfWaitingOnPause = 0
    fileprivate var timeLeftInTimer = Int() // time, left in timer , in seconds
    fileprivate var audioData = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: Constants.MelodyFileNames.SimpleSoundFileName, ofType: "mp3")!))
    fileprivate var audioPlayer = AVAudioPlayer()
    fileprivate var numOfChosenMelody : Int?
    fileprivate let totalTimeText = NSLocalizedString("Total time ", comment: "text before numbers of Total Time label")
    fileprivate struct StringsForAlert {
        struct TimeIsUpAlert {
            static let Title = NSLocalizedString("Time is up!", comment: "Time is up - message")
            static let ActionButton = NSLocalizedString("+1min", comment: "action to add one more minute")
        }
    }
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var runningTimeLabel: UILabel!
    @IBOutlet weak var startOrPauseButton: UIButton!
    @IBOutlet weak var soundOnOffOButton: UIButton!
    @IBOutlet weak var minusOneMinuteButton: UIButton!
    
    
    @IBAction func turnSoundOnOff(_ sender: UIButton) {
        if soundIsOff == false {
            soundIsOff = true
            soundOff()
        } else {
            soundIsOff = false
            soundOn()
        }
        defaults.set(soundIsOff, forKey: Constants.KeysUsedInCountdownTimer.SoundOnOff)
    }
    
    @IBAction func minusOneMinute(_ sender: UIButton) {
        plusMinusMinute(-1)
    }

    @IBAction func plusOneMinute(_ sender: UIButton) {
        plusMinusMinute(1)
    }

    @IBAction func startOrPauseAction(_ sender: UIButton) {
        startOrPauseTimer(sender)
    }

    @IBAction func stopButton(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialize appDelegate variable
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        // convert start time from hr, min, sec into seconds.Must be done to count number of hr, min, sec in changeTimeLabel()
//        secondsFromChosenTime = Constants.TimeConstants.SecInHour * startHr + Constants.TimeConstants.SecInMinute * startMin + startSec
        takeChosenMelody()
        startDate = Date()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.addObserver(app.delegate!,
                                       selector: #selector(AppDelegate.doLocalNotification),
                                       name: NSNotification.Name.UIApplicationDidEnterBackground,
                                       object: nil)
        // if it was set to true in stopwatch, then set it to false here, as in countdown it should be able to sleep.
        if app.isIdleTimerDisabled { app.isIdleTimerDisabled = false }
        
        if let soundVol = defaults.object(forKey: Constants.KeysUsedInCountdownTimer.SoundOnOff) as? Bool {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        calculateTimeAndSetTimeLabel(totalTimeLabel, timeInSeconds: secondsFromChosenTime)
        calculateTimeAndSetTimeLabel(runningTimeLabel, timeInSeconds: secondsFromChosenTime)


        if openFirstTime {
            totalTimeLabel.alpha = 0
            runningTimeLabel.alpha = 0
            UIView.animate(withDuration: 0.4,
                                       animations: {[unowned self] () in
                                        self.totalTimeLabel.alpha = 1
                                        self.runningTimeLabel.alpha = 1
                                        
                }, completion: nil
            )

            startTimer()
            openFirstTime = false
        } else {
            // if timer is not on pause, start timer considering NSDate changes
            if !timerIsOnPause {
                calculateTimeAndSetTimeLabel(runningTimeLabel, timeInSeconds: secondsFromChosenTime + Int(startDate!.timeIntervalSinceNow))
                startTimer()
            }
            // or if timer is on pause, do nothing
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.removeObserver(app.delegate!)
        app.cancelAllLocalNotifications()
        // need to stop NSTimer always when pop the screen, but that's why need to write smart code in viewDidAppear
        stopTimer()
    }
    
    fileprivate func startOrPauseTimer(_ nameOfButton : UIButton) {
        if !appDelegate.countdownTimerStarted {
            startTimer()
            timerIsOnPause = false
            nameOfButton.setImage(UIImage(named: "PauseButton"), for: UIControlState())
        } else {
            // press pause
            stopTimer()
            // remember current timeKeeper do make corrective evaluations for running time label later
            timeKeeperForPause = timeKeeper
            timeWithPauseEvaluated = false
            timerIsOnPause = true
            nameOfButton.setImage(UIImage(named: "StartButton"), for: UIControlState())
            // remove local notification
            notificationCenter.removeObserver(app.delegate!)
            app.cancelAllLocalNotifications()
        }
    }
    
    fileprivate func startTimer() {
        // changeTimeLabel() function will implement itself in 0.2 seconds. The code in current function will be already implemented.
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(changeTimeLabel), userInfo: nil, repeats: true)
        appDelegate.countdownTimerStarted = true

    }
    
    fileprivate func stopTimer() {
        if appDelegate.countdownTimerStarted {
            timer.invalidate()
        }
        appDelegate.countdownTimerStarted = false
    }

    fileprivate func plusMinusMinute(_ delta : Int) {
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
        calculateTimeAndSetTimeLabel(totalTimeLabel, timeInSeconds: secondsFromChosenTime)
        changeTimeLabel()
    }
    
    fileprivate func timeToString(_ selectedTime : Int) -> String {
        if selectedTime < 10 {
            return "0\(selectedTime)"
        } else {
            return "\(selectedTime)"
        }
    }
    
    fileprivate func pushAlert() {
        let alert = UIAlertController (title: StringsForAlert.TimeIsUpAlert.Title,
                                       message: "",
                                       preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: StringsForAlert.TimeIsUpAlert.ActionButton , style: UIAlertActionStyle.default) {
            [unowned self] (action: UIAlertAction) -> Void in
            // Action: add +1 minute
            // update startDate, because I need to add 1 minute to 0 , and not to -(time,waiting for pressing button in alert)
            self.audioPlayer.stop() // stops playing sound after button is pressed
            // First recalculate startDate in startTimer(), only then can add 1 minute to refreshed startDate.
            self.startTimer()
            self.plusMinusMinute(1)
        })
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            [unowned self] (action: UIAlertAction) -> Void in
            // Action: Stop timer and return to timer settings
            self.navigationController!.popViewController(animated: true)
            self.audioPlayer.stop()
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Changing time labels
    
    func changeTimeLabel() {
        
        timeKeeper = startDate!.timeIntervalSinceNow
        
        if timeKeeperForPause != 0 && !timeWithPauseEvaluated {
            timeOfWaitingOnPause += -Int(timeKeeper) + Int(timeKeeperForPause)
            timeWithPauseEvaluated = true
        }
        // count this value considering all the pauses if there were any
        timeLeftInTimer = secondsFromChosenTime + Int(timeKeeper) + (timeOfWaitingOnPause)

        // Set this value here for case of going to the background. So the local notification will come in time, left in timer.
        appDelegate.secondsForFireDate = Double(timeLeftInTimer)
        
        if timeLeftInTimer <= 0 {
            // play audio if it wasn't played in background state
            if timeLeftInTimer == 0 {
                audioPlayer.play()
            }
            /*
            timeKeeper is used further if I choose "+1min" action in alert. If an app was in background and I didn't open notification immidiately, (NSDate() - startDate) will be -(secondsFromChosenTime + Time_of_Waiting_To_Open_the_App), and I change it to be -(secondsFromChosenTime) which is correct.
            */
            timeKeeper = -Double(secondsFromChosenTime)
            //the running time label must be fixed NOT to show smth like 00:0-10:0-11 (negative time)
            timeLeftInTimer = 0
            stopTimer()
            pushAlert()
        }
        
        // if time < 61 sec , lock pressing "-1m" button
        if timeLeftInTimer < (Constants.TimeConstants.SecInMinute + 1) && moreThanOneMinute {
            UIView.animate(withDuration: 0.7,
                                       animations: {[unowned self] () in
                                        self.minusOneMinuteButton.alpha = 0.5
                }, completion: { _ in self.minusOneMinuteButton.isEnabled = false; self.minusOneMinuteButton.alpha = 1}
            )
            moreThanOneMinute = false
        } else if timeLeftInTimer > (Constants.TimeConstants.SecInMinute + 1) && !moreThanOneMinute {
            minusOneMinuteButton.isEnabled = true
            moreThanOneMinute = true
        }
        
        calculateTimeAndSetTimeLabel(runningTimeLabel, timeInSeconds: timeLeftInTimer)
    }
    
    // as timeInSeconds variable it must be secondsFromChosenTime (for totalTimeEvaluate) or timeLeftInTimer (for changeTimeLabel)
    fileprivate func calculateTimeAndSetTimeLabel(_ timeLabel : UILabel , timeInSeconds : Int) {
        
        let hours = timeInSeconds / Constants.TimeConstants.SecInHour
        let minutes = (timeInSeconds - (hours * Constants.TimeConstants.SecInHour)) / Constants.TimeConstants.SecInMinute % Constants.TimeConstants.SecInMinute
        let seconds = (timeInSeconds - (hours * Constants.TimeConstants.SecInHour)) % Constants.TimeConstants.SecInMinute
        
        // add NSLocalizedString , so the start of text for total time label will be availible for 2 languages
        if timeLabel == totalTimeLabel {
            timeLabel.text = totalTimeText
        } else {
            timeLabel.text = ""
        }
        timeLabel.text = timeLabel.text! + timeToString(hours) + ":" + timeToString(minutes) + ":" + timeToString(seconds)
    }
    
    // MARK: - Audio functions
    
    fileprivate func soundOff() {
        soundOnOffOButton.setImage(UIImage(named : "SoundOff"), for: UIControlState())
        audioPlayer.volume = 0
    }
    fileprivate func soundOn() {
        soundOnOffOButton.setImage(UIImage(named : "SoundOn"), for: UIControlState())
        audioPlayer.volume = 1
    }
    
    fileprivate func takeChosenMelody() {
        if let chosMelodyNum = defaults.value(forKey: Constants.DefaultKeys.AudioKeyForChosenMelody) as? Int {
            numOfChosenMelody = chosMelodyNum
            audioData = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: Constants.arrayOfFileNames[numOfChosenMelody!], ofType: "mp3")!))
        }
        do {
            audioPlayer = try AVAudioPlayer(data: audioData!)
        } catch let error as NSError {
            print("An error occured , trying to take data from \(audioData) ,\(error.localizedDescription)")
        }
    }

 }


