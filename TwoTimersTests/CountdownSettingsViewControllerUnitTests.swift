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
    
    override func setUp() {
        super.setUp()

        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "CountdownSettingsViewController") as! CountdownSettingsViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        let _ = viewController.view
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_IfSettingsScreenContainsThreePickerViewComponents() {
        XCTAssertEqual(viewController.numberOfComponents(in: viewController.chooseTime), 3)
    }
    
    func test_IfPickerViewHasACorrectNumberOfRowsInEachComponent() {
        let rowsInComponentOne = viewController.chooseTime.numberOfRows(inComponent: 0)
        let rowsInComponentTwo = viewController.chooseTime.numberOfRows(inComponent: 1)
        let rowsInComponentThree = viewController.chooseTime.numberOfRows(inComponent: 2)
        
        let numOfHoursInComponent = CountdownSettingsViewController.LocalConstants.NumOfHrs + 1
        let numOfMinutesOrSecondsInComponent = CountdownSettingsViewController.LocalConstants.NumOfMinutesOrSecondsInComponent 
        
        XCTAssertEqual(rowsInComponentOne, numOfHoursInComponent)
        XCTAssertEqual(rowsInComponentTwo, numOfMinutesOrSecondsInComponent)
        XCTAssertEqual(rowsInComponentThree, numOfMinutesOrSecondsInComponent)
    }

}
