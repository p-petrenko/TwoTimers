//
//  TwoTimersUITests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 17.01.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest

class TwoTimersUITests: XCTestCase {
    
// Comment these tests because each test is slow
    /*
    let app = XCUIApplication()
    let defaults = UserDefaults.standard
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_ToCheckIfTheLaunchOfTheAppOpensCountdownSettingsScreen() {
        let pickerView = app.pickers["TimerPickerView"]
        let startButton = app.buttons["StartTimerInSettingsButton"]
        let chooseMelodyButton = app.buttons["ChooseMelodyButton"]
        let settingsScreenExists = NSPredicate(format: "exists == true")
        expectation(for: settingsScreenExists, evaluatedWith: pickerView, handler: nil)
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("\nERROR! \(error.localizedDescription)\n")
            } else {
                XCTAssert(pickerView.exists)
                XCTAssert(startButton.exists)
                XCTAssert(chooseMelodyButton.exists)
            }
        }
    }
    
    func test_ToCheckIfChoosingStopwatchInTabBarOpensStopwatchScreen() {
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Stopwatch"].tap()

        let startButton = app.buttons["StartTimerInStopwatchButton"]
        let stopButton = app.buttons["StopTimerInStopwatchButton"]
        let sleepButton = app.buttons["SleepModeButton"]
        let runningTimeLabel = app.staticTexts["RunningTimeLabel"]
        let runningSplitTimeLabel = app.staticTexts["RunningSplitTimeLabel"]
        
        XCTAssert(startButton.exists)
        XCTAssert(stopButton.exists)
        XCTAssert(sleepButton.exists)
        XCTAssert(runningTimeLabel.exists)
        XCTAssert(runningSplitTimeLabel.exists)
    }
    */
}
