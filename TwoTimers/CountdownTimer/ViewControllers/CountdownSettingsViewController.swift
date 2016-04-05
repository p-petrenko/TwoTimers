//
//  CountdownSettingsViewController.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 24.03.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit
import CoreData

class CountdownSettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate , UIPopoverPresentationControllerDelegate {
    
    //    arrays of data in UIPickerView
    var pickerViewHoursArray = [String]()
    var pickerViewMinutesArray = [String]()
    var pickerViewSecondsArray = [String]()
    
    var selectedHours : Int!
    var selectedMinutes : Int!
    var selectedSeconds : Int!
    
    let app = UIApplication.sharedApplication()
    
    var notificationCenter = NSNotificationCenter.defaultCenter()
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    var countdownTimer : CountdownTimer!
    
    @IBOutlet weak var chooseTime: UIPickerView!

    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startButton(sender: UIButton) {
        
        selectedHours = chooseTime.selectedRowInComponent(0)
        selectedMinutes = chooseTime.selectedRowInComponent(1)
        selectedSeconds = chooseTime.selectedRowInComponent(2)
        
        let dictionary : [String : AnyObject] = [
            Constants.KeysUsedInCountdownTimer.SecondsForStart : selectedSeconds,
            Constants.KeysUsedInCountdownTimer.MinutesForStart : selectedMinutes,
            Constants.KeysUsedInCountdownTimer.HoursForStart : selectedHours
        ]
        
        if let cdTimers = fetchCountdownTimer() as [CountdownTimer]! {
            if cdTimers.count == 0 {
                countdownTimer = CountdownTimer(dictionary: dictionary, context: self.sharedContext)
            } else {
    // delete existing countdownTimer and create the new one with new data in the dictionary of parameters
                sharedContext.deleteObject(countdownTimer)
                countdownTimer = CountdownTimer(dictionary: dictionary, context: self.sharedContext)
            }
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    struct LocalConstants {
        static let NumOfHrs = 23
        static let NumOfMinutesOrSeconds = 60
        static let NumOfMinOrSecInComponent = 1200
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for hrs in 0...LocalConstants.NumOfHrs {
            pickerViewHoursArray.append("\(hrs)")
        }
        
    // There will be 1200 minutes/seconds overall , but the value of infiniteMin/infiniteSec will be not bigger than 60
        for minutes in 0..<LocalConstants.NumOfMinOrSecInComponent {
            let infiniteMin = minutes % LocalConstants.NumOfMinutesOrSeconds
            pickerViewMinutesArray.append("\(infiniteMin)")
        }
        
        for seconds in 0..<LocalConstants.NumOfMinOrSecInComponent {
            let infiniteSec = seconds % LocalConstants.NumOfMinutesOrSeconds
            pickerViewSecondsArray.append("\(infiniteSec)")
        }
    
    // Use data from CoreData
        if let cdTimers = fetchCountdownTimer() as [CountdownTimer]! {
            if cdTimers.count != 0 {
                countdownTimer = cdTimers[0]

                selectedSeconds = countdownTimer.selectedSeconds as! Int
                selectedMinutes = countdownTimer.selectedMinutes as! Int
                selectedHours = countdownTimer.selectedHours as! Int
                    
                chooseTime.selectRow(selectedHours, inComponent: 0, animated: false)
                chooseTime.selectRow(selectedMinutes, inComponent: 1, animated: false)
                chooseTime.selectRow(selectedSeconds, inComponent: 2, animated: false)
            } else {
                chooseTime.selectRow(0, inComponent: 0, animated: false)
    // The row will be in the middle of range (1200 / 2) so the user could scroll up and down as he wish.
                chooseTime.selectRow((LocalConstants.NumOfMinOrSecInComponent / 2 + 1), inComponent: 1, animated: false)
                chooseTime.selectRow(LocalConstants.NumOfMinOrSecInComponent / 2, inComponent: 2, animated: false)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if app.idleTimerDisabled == true {
            app.idleTimerDisabled = false
        }
    //        for tab-switches
        notificationCenter.postNotificationName(Constants.CountdownNotificationKeys.TabToCountdown, object: self)
    
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    //    permission for notifications
        let regUserNotifSettings = UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))

        if regUserNotifSettings {
            app.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound, UIUserNotificationType.Alert] , categories: nil)) // | UIUserNotificationType.Badge
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationCenter.postNotificationName(Constants.CountdownNotificationKeys.TabBackToStopwatch, object: self) 
    }
    
    // MARK: - Fetching data
    
    func fetchCountdownTimer() -> [CountdownTimer] {
        let fetchRequest = NSFetchRequest(entityName: "CountdownTimer")
        
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [CountdownTimer]
        } catch {
            print("an error with fetching actors")
            return [CountdownTimer]()
        }
    }

    // MARK: - UIPickerView parameters
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    //  number of rows in each component
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerViewHoursArray.count
        }
        else if component == 1 {
            return pickerViewMinutesArray.count
        }
        else if component == 2 {
            return pickerViewSecondsArray.count
        }
        return 0
    }
    
    //  content of each row in each component
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let blueColor = UIColor(red: 2/255, green: 56/255, blue: 81/255, alpha: 1)
        let attrs = [NSForegroundColorAttributeName : blueColor ] // , NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 60)!
        
        if component == 0 {
            let hStr = NSLocalizedString(" h",  comment: "short from hour or hours nearby number of hours")
            let h = pickerViewHoursArray[row] + hStr
            let attrStr = NSAttributedString(string: h, attributes: attrs)
            return attrStr
        }
        else if component == 1 {
            let minStr = NSLocalizedString(" min", comment: "short from minutes")
            let min = pickerViewMinutesArray[row] + minStr
            let attrStr = NSAttributedString(string: min, attributes: attrs)
            return attrStr
        }
        else if component == 2 {
            let secStr = NSLocalizedString(" sec",comment: "short from seconds")
            let sec = pickerViewSecondsArray[row] + secStr
            let attrStr = NSAttributedString(string: sec, attributes: attrs)
            return attrStr
        }
        
        return NSAttributedString()
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    // If user sets time 00:00:00, then pickerView will automatically reset it to 00:01:00.
        if chooseTime.selectedRowInComponent(0) == 0 && chooseTime.selectedRowInComponent(1) % 60 == 0 && chooseTime.selectedRowInComponent(2) % 60 == 0 {
            chooseTime.selectRow(chooseTime.selectedRowInComponent(1) + 1 , inComponent: 1, animated: true)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            
            if identifier == "Choose Music" {
                if let mtvc = segue.destinationViewController as? MusicTableViewController {
                    if let ppc = mtvc.popoverPresentationController {
                        ppc.delegate = self
                        let minimumSize = mtvc.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                        mtvc.preferredContentSize = CGSize(width: minimumSize.width, height: minimumSize.height) // (width: 320, height: 320)
                    }
                }
            }

            if identifier == "Start Countdown Timer" {
                if let crvc = segue.destinationViewController as? CountdownRunViewController {
                    selectedHours = chooseTime.selectedRowInComponent(0)
                    selectedMinutes = chooseTime.selectedRowInComponent(1) % 60
                    selectedSeconds = chooseTime.selectedRowInComponent(2) % 60
                    
                // pass set time to next ViewController
                    crvc.startHr = selectedHours
                    crvc.startMin = selectedMinutes
                    crvc.startSec = selectedSeconds
                }
            }
        }
        
    }

    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    
    
}
