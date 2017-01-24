//
//  CountdownRunUITests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 24.01.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest

class CountdownRunUITests: XCTestCase {
    let app = XCUIApplication()
    
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
        let startButton = app.buttons["StartTimerInSettingsButton"]
        app.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "0 h")
        app.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "1 min")
        app.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "0 sec")
        
        startButton.tap()
        
        // RunVC
        let totalTimeLabelTitle = app.staticTexts["RunningTimeCountdownLabel"].label
        XCTAssertEqual(totalTimeLabelTitle, "00:01:00")
    }
    
}
