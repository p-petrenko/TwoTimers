//
//  TwoTimersUITests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 17.01.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest

class TwoTimersUITests: XCTestCase {
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
        let hr = "1 h"
        let min = "2 min"
        let sec = "3 sec"
        
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: hr)
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: min)
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: sec)
        
        let hourPickerWheel = app.pickerWheels[hr]
        let minPickerWheel = app.pickerWheels[min]
        let secPickerWheel = app.pickerWheels[sec]
        let startButton = app.buttons["StartTimerInSettingsButton"]
        let chooseMelodyButton = app.buttons["ChooseMelodyButton"]
        
        XCTAssert(hourPickerWheel.exists)
        XCTAssert(minPickerWheel.exists)
        XCTAssert(secPickerWheel.exists)
        XCTAssert(startButton.exists)
        XCTAssert(chooseMelodyButton.exists)
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
    
}
