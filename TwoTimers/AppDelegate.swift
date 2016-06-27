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
    
    var oneTimerStarted = false
    
    var startPressed = false
    
    var app = UIApplication.sharedApplication()
    var localNotification = UILocalNotification()
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var secondsForFireDate = Double()
    var backgroundDate: NSDate?
 
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func timeIntervalForStopwatch() {
        var timeIntervalFromBackgroundToForeground  = Int()
        if startPressed == true {
            if let bgDate = backgroundDate {
                timeIntervalFromBackgroundToForeground = -Int(bgDate.timeIntervalSinceNow)
            }
            defaults.setValue(timeIntervalFromBackgroundToForeground, forKey: Constants.KeysUsedInStopwatch.StopwatchTimeInterval)
        }
    }
     
    func doLocalNotification() {
        let arrayOfFileNames = Constants.arrayOfFileNames
        
        var soundNameForNotification : String?
        
        if oneTimerStarted {
            print("   *** Implement doLocalNotification()  function")
            app.cancelLocalNotification(localNotification)
            
            if let chosMelodyNum = defaults.objectForKey(Constants.DefaultKeys.AudioKeyForChosenMelody) as? Int {
                soundNameForNotification =  "\(arrayOfFileNames[chosMelodyNum])" + ".mp3"
            } else {
                soundNameForNotification = "\(Constants.MelodyFileNames.SimpleSoundFileName)" + ".mp3"
            }

            // the line where we set the fire date. It is the period of time in which the application will send a notification in background state.
            localNotification.fireDate = NSDate(timeIntervalSinceNow: secondsForFireDate)
            localNotification.alertTitle = "Alert Title"
            
            localNotification.alertBody = "Time is up"
            localNotification.alertAction = NSLocalizedString("Open timer", comment: "A word that means : look ,time is up, so open the application")
            if let soundInRunVCisOff = defaults.objectForKey(Constants.KeysUsedInCountdownTimer.SoundOnOff) as? Bool {
                if soundInRunVCisOff == false {
                    localNotification.soundName = soundNameForNotification
                } else {
                    localNotification.soundName = "" // must be no sound
                }
            } else {
                localNotification.soundName =  soundNameForNotification
            }
            app.scheduleLocalNotification(localNotification)
        }
    }
    
}

