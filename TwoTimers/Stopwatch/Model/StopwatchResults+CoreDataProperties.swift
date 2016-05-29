//
//  StopwatchResults+CoreDataProperties.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 29.05.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension StopwatchResults {

    @NSManaged var splitEventName: String?
    @NSManaged var dateAndTimeOfSplit: NSDate?
    @NSManaged var splitTimeLabel: String?
    @NSManaged var saved: NSNumber?
    @NSManaged var current: NSNumber?

}
