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
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "CountdownTimer", in: context)!
        super.init(entity: entity, insertInto: context)
        selectedSeconds = dictionary[Constants.KeysUsedInCountdownTimer.SecondsForStart] as! Int as NSNumber?
        selectedMinutes = dictionary[Constants.KeysUsedInCountdownTimer.MinutesForStart] as! Int as NSNumber?
        selectedHours = dictionary[Constants.KeysUsedInCountdownTimer.HoursForStart] as! Int as NSNumber?
    }
    
    
}
