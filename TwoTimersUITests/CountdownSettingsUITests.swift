//
//  CountdownSettingsUITests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 17.01.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest

class CountdownSettingsUITests: XCTestCase {
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
        // elements of RunVC
        let minusOneMinButton = app.buttons["MinusOneMinuteButton"]
        let plusOneMinButton = app.buttons["PlusOneMinuteButton"]
        let soundButton = app.buttons["SoundOnOffButton"]
        let timeLabel = app.staticTexts["RunningTimeCountdownLabel"]

        startButton.tap()
        XCTAssert(minusOneMinButton.exists)
        XCTAssert(plusOneMinButton.exists)
        XCTAssert(soundButton.exists)
        XCTAssert(timeLabel.exists)
    }
    
    func test_IfMusicButtonOpensMusicTableViewControllerScreen() {
        let chooseMelodyButton = app.buttons["ChooseMelodyButton"]
        // elements of MusicTVC
        let musicTitle = app.staticTexts["Sounds for Alarm"]
        let melodyNameLabel = app.staticTexts["MelodyNameLabel"]
        
        chooseMelodyButton.tap()
        XCTAssert(musicTitle.exists)
        XCTAssert(melodyNameLabel.exists)
    }
    
//    func test_IfTheChosenMelodyHasACheckMarkImageInACell() {
//        let chooseMelodyButton = app.buttons["ChooseMelodyButton"]
//        // elements of MusicTVC
//        
//        
//        chooseMelodyButton.tap()
//        
////        let fifthCell = app.tableRows.children(matching: .any).element(boundBy: 4)
////        if fifthMelody.exists {
////            fifthMelody.tap()
////        }
//
//        app.tables.staticTexts["fretless bass"].tap()
//        let fifthCell = app.tableRows.children(matching: .any).element(boundBy: 4)
//        let fifthMelody = fifthCell.staticTexts["fretless bass"]
//        XCTAssert(<#T##expression: Bool##Bool#>)
//    }

        
//        app.pickerWheels.element(boundBy: 0).swipeUp()
//        let val = app.pickerWheels.element(boundBy: 0).value as! String

//        let exists = NSPredicate(format: "exists == true")
//        expectation(for: exists, evaluatedWith: startButton, handler: nil)
//        waitForExpectations(timeout: 5, handler: nil)
    
}
