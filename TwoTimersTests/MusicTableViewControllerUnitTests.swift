//
//  MusicTableViewControllerUnitTests.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 22.02.17.
//  Copyright © 2017 Polina Petrenko. All rights reserved.
//

import XCTest
@testable import TwoTimers

class MusicTableViewControllerUnitTests: XCTestCase {
    
    var viewController: MusicTableViewController!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewController = storyboard.instantiateViewController(withIdentifier: "MusicTableViewController") as! MusicTableViewController
        UIApplication.shared.keyWindow!.rootViewController = viewController
        
        let _ = viewController.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_IfSelectingFirstRowWillSetSelectedRowVariableTo1() {
        let indexPath = IndexPath(row: 1, section: 1)
        let _ = viewController.tableView(viewController.tableView, willSelectRowAt: indexPath)
        
        XCTAssertEqual(viewController.selectedRow!, 1)
    }
    
    func test_IfSelectingARowTurnsOnTheMusic() {
        let indexPath = IndexPath(row: 1, section: 1)
        let _ = viewController.tableView(viewController.tableView, willSelectRowAt: indexPath)
        
        XCTAssertEqual(viewController.audioPlayer!.isPlaying, true)
    }
  
}
