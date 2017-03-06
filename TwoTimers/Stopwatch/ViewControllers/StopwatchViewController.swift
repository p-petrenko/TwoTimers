//
//  StopwatchViewController.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 05.04.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit
import CoreData

class StopwatchViewController: UIViewController {
    fileprivate let app = UIApplication.shared
    fileprivate let appDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var notificationCenter = NotificationCenter.default
    fileprivate var defaults = UserDefaults.standard
    fileprivate var coreDataStackManager = CoreDataStackManager.sharedInstance()
    fileprivate var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    fileprivate var timer: Timer!
    var startDate: Date! // time, which was at the moment of pressing the start button
    var splitStartDate: Date!
    fileprivate var secondsFromNSDate: Double! // NSDate interval from now to the moment of start
    fileprivate var secondsFromSplitNSDate: Double! // NSDate interval from now to themoment of last split start
    fileprivate var timeKeeper = 0.0  // time in seconds, which was last time at the moment of pressing Pause
    fileprivate var splitTimeKeeper = 0.0 // the same as timeKeeper, but on each split it resets to 0
    fileprivate var splitNumber = 0
    fileprivate var timerIsOnPause = true
    fileprivate var timeWithPauseEvaluated = false
    fileprivate var sleepModeOff = false
    fileprivate var splitStopwatchResults = [SplitStopwatchResult]()
    fileprivate var savedStopwatchResults = [SplitStopwatchResult]()
    
    @IBOutlet weak var runningTimeLabel: UILabel!
    @IBOutlet weak var splitLabel: UILabel!
    @IBOutlet weak var startTimerButton: UIButton! // start/pause button outlet
    @IBOutlet weak var splitAndResetButton: UIButton! // split/reset button outlet
    @IBOutlet weak var sleepModeButton: UIButton!
    @IBOutlet weak var showAllResultsButton: UIButton!
    @IBOutlet weak var folderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let timkeeper = defaults.value(forKey: Constants.KeysUsedInStopwatch.TimeKeeperKey) as? Double {
            timeKeeper = timkeeper
        }
        if let splittimekeeper = defaults.value(forKey: Constants.KeysUsedInStopwatch.SplitTimeKeeperKey) as? Double {
            splitTimeKeeper = splittimekeeper
        }
        presetTimeLabels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        savedStopwatchResults = coreDataStackManager.fetchSavedSplitResult()
        
        notificationCenter.addObserver(self,
                                       selector: #selector(setDefaults),
                                       name: NSNotification.Name.UIApplicationDidEnterBackground,
                                       object: nil)

        // fetch results from CoreData
        splitStopwatchResults = coreDataStackManager.fetchCurrentSplitResult()
        splitNumber = splitStopwatchResults.count
        if let lastResult = splitStopwatchResults.last {
            showAllResultsButton.setTitle("#\(splitNumber) " + lastResult.splitTimeLabel!, for: .normal)
        } else {
            showAllResultsButton.setTitle(" ", for: .normal)
        }

        if let sleepMode = defaults.object(forKey: Constants.KeysUsedInStopwatch.SleepMode) as? Bool {
            sleepModeOff = sleepMode
            setSleepModeState(sleepModeOff)
        } else {
            // the screen can sleep by default
            setSleepModeState(false)
        }

        // if there is at least one element in saved results, show folder button
        folderButton.isHidden = savedStopwatchResults.isEmpty
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !timerIsOnPause {
            automaticPressStart()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationCenter.removeObserver(self)
        app.cancelAllLocalNotifications()
        pauseTimer()
    }
    
    @IBAction func switchSleepMode(_ sender: UIButton) {
        //switch off the sleeping possibility of the screen if it is on and vice versa
        setSleepModeState(!sleepModeOff)
        defaults.set(sleepModeOff, forKey: Constants.KeysUsedInStopwatch.SleepMode)
    }
    
    @IBAction func startTimer(_ sender: UIButton) {
        if !appDelegate.stopwatchTimerStarted {
            // the user pressed Start
            automaticPressStart()
            changeButtonsToPauseAndSplit()
            startDate = Date()
            splitStartDate = Date()
        } else {
            // the user pressed Pause
            pauseTimer()
            changeButtonsToStartAndReset()
            timeKeeper = secondsFromNSDate
            splitTimeKeeper = secondsFromSplitNSDate
            timerIsOnPause = true
        }
    }
    
    @IBAction func resetOrMakeSplit(_ sender: UIButton) {
        if !appDelegate.stopwatchTimerStarted {
            // the user pressed Reset
            showAllResultsButton.setTitle("", for: .normal)
            startDate = Date(); splitStartDate = Date()
            timeKeeper = 0 ; splitTimeKeeper = 0 ; splitNumber = 0
            removeSplitResultsFromCoreData()
            timerBeep()
        } else {
            // the user pressed Split
            splitStartDate = Date()
            splitTimeKeeper = 0
            splitNumber += 1
            let splitTimeResult = "\(splitLabel.text!)"
            //timeOfResultSaving and positionOfSavedResult are not used for split results table view, but it must have some value, which will never be used
            coreDataStackManager.saveSplitResult("",
                                                 timeLabel: splitTimeResult,
                                                 date: Date(),
                                                 saved: false,
                                                 current: true,
                                                 timeOfResultSaving: Date(),
                                                 positionOfSavedResult: 0
            )
            showAllResultsButton.setTitle("#\(splitNumber) " + splitTimeResult, for: .normal)
        }
    }
    
    fileprivate func automaticPressStart() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerBeep), userInfo: nil, repeats: true)
        appDelegate.stopwatchTimerStarted = true
        timerIsOnPause = false
    }
    
    func pauseTimer() {
        if appDelegate.stopwatchTimerStarted {
            appDelegate.stopwatchTimerStarted = false
            timeWithPauseEvaluated = false
            timer.invalidate()
            setDefaults()
        }
    }

    fileprivate func changeButtonsToStartAndReset() {
        startTimerButton.setImage(UIImage(named: "StartButton"), for: .normal)
        splitAndResetButton.setImage(UIImage(named: "ResetButton"), for: .normal)
    }
    
    fileprivate func changeButtonsToPauseAndSplit() {
        startTimerButton.setImage(UIImage(named: "PauseButton"), for: .normal)
        splitAndResetButton.setImage(UIImage(named: "SplitButton"), for: .normal)
    }
    
    func timerBeep() {
        /*
            On the first Start:
         secondsFromNSDate = 0 - (-0.1 sec) = 0.1 sec
         secondsFromSplitNSDate = 0 - (-0.1 sec) = 0.1 sec
         
            On Start after Pause:
         secondsFromNSDate = 0.1 - (-0.1 sec) = 0.2 sec
         secondsFromSplitNSDate = 0.1 - (-0.1 sec) = 0.2 sec
         
            On Split after Start(time was running for 5 seconds):
         secondsFromNSDate = 0 - (-5.1 sec) = 5.1 sec
         secondsFromSplitNSDate = 0 - (-0.1 sec) = 0.1 sec
         */
        secondsFromNSDate = timeKeeper - (startDate.timeIntervalSinceNow)
        secondsFromSplitNSDate = splitTimeKeeper - (splitStartDate.timeIntervalSinceNow)
        runningTimeLabel.text = getTimeLabelFromTimeNumbers(secondsFromNSDate)
        splitLabel.text = getTimeLabelFromTimeNumbers(secondsFromSplitNSDate)
    }
    
    fileprivate func getTimeLabelFromTimeNumbers(_ secFromNSDate : Double ) -> String {
        let min = ((secFromNSDate) / Double(Constants.TimeConstants.SecInMinute))  //I have no hours, so I can make more than 60 minutes // % Int(TimeConstants.SecInMinute)
        let sec = (secFromNSDate).truncatingRemainder(dividingBy: Double(Constants.TimeConstants.SecInMinute))
        let cs = (((secFromNSDate)) * 10).truncatingRemainder(dividingBy: 10)
        return timeToString(Int(min)) + ":" + timeToString(Int(sec)) + "." + "\(Int(cs))"
    }
    
    fileprivate func timeToString(_ selectedTime : Int) -> String {
        if selectedTime < 10 {
            return "0\(selectedTime)"
        } else {
            return "\(selectedTime)"
        }
    }
    
    func setDefaults() {
        defaults.setValue(secondsFromNSDate , forKey: Constants.KeysUsedInStopwatch.TimeKeeperKey)
        defaults.setValue(secondsFromSplitNSDate, forKey: Constants.KeysUsedInStopwatch.SplitTimeKeeperKey)
    }
    
    fileprivate func setSleepModeState(_ state: Bool) {
        app.isIdleTimerDisabled = state
        sleepModeOff = state
        let imageOfSleepModeButton = sleepModeOff ? UIImage(named: "SleepModeOff") : UIImage(named: "SleepModeOn")
        sleepModeButton.setImage(imageOfSleepModeButton, for: .normal)
    }
 
    fileprivate func presetTimeLabels() {
        secondsFromNSDate = timeKeeper - (Date().timeIntervalSinceNow)
        secondsFromSplitNSDate = splitTimeKeeper - (Date().timeIntervalSinceNow)
        runningTimeLabel.text = getTimeLabelFromTimeNumbers(secondsFromNSDate)
        splitLabel.text = getTimeLabelFromTimeNumbers(secondsFromSplitNSDate)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Split Results Segue" && splitNumber != 0 {
            return true
        }
        else if identifier == "Folder in StopwatchVC Segue" && !savedStopwatchResults.isEmpty {
            // if there is a value in core data and if the array of time intervals is not empty, return true
            return true
        }
        return false
    }

    
    fileprivate func removeSplitResultsFromCoreData() {
        for (index,_) in splitStopwatchResults.enumerated() {
            if let savedSplitStopwatchResult = splitStopwatchResults[index].saved as? Bool {
                if !savedSplitStopwatchResult {
                    sharedContext.delete(splitStopwatchResults[index])
                } else {
                    splitStopwatchResults[index].current = false
                }
            }
        }
        coreDataStackManager.saveContext()
    }
    
    
}
