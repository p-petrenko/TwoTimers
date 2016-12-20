//
//  SplitStopwatchResult+CoreDataProperties.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 30.07.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SplitStopwatchResult {

    @NSManaged var current: NSNumber?
    @NSManaged var saved: NSNumber?
    @NSManaged var splitDateAndTimeOfSplit: Date?
    @NSManaged var splitEventName: String?
    @NSManaged var splitTimeLabel: String?
    @NSManaged var timeOfResultSaving: Date?
    @NSManaged var positionOfSavedResult: NSNumber?

}
