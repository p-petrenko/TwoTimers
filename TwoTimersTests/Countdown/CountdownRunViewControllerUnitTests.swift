//
//  CountdownRunViewControllerUnitTests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 29.01.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest
@testable import TwoTimers

class CountdownRunViewControllerUnitTests: XCTestCase {
    
    var viewController: CountdownRunViewController!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "CountdownRunViewController") as! CountdownRunViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        let _ = viewController.view
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_IfPressingStartTimerSetsNewButtonImage() {
        appDelegate.countdownTimerStarted = false
        let startButton = viewController.startOrPauseButton!
        viewController.startOrPauseAction(startButton)
        XCTAssertEqual(startButton.image(for: .normal), UIImage(named: "PauseButton"))
        XCTAssertEqual(appDelegate.countdownTimerStarted, true)
    }
    
    func test_IfPressingStartTimerSetsCountdownTimerStartedTrue() {
        appDelegate.countdownTimerStarted = false
        let startButton = viewController.startOrPauseButton!
        viewController.startOrPauseAction(startButton)
        XCTAssertEqual(appDelegate.countdownTimerStarted, true)
    }

    func test_IfPressingPauseTimerSetsNewButtonImage() {
        appDelegate.countdownTimerStarted = true
        let pauseButton = viewController.startOrPauseButton!
        viewController.startOrPauseAction(pauseButton)
        XCTAssertEqual(pauseButton.image(for: .normal), UIImage(named: "StartButton"))
    }

    func test_IfPressingPauseTimerSetsCountdownTimerStartedFalse() {
        appDelegate.countdownTimerStarted = true
        let pauseButton = viewController.startOrPauseButton!
        viewController.startOrPauseAction(pauseButton)
        XCTAssertEqual(appDelegate.countdownTimerStarted, false)
    }
    
    func test_IfPressingMinusOneMinuteDecreasesSecondsBy60() {
        viewController.secondsFromChosenTime = 120
        viewController.minusOneMinute()
        
        XCTAssertEqual(viewController.secondsFromChosenTime, 60)
    }

    func test_IfPressingMinusOneMinuteChangesTotalTimeLabelCorrectly() {
        viewController.secondsFromChosenTime = 120
        viewController.minusOneMinute()
        
        let totalTimeLabelText = viewController.totalTimeLabel.text
        XCTAssertEqual(totalTimeLabelText, "Total time 00:01:00")
    }
   
    func test_IfPressingPlusOneMinuteIncreasesSecondsBy60() {
        viewController.secondsFromChosenTime = 60
        viewController.plusOneMinute()
        
        XCTAssertEqual(viewController.secondsFromChosenTime, 120)
    }
    
    func test_IfPressingPlusOneMinuteChangesTotalTimeLabelCorrectly() {
        viewController.secondsFromChosenTime = 60
        viewController.plusOneMinute()
        
        let totalTimeLabelText = viewController.totalTimeLabel.text
        XCTAssertEqual(totalTimeLabelText, "Total time 00:02:00")
    }
    
    func test_IfPressingPlusOneMinuteChangesRunningTimeLabelCorrectly() {
        viewController.secondsFromChosenTime = 60
        viewController.plusOneMinute()
        
        let runningTimeLabelText = viewController.runningTimeLabel.text
        // timeLeftInTimer = secondsFromChosenTime + Int(timeKeeper) + (timeOfWaitingOnPause)
        XCTAssertEqual(runningTimeLabelText, "00:02:00")
    }
    
    func test_IfTimeAfterPauseCalculatesCorrectly() {
        viewController.secondsFromChosenTime = 60
        viewController.changeTimeLabel()
    }

}
