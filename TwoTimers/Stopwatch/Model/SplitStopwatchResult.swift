//
//  SplitStopwatchResult.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 25.07.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import Foundation
import CoreData


class SplitStopwatchResult: NSManagedObject {

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "SplitStopwatchResult", in: context)!
        super.init(entity: entity, insertInto: context)
        splitDateAndTimeOfSplit = dictionary[Constants.KeysUsedInStopwatch.SplitDateAndTime] as? Date
        splitEventName = dictionary[Constants.KeysUsedInStopwatch.SplitEventName] as? String
        splitTimeLabel = dictionary[Constants.KeysUsedInStopwatch.SplitIntervalTimeResult] as? String
        saved = dictionary[Constants.KeysUsedInStopwatch.Saved] as! Bool as NSNumber?
        current = dictionary[Constants.KeysUsedInStopwatch.Current] as! Bool as NSNumber?
        timeOfResultSaving = dictionary[Constants.KeysUsedInStopwatch.TimeOfResultSaving] as? Date
        positionOfSavedResult = dictionary[Constants.KeysUsedInStopwatch.PositionOfSavedResult] as? Int as NSNumber?
    }
}
