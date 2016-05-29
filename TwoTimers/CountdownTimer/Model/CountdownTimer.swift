//
//  CountdownTimer.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 24.03.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import Foundation
import CoreData


class CountdownTimer: NSManagedObject {
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("CountdownTimer", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        selectedSeconds = dictionary[Constants.KeysUsedInCountdownTimer.SecondsForStart] as! Int
        selectedMinutes = dictionary[Constants.KeysUsedInCountdownTimer.MinutesForStart] as! Int
        selectedHours = dictionary[Constants.KeysUsedInCountdownTimer.HoursForStart] as! Int
    }
}
