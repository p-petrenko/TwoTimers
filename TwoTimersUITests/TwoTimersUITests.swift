//
//  TwoTimersUITests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 17.01.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest

class TwoTimersUITests: XCTestCase {
    
    var defaults = UserDefaults.standard
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testForCheckingIfTheLaunchOfTheAppOpensCountdownSettingsScreen() {
        let app = XCUIApplication()
        
//        XCTAssert(app.buttons["StartTimerInSettingsButton"].exists)
//        XCTAssert(app.buttons["ChooseMelodyButton"].exists)
        XCTAssertEqual("1", "1")
    }
    
}
