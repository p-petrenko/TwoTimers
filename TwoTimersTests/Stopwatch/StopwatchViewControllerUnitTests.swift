//
//  StopwatchViewControllerUnitTests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 23.02.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest
@testable import TwoTimers

class StopwatchViewControllerUnitTests: XCTestCase {
    
    var viewController: StopwatchViewController!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let app = UIApplication.shared
    var defaults = UserDefaults.standard
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "StopwatchViewController") as! StopwatchViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        let _ = viewController.view
    }
    override func tearDown() {
        super.tearDown()
    }
    
    func test_IfSwitchingSleepModeSetsProperSleepMode() {
        // sleepModeOff - private but false by default
        let stateOfSleepModeBeforeSwitching = app.isIdleTimerDisabled
        viewController.switchSleepMode(viewController.sleepModeButton)
        let defaultsSleepModeValue = defaults.value(forKey: Constants.KeysUsedInStopwatch.SleepMode) as! Bool
        
        XCTAssertEqual(app.isIdleTimerDisabled, !stateOfSleepModeBeforeSwitching)
        XCTAssertEqual(defaultsSleepModeValue, !stateOfSleepModeBeforeSwitching)
    }
    
    func test_IfPressingStartSetsStopwatchTimerStartedToTrue() {
        // start timer
        appDelegate.stopwatchTimerStarted = false
        viewController.startTimer(viewController.startTimerButton)
        
        XCTAssertEqual(appDelegate.stopwatchTimerStarted, true)
    }
    
    func test_IfPressingStartSetsCorrectButtonsImages() {
        // start timer
        appDelegate.stopwatchTimerStarted = false
        viewController.startTimer(viewController.startTimerButton)
        
        XCTAssertEqual(viewController.startTimerButton.image(for: .normal), UIImage(named: "PauseButton"))
        XCTAssertEqual(viewController.splitAndResetButton .image(for: .normal), UIImage(named: "SplitButton"))
    }
    
    func test_IfPressingPauseSetsStopwatchTimerStartedToFalse() {
        // start timer
        appDelegate.stopwatchTimerStarted = false
        viewController.startTimer(viewController.startTimerButton)
        // pause timer
        appDelegate.stopwatchTimerStarted = true
        viewController.startTimer(viewController.startTimerButton)
        
        XCTAssertEqual(appDelegate.stopwatchTimerStarted, false)
    }

    func test_IfPressingPauseSetsCorrectButtonsImages() {
        // start timer
        appDelegate.stopwatchTimerStarted = false
        viewController.startTimer(viewController.startTimerButton)
        // pause timer
        appDelegate.stopwatchTimerStarted = true
        viewController.startTimer(viewController.startTimerButton)
        
        XCTAssertEqual(viewController.startTimerButton.image(for: .normal), UIImage(named: "StartButton"))
        XCTAssertEqual(viewController.splitAndResetButton .image(for: .normal), UIImage(named: "ResetButton"))
    }

}
