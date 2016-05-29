//
//  StopwatchResults.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 29.05.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import Foundation
import CoreData


class StopwatchResults: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("StopwatchResults", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        splitEventName = dictionary[Constants.KeysUsedInStopwatch.SplitEventName] as? String
        dateAndTimeOfSplit = dictionary[Constants.KeysUsedInStopwatch.DateAndTime] as? NSDate
        splitTimeLabel = dictionary[Constants.KeysUsedInStopwatch.IntervalTimeResult] as? String
        current = dictionary[Constants.KeysUsedInStopwatch.Current] as! Bool
        saved = dictionary[Constants.KeysUsedInStopwatch.Saved] as! Bool
    }
}
