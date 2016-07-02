//
//  SavedResult.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 02.07.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import Foundation

class SavedResult: NSObject {
    
    let resultName: String!
    let timeInterval: String!
    let deviceDateAndTime: NSDate!
    
    init(resultname: String, timeinterval: String, dateAndTime: NSDate) {
        resultName = resultname
        timeInterval = timeinterval
        deviceDateAndTime = dateAndTime
    }
}
