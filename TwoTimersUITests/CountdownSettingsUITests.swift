//
//  CountdownSettingsUITests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 17.01.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest

class CountdownSettingsUITests: XCTestCase {
    
// Comment these tests because each test is slow
/*
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_IfPlayButtonsOpensRunViewControllerScreen() {
        let startButton = app.buttons["StartTimerInSettingsButton"]
        startButton.tap()
        // elements of RunVC
        let minusOneMinButton = app.buttons["MinusOneMinuteButton"]
        let plusOneMinButton = app.buttons["PlusOneMinuteButton"]
        let soundButton = app.buttons["SoundOnOffButton"]
        let timeLabel = app.staticTexts["RunningTimeCountdownLabel"]
        let totalTimeLabel = app.staticTexts["TotalTimeCountdownLabel"]

        XCTAssert(minusOneMinButton.exists)
        XCTAssert(plusOneMinButton.exists)
        XCTAssert(soundButton.exists)
        XCTAssert(timeLabel.exists)
        XCTAssert(totalTimeLabel.exists)
    }
    
    func test_IfMusicButtonOpensMusicTableViewControllerScreen() {
        let chooseMelodyButton = app.buttons["ChooseMelodyButton"]
        let settingsScreenExists = NSPredicate(format: "exists == true")
        expectation(for: settingsScreenExists, evaluatedWith: chooseMelodyButton, handler: nil)
        waitForExpectations(timeout: 20) { (error) in
            if let error = error {
                XCTFail("\nERROR! \(error.localizedDescription)\n")
            } else {
                chooseMelodyButton.tap()
                
                // elements of MusicTVC
                let musicTitle = self.app.staticTexts["Sounds for Alarm"]
                let melodyNameLabel = self.app.staticTexts["MelodyNameLabel"]
                XCTAssert(musicTitle.exists)
                XCTAssert(melodyNameLabel.exists)
            }
        }
    }
    
    func text_IfDoneButtonClosesMusicTableViewControllerScreen() {
        let chooseMelodyButton = app.buttons["ChooseMelodyButton"]
        let doneButton = app.navigationBars["Sounds for Alarm"].buttons["Done"]
        let pickerView = app.pickers["TimerPickerView"]
        let startButton = app.buttons["StartTimerInSettingsButton"]
        
        chooseMelodyButton.tap()
        doneButton.tap()

        XCTAssert(pickerView.exists)
        XCTAssert(startButton.exists)
        XCTAssert(chooseMelodyButton.exists)
    }
*/
    
}
