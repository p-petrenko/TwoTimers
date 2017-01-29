//
//  CountdownSettingsViewControllerUnitTests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 28.01.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest
import UIKit
@testable import TwoTimers

class CountdownSettingsViewControllerUnitTests: XCTestCase {
    
    var viewController : CountdownSettingsViewController!
    var pickerView: UIPickerView!
    
    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "CountdownSettingsViewController") as! CountdownSettingsViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        let _ = viewController.view
        
        pickerView = viewController.chooseTime
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_IfSettingsScreenContainsThreePickerViewComponents() {
        XCTAssertEqual(viewController.numberOfComponents(in: viewController.chooseTime), 3)
    }
    
    func test_IfPickerViewHasCorrectNumberOfRowsInEachComponent() {
        let rowsInComponentOne = pickerView.numberOfRows(inComponent: 0)
        let rowsInComponentTwo = pickerView.numberOfRows(inComponent: 1)
        let rowsInComponentThree = pickerView.numberOfRows(inComponent: 2)
        
        let numOfHoursInComponent = CountdownSettingsViewController.LocalConstants.NumOfHrs + 1
        let numOfMinutesOrSecondsInComponent = CountdownSettingsViewController.LocalConstants.NumOfMinutesOrSecondsInComponent 
        
        XCTAssertEqual(rowsInComponentOne, numOfHoursInComponent)
        XCTAssertEqual(rowsInComponentTwo, numOfMinutesOrSecondsInComponent)
        XCTAssertEqual(rowsInComponentThree, numOfMinutesOrSecondsInComponent)
    }

    func test_IfPickerViewHasCorrectContentOfTheFifthRowInEachComponent() {
        let blueColor = UIColor(red: 2/255, green: 56/255, blue: 81/255, alpha: 1)
        let hoursAttrString = viewController.pickerView(pickerView, attributedTitleForRow: 5, forComponent: 0)!
        let minutesAttrString = viewController.pickerView(pickerView, attributedTitleForRow: 5, forComponent: 1)!
        let secondsAttrString = viewController.pickerView(pickerView, attributedTitleForRow: 5, forComponent: 2)!
        XCTAssertEqual(hoursAttrString, NSAttributedString(string: "5 h", attributes: [NSForegroundColorAttributeName : blueColor]))
        XCTAssertEqual(minutesAttrString, NSAttributedString(string: "5 min", attributes: [NSForegroundColorAttributeName : blueColor]))
        XCTAssertEqual(secondsAttrString, NSAttributedString(string: "5 sec", attributes: [NSForegroundColorAttributeName : blueColor]))
    }
    
    func test_IfZeroTimeAutomaticallyAddsOneSecond() {
        // select 0 minutes and 0 seconds
        pickerView.selectRow(0, inComponent: 1, animated: false)
        pickerView.selectRow(0, inComponent: 2, animated: false)
        
        // select 0 hours, and time should be changed from 00:00:00 to 00:00:01
        viewController.pickerView(pickerView, didSelectRow: 0, inComponent: 0)
        
        XCTAssertEqual(pickerView.selectedRow(inComponent: 2), 1)
    }
    
    func test_IfStartCountdownTimerSegueIndicatesFirstOpeningFromSettingsInDestinationViewController() {
        let destVC = CountdownRunViewController()
        let segue = UIStoryboardSegue(identifier: "Start Countdown Timer", source: viewController, destination: destVC)
        
        viewController.prepare(for: segue, sender: nil)
        
        XCTAssertTrue(destVC.openFirstTime)
    }
    
    func test_IfStartCountdownTimerSegue_PassesCorrentTimeToDestinationViewController() {
        let destVC = CountdownRunViewController()
        let segue = UIStoryboardSegue(identifier: "Start Countdown Timer", source: viewController, destination: destVC)
        
        // set "1:02:03" time
        pickerView.selectRow(1, inComponent: 0, animated: false)
        pickerView.selectRow(2, inComponent: 1, animated: false)
        pickerView.selectRow(3, inComponent: 2, animated: false)
        
        viewController.prepare(for: segue, sender: nil)
        
        XCTAssertEqual(destVC.secondsFromChosenTime, (Constants.TimeConstants.SecInHour * 1 + Constants.TimeConstants.SecInMinute * 2 + 3))
    }
    
}
