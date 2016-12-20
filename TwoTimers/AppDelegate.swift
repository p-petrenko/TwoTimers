//
//  AppDelegate.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 24.03.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var countdownTimerStarted = false
    var stopwatchTimerStarted = false
    
    var app = UIApplication.shared
    var localNotification = UILocalNotification()
    
    var defaults = UserDefaults.standard
    
    var secondsForFireDate = Double()
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if defaults.value(forKey: Constants.TimersKeys.FirstRunKey) == nil {
            defaults.setValue(true, forKey: Constants.TimersKeys.FirstRunKey)
            // take data from Defaults (for saved results) of previous version and put it to CoreData for current version
        } else {
            // start with empty saved results
        }
        return true
    }
    
//    func applicationDidEnterBackground(application: UIApplication) {
//    }
//    
//    func applicationWillEnterForeground(application: UIApplication) {
//    }
    
    func doLocalNotification() {
        let arrayOfFileNames = Constants.arrayOfFileNames
        var soundNameForNotification = "\(Constants.MelodyFileNames.SimpleSoundFileName)" + ".mp3"
        
        if countdownTimerStarted {
            // cancel notification if there is any existing
            app.cancelLocalNotification(localNotification)

            // the line where we set the fire date. It is the period of time in which the application will send a notification in background state.
            localNotification.fireDate = Date(timeIntervalSinceNow: secondsForFireDate)
            localNotification.alertBody = "Time is up"
            localNotification.alertAction = NSLocalizedString("Open the timer", comment: "Open the timer")
            
            if let chosenMelodyNum = defaults.value(forKey: Constants.DefaultKeys.AudioKeyForChosenMelody) as? Int {
                soundNameForNotification =  "\(arrayOfFileNames[chosenMelodyNum])" + ".mp3"
            }
            localNotification.soundName =  soundNameForNotification
            if let soundInRunVCIsOff = defaults.object(forKey: Constants.KeysUsedInCountdownTimer.SoundOnOff) as? Bool {
                if soundInRunVCIsOff {
                    localNotification.soundName = "" // must be no sound
                }
            }
            app.scheduleLocalNotification(localNotification)
        }
    }
    
}

