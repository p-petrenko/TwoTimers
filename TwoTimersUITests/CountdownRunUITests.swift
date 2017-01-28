//
//  CountdownRunUITests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 24.01.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest

class CountdownRunUITests: XCTestCase {
    
    // Comment these tests because each test is slow
    /*
    let app = XCUIApplication()
    var currentSecondsValue: String!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_IfTotalTimeLabelShowsThePresetTime() {
        // SettingsVC
        let hr = 0; let min = 0; let sec = 59
        setTimeAndStartTimer(hours: hr, minutes: min, seconds: sec)
        
        // RunVC
        if let seconds = Int(currentSecondsValue) {
            let runningTimeLabelTitle = app.staticTexts["RunningTimeCountdownLabel"].label
            let totalTimeLabelTitle = app.staticTexts["TotalTimeCountdownLabel"].label
            XCTAssertEqual(runningTimeLabelTitle, "00:00:\(seconds)")
            XCTAssertEqual(totalTimeLabelTitle, "Total time 00:00:59")
        }
        
    }
  
    
    func test_IfInTwoSecondsTimeWillBeOtherThanInitial() {
        // SettingsVC
        let hr = 0; let min = 0; let sec = 59
        setTimeAndStartTimer(hours: hr, minutes: min, seconds: sec)
        
        // RunVC
        let startOrPauseButton = app.buttons["StartOrPauseButton"]
        let runScreenExists = NSPredicate(format: "exists == true")
        expectation(for: runScreenExists, evaluatedWith: startOrPauseButton, handler: nil)
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("\nERROR! \(error.localizedDescription)\n")
            } else {
                // start timer (timer is on pause)
                startOrPauseButton.tap()
                
                if let seconds = Int(self.currentSecondsValue) {
                    let timeLabeLInTwoSeconds = "00:00:\(seconds - 2)"
                    let lessThanOneMinute = NSPredicate(format: "label == '\(timeLabeLInTwoSeconds)'")
                    self.expectation(for: lessThanOneMinute, evaluatedWith: self.app.staticTexts["RunningTimeCountdownLabel"], handler: nil)
                    self.waitForExpectations(timeout: 10) { (error) in
                        if let error = error {
                            print("ERROR! \(error.localizedDescription)")
                            
                        } else {
                            XCTAssert(true)
                        }
                    }
                }
            }
        }
    }
    
    func test_IfMinusOneMinuteButtonDecreasesTimeByOneMinute() {
        // SettingsVC
        let hr = 0; let min = 4; let sec = 59
        setTimeAndStartTimer(hours: hr, minutes: min, seconds: sec)
        
        // RunVC
        let minusOneMinButton = app.buttons["MinusOneMinuteButton"]
        let runScreenExists = NSPredicate(format: "exists == true")
        expectation(for: runScreenExists, evaluatedWith: minusOneMinButton, handler: nil)
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("\nERROR! \(error.localizedDescription)\n")
            } else {
                minusOneMinButton.tap()
                
                if let seconds = Int(self.currentSecondsValue) {
                    let runningTimeLabelTitle = self.app.staticTexts["RunningTimeCountdownLabel"].label
                    let totalTimeLabelTitle = self.app.staticTexts["TotalTimeCountdownLabel"].label
                    XCTAssertEqual(runningTimeLabelTitle, "00:03:\(seconds)")
                    XCTAssertEqual(totalTimeLabelTitle, "Total time 00:03:59")
                }
            }
        }
    }
    
    func test_IfPlusOneMinuteButtonIncreasesTimeByOneMinute() {
        // SettingsVC
        let hr = 0; let min = 4; let sec = 59
        setTimeAndStartTimer(hours: hr, minutes: min, seconds: sec)
        
        // RunVC
        let plusOneMinButton = app.buttons["PlusOneMinuteButton"]
        let runScreenExists = NSPredicate(format: "exists == true")
        expectation(for: runScreenExists, evaluatedWith: plusOneMinButton, handler: nil)
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("\nERROR! \(error.localizedDescription)\n")
            } else {
                plusOneMinButton.tap()
                
                if let seconds = Int(self.currentSecondsValue) {
                    let runningTimeLabelTitle = self.app.staticTexts["RunningTimeCountdownLabel"].label
                    let totalTimeLabelTitle = self.app.staticTexts["TotalTimeCountdownLabel"].label
                    XCTAssertEqual(runningTimeLabelTitle, "00:05:\(seconds)")
                    XCTAssertEqual(totalTimeLabelTitle, "Total time 00:05:59")
                }
            }
        }

        

    }

    func test_IfStopButtonOpensSettingsScreen() {
        // SettingsVC
        let hr = 0; let min = 0; let sec = 59
        setTimeAndStartTimer(hours: hr, minutes: min, seconds: sec)
        
        // RunVC
        let stopButton = app.buttons["StopButton"]
        stopButton.tap()
        
        // SettingsVC
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
    
    
    func test_IfAlertShowsUpWhenTimeIsUp() {
        // SettingsVC
        let hr = 0; let min = 0; let sec = 2
        setTimeAndStartTimer(hours: hr, minutes: min, seconds: sec)
        
        // RunVC
        let startOrPauseButton = app.buttons["StartOrPauseButton"]
        let runScreenExists = NSPredicate(format: "exists == true")
        expectation(for: runScreenExists, evaluatedWith: startOrPauseButton, handler: nil)
        waitForExpectations(timeout: 20) {[unowned self] (error) in
            if let error = error {
                XCTFail("\nERROR! \(error.localizedDescription)\n")
            } else {
                startOrPauseButton.tap()
                let alert = self.app.alerts["Time is up!"]
                let exists = NSPredicate(format: "exists == true")
                self.expectation(for: exists, evaluatedWith: alert, handler: nil)
                self.waitForExpectations(timeout: 10) { (error) in
                    if let error = error {
                        XCTFail("\nERROR! \(error.localizedDescription)\n")
                    } else {
                        XCTAssert(alert.exists)
                    }
                }
            }
        }
    }
 
    // helper functions
    fileprivate func setTimeAndStartTimer(hours: Int, minutes: Int, seconds: Int) {
        // SettingsVC
        let startButton = app.buttons["StartTimerInSettingsButton"]
        
        // check that elements of Settings screen appeared, then proceed
        let settingsScreenExists = NSPredicate(format: "exists == true")
        expectation(for: settingsScreenExists, evaluatedWith: startButton, handler: nil)
        waitForExpectations(timeout: 20) {[unowned self] (error) in
            if let error = error {
                XCTFail("\nERROR! \(error.localizedDescription)\n")
            } else {
                if !self.app.pickerWheels["\(hours) h"].exists {
                    self.app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "\(hours) h")
                }
                if !self.app.pickerWheels["\(minutes) min"].exists {
                    self.app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "\(minutes) min")
                }
                if !self.app.pickerWheels["\(seconds) sec"].exists {
                    self.app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "\(seconds) sec")
                }
                startButton.tap()
                
                // check that elements of RunViewController screen appeared, then proceed
                let startOrPauseButton = self.app.buttons["StartOrPauseButton"]
                let runVCScreenExists = NSPredicate(format: "exists == true")
                self.expectation(for: runVCScreenExists, evaluatedWith: startOrPauseButton, handler: nil)
                self.waitForExpectations(timeout: 20) {[unowned self] (error) in
                    if let error = error {
                        XCTFail("\nERROR! \(error.localizedDescription)\n")
                    } else {
                        startOrPauseButton.tap()
                        
                        /*
                         I can't say definetly at what time pause will be pressed,
                         considering possible delays while testing,
                         that's why I take the label of running time after pressing Pause
                         and get seconds from it (usually it should be 57...59 sec, if a preset time was with 59 sec)
                         */
                        self.currentSecondsValue = self.getSecondsComponentFromRunningTimeLabel()
                    }
                }
            }
        }
    }
    
    fileprivate func getSecondsComponentFromRunningTimeLabel() -> String {
        let runningTimeLabelTitle = app.staticTexts["RunningTimeCountdownLabel"].label
        let componentsOfRunningTimeLabel = runningTimeLabelTitle.components(separatedBy: ":")
        return componentsOfRunningTimeLabel[2]
    }
    */
}
