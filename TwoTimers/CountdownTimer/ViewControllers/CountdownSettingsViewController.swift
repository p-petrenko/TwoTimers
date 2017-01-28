//
//  CountdownSettingsViewController.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 24.03.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit
import CoreData

class CountdownSettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerDelegate  {

    fileprivate var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    fileprivate var pickerViewHoursArray = [String]()
    fileprivate var pickerViewMinutesArray = [String]()
    fileprivate var pickerViewSecondsArray = [String]()
    fileprivate var selectedHours : Int!
    fileprivate var selectedMinutes : Int!
    fileprivate var selectedSeconds : Int!
    fileprivate let app = UIApplication.shared
    fileprivate var countdownTimer : CountdownTimer!
    
    struct LocalConstants {
        static let NumOfHrs = 23
        static let NumOfMinutesOrSeconds = 60
        static let NumOfMinutesOrSecondsInComponent = 1200
    }
    
    @IBOutlet weak var chooseTime: UIPickerView!

    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startButton(_ sender: UIButton) {
        selectedHours = chooseTime.selectedRow(inComponent: 0)
        selectedMinutes = chooseTime.selectedRow(inComponent: 1)
        selectedSeconds = chooseTime.selectedRow(inComponent: 2)
        
        let dictionary : [String : AnyObject] = [
            Constants.KeysUsedInCountdownTimer.SecondsForStart : selectedSeconds as AnyObject,
            Constants.KeysUsedInCountdownTimer.MinutesForStart : selectedMinutes as AnyObject,
            Constants.KeysUsedInCountdownTimer.HoursForStart : selectedHours as AnyObject
        ]
        
        if let cdTimers = fetchCountdownTimer() as [CountdownTimer]! {
            if cdTimers.count != 0 {
                // delete existing countdownTimer and create the new one with new data in the dictionary of parameters
                sharedContext.delete(countdownTimer)
            }
            countdownTimer = CountdownTimer(dictionary: dictionary, context: self.sharedContext)
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for hrs in 0...LocalConstants.NumOfHrs {
            pickerViewHoursArray.append("\(hrs)")
        }
        for minutes in 0..<LocalConstants.NumOfMinutesOrSecondsInComponent {
            let infiniteMin = minutes % LocalConstants.NumOfMinutesOrSeconds
            pickerViewMinutesArray.append("\(infiniteMin)")
        }
        for seconds in 0..<LocalConstants.NumOfMinutesOrSecondsInComponent {
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
                /* Minutes and seconds rows will be in the middle of range (1200 / 2) so the user could scroll up and down as he wish,
                   and the initial time will be 00:01:00.
                 */
                chooseTime.selectRow(0, inComponent: 0, animated: false)
                chooseTime.selectRow((LocalConstants.NumOfMinutesOrSecondsInComponent / 2 + 1), inComponent: 1, animated: false)
                chooseTime.selectRow((LocalConstants.NumOfMinutesOrSecondsInComponent / 2), inComponent: 2, animated: false)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //    ask the user for a permission for notifications
        let regUserNotifSettings = UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))
        if regUserNotifSettings {
            app.registerUserNotificationSettings(UIUserNotificationSettings(types: [UIUserNotificationType.sound, UIUserNotificationType.alert] , categories: nil))
        }
    }
    
    // MARK: - UIPickerView parameters
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    //  number of rows in each component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let blueColor = UIColor(red: 2/255, green: 56/255, blue: 81/255, alpha: 1)
        let attrs = [NSForegroundColorAttributeName : blueColor ]
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
    
    // If user sets time 00:00:00, then pickerView will automatically reset it to 00:00:01
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if chooseTime.selectedRow(inComponent: 0) == 0 && chooseTime.selectedRow(inComponent: 1) % 60 == 0 && chooseTime.selectedRow(inComponent: 2) % 60 == 0 {
            chooseTime.selectRow(chooseTime.selectedRow(inComponent: 2) + 1 , inComponent: 2, animated: true)
        }
    }

    // MARK: - Fetching data
    
    fileprivate func fetchCountdownTimer() -> [CountdownTimer] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CountdownTimer")
        
        do {
            return try sharedContext.fetch(fetchRequest) as! [CountdownTimer]
        } catch {
            print("an error with fetching actors")
            return [CountdownTimer]()
        }
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            
            if identifier == "Choose Music" {
                if let mtvc = segue.destination as? MusicTableViewController {
                    if let ppc = mtvc.popoverPresentationController {
                        ppc.delegate = self
                        let minimumSize = mtvc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                        mtvc.preferredContentSize = CGSize(width: minimumSize.width, height: minimumSize.height) //is (width: 320, height: 320)
                    }
                }
            }
            if identifier == "Start Countdown Timer" {
                if let crvc = segue.destination as? CountdownRunViewController {
                    selectedHours = chooseTime.selectedRow(inComponent: 0)
                    selectedMinutes = chooseTime.selectedRow(inComponent: 1) % 60
                    selectedSeconds = chooseTime.selectedRow(inComponent: 2) % 60
                    
                    // pass the preset time to next ViewController
                    crvc.startHr = selectedHours
                    crvc.startMin = selectedMinutes
                    crvc.startSec = selectedSeconds
                    crvc.openFirstTime = true
                }
            }
        }
    }
    
}
