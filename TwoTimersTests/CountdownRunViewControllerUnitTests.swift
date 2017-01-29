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
    
    var viewController : CountdownRunViewController!
    
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
    

    func test_() {
//        viewController.
    }
    
}
