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
    fileprivate var startDate : Date! // time begins to run on pressing start, and it's value is set in viewDidAppear (first time)
    fileprivate var timeKeeper: Double = 0.0 // time keeps track of the latest time
    fileprivate var timeKeeperForPause: Double = 0.0 // remembers the timekeeper at the moment of pressing pause
    fileprivate var timeOfWaitingOnPause = 0
    fileprivate var timeLeftInTimer = Int() // time, left in timer , in seconds
    fileprivate var audioData: Data!
    fileprivate var audioPlayer = AVAudioPlayer()
    fileprivate var numOfChosenMelody : Int?
    fileprivate let totalTimeText = NSLocalizedString("Total time ", comment: "text before numbers of Total Time label")
    fileprivate struct StringsForAlert {
        struct TimeIsUpAlert {
            static let Title = NSLocalizedString("Time is up!", comment: "Time is up - message")
            static let ActionButton = NSLocalizedString("+1min", comment: "action to add one more minute")
        }
    }
    fileprivate enum MinutesValue {
        case PlusMinute
        case MinusMinute
    }
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var runningTimeLabel: UILabel!
    @IBOutlet weak var startOrPauseButton: UIButton!
    @IBOutlet weak var soundOnOffOButton: UIButton!
    @IBOutlet weak var minusOneMinuteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initialize appDelegate variable
        appDelegate = UIApplication.shared.delegate as! AppDelegate
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
        if app.isIdleTimerDisabled{ app.isIdleTimerDisabled = false }
        
        if let soundVol = defaults.object(forKey: Constants.KeysUsedInCountdownTimer.SoundOnOff) as? Bool {
            soundIsOff = soundVol
            if soundIsOff {
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
                calculateTimeAndSetTimeLabel(runningTimeLabel, timeInSeconds: secondsFromChosenTime + Int(startDate.timeIntervalSinceNow))
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
    
    @IBAction func turnSoundOnOff(_ sender: UIButton) {
        if !soundIsOff {
            soundIsOff = true
            soundOff()
        } else {
            soundIsOff = false
            soundOn()
        }
        defaults.set(soundIsOff, forKey: Constants.KeysUsedInCountdownTimer.SoundOnOff)
    }
    
    @IBAction func minusOneMinute() {
        plusMinusMinute(MinutesValue.MinusMinute)
    }
    
    @IBAction func plusOneMinute() {
        plusMinusMinute(MinutesValue.PlusMinute)
    }
    
    @IBAction func startOrPauseAction(_ sender: UIButton) {
        if !appDelegate.countdownTimerStarted {
            startTimer()
            timerIsOnPause = false
            sender.setImage(UIImage(named: "PauseButton"), for: .normal)
            /*
             Initially observer is added in viewWillAppear
             But when first pause is pressed, this observer is removed
             So in case when Start is pressed and observer was removed, I am adding an observer
             */
            notificationCenter.addObserver(app.delegate!,
                                           selector: #selector(AppDelegate.doLocalNotification),
                                           name: NSNotification.Name.UIApplicationDidEnterBackground,
                                           object: nil)
        } else {
            // press pause
            stopTimer()
            // remember current timeKeeper do make corrective evaluations for running time label later
            timeKeeperForPause = timeKeeper
            timeWithPauseEvaluated = false
            timerIsOnPause = true
            sender.setImage(UIImage(named: "StartButton"), for: .normal)
            // remove local notification
            notificationCenter.removeObserver(app.delegate!)
            app.cancelAllLocalNotifications()
        }
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
    fileprivate func startTimer() {
        // changeTimeLabel() function will be implemented in 0.2 seconds. The code in current function will be already implemented.
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(changeTimeLabel), userInfo: nil, repeats: true)
        appDelegate.countdownTimerStarted = true
    }
    
    fileprivate func stopTimer() {
        if appDelegate.countdownTimerStarted {
            timer.invalidate()
        }
        appDelegate.countdownTimerStarted = false
    }

    fileprivate func plusMinusMinute(_ delta : MinutesValue) {
        switch delta {
        case MinutesValue.PlusMinute:
            self.plusMinute = false
            secondsFromChosenTime += 60
        case MinutesValue.MinusMinute:
            self.plusMinute = true
            secondsFromChosenTime -= 60
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
            self.plusMinusMinute(MinutesValue.PlusMinute)
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
        timeKeeper = startDate.timeIntervalSinceNow
        calculateTimeOfBeingInPauseStateIfPressedStartAfterPause()
        timeLeftInTimer = secondsFromChosenTime + Int(timeKeeper) + (timeOfWaitingOnPause)
        //Set secondsForFireDate in case of going to background. Then local notification will come in time, left in timer.
        appDelegate.secondsForFireDate = Double(timeLeftInTimer)
        stopTimerAndShowAlertIfTimeIsUp()
        disableMinusOneMinuteButtonIfTimeIsLessThan61Seconds()
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
        soundOnOffOButton.setImage(UIImage(named : "SoundOff"), for: .normal)
        audioPlayer.volume = 0
    }
    fileprivate func soundOn() {
        soundOnOffOButton.setImage(UIImage(named : "SoundOn"), for: .normal)
        audioPlayer.volume = 1
    }
    
    fileprivate func takeChosenMelody() {
        var melody = Constants.MelodyFileNames.SimpleSoundFileName
        
        if let chosMelodyNum = defaults.value(forKey: Constants.DefaultKeys.AudioKeyForChosenMelody) as? Int {
            numOfChosenMelody = chosMelodyNum
            melody = Constants.arrayOfFileNames[numOfChosenMelody!]
        }
        do {
            audioData = try Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: melody, ofType: "mp3")!))
        } catch let error as NSError {
            print("An error occured, trying to get data from melody '\(Constants.MelodyFileNames.SimpleSoundFileName)', \(error.localizedDescription)")
        }
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
        } catch let error as NSError {
            print("An error occured, trying to initialise AVAudioPlayer with data \(audioData), \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helper functions for making changeTimeLabel() more readable
    
    fileprivate func calculateTimeOfBeingInPauseStateIfPressedStartAfterPause() {
        if timeKeeperForPause != 0 && !timeWithPauseEvaluated {
            timeOfWaitingOnPause += -Int(timeKeeper) + Int(timeKeeperForPause)
            timeWithPauseEvaluated = true
        }
    }
    
    fileprivate func stopTimerAndShowAlertIfTimeIsUp() {
        if timeLeftInTimer <= 0 {
            // play audio if it wasn't played in background state
            if timeLeftInTimer == 0 {
                audioPlayer.play()
            }
            /*
             timeKeeper is used further if I choose "+1min" action in alert. If the app was in background and I didn't open notification immidiately, (Date() - startDate) will be -(secondsFromChosenTime + Time_of_Waiting_To_Open_the_App), and I change it to be -(secondsFromChosenTime) which is correct. It will set runningTimeLabel to be "00:00:00".
             */
            timeKeeper = -Double(secondsFromChosenTime)
            //the runningTimeLabel must be fixed NOT to show smth like 00:0-10:0-11 (negative time)
            timeLeftInTimer = 0
            stopTimer()
            pushAlert()
        }
    }
    
    fileprivate func disableMinusOneMinuteButtonIfTimeIsLessThan61Seconds() {
        if (timeLeftInTimer < Constants.TimeConstants.SecInMinute + 1) && moreThanOneMinute {
            UIView.animate(withDuration: 0.7,
                           animations: {[unowned self] () in
                            self.minusOneMinuteButton.alpha = 0.5
                }, completion: { _ in self.minusOneMinuteButton.isEnabled = false; self.minusOneMinuteButton.alpha = 1}
            )
            moreThanOneMinute = false
        } else if (timeLeftInTimer > Constants.TimeConstants.SecInMinute + 1) && !moreThanOneMinute {
            minusOneMinuteButton.isEnabled = true
            moreThanOneMinute = true
        }
    }
    
 }


