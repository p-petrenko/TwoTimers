//
//  TimersTabBarController.swift
//  TwoTimers
//
//  Created by Sergey Petrenko on 24.03.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit

class TimersTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.tintColor = UIColor(red: 6/255, green: 167/255, blue: 244/255, alpha: 1)
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
    //    if user selects already chosen tab
        if tabBarController.selectedViewController == viewController {
            return false
        }
        return true
    }
}
