//
//  CountdownTimer+CoreDataProperties.swift
//  TwoTimers
//
//  Created by Sergey Petrenko on 24.03.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CountdownTimer {

    @NSManaged var selectedSeconds: NSNumber?
    @NSManaged var selectedMinutes: NSNumber?
    @NSManaged var selectedHours: NSNumber?

}
