//
//  AppDelegate.swift
//  TwoTimers
//
//  Created by Sergey Petrenko on 24.03.16.
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
    
    var activeDate: NSDate?
    
    private struct TimeConstants {
        static let secInHour = 3600
        static let secInMinute = 60
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        activeDate = NSDate()
    }
    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
                soundNameForNotification = "\(arrayOfFileNames[1])" + ".mp3"
            }

            
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

