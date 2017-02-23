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
    
    func testExample() {

    }
    

    
}
