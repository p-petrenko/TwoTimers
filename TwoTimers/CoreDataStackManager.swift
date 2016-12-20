    //
//  CoreDataStackManager.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 25.03.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import Foundation
import CoreData


private let SQLITE_FILE_NAME = "TwoTimers.sqlite"

class CoreDataStackManager {
    
    
    // MARK: - Shared Instance
    
    /**
    *  This class variable provides an easy way to get access
    *  to a shared instance of the CoreDataStackManager class.
    */
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        return Static.instance
    }
    
    // MARK: - The Core Data stack. The code has been moved, unaltered, from the AppDelegate.
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "TwoTimers", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent(SQLITE_FILE_NAME)

        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // abort() causes the application to generate a crash log and terminate. Comment this function in a shipping application, it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
//            abort()
        }
        return coordinator
    }()
    
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
//                abort()
            }
        }
    }
    
    // MARK: - Fetch Split Results
    
    func fetchCurrentSplitResult() -> [SplitStopwatchResult] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SplitStopwatchResult")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "splitDateAndTimeOfSplit", ascending: true)]

        fetchRequest.predicate = NSPredicate(format: "current == true")
        do {
            return try managedObjectContext.fetch(fetchRequest) as! [SplitStopwatchResult]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return [SplitStopwatchResult]()
        }
    }
    
    // MARK: - Fetch Saved Results
    
    func fetchSavedSplitResult() -> [SplitStopwatchResult] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SplitStopwatchResult")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "positionOfSavedResult", ascending: true), NSSortDescriptor(key: "timeOfResultSaving", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "saved == true")
        
        do {
            return try managedObjectContext.fetch(fetchRequest) as! [SplitStopwatchResult]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return [SplitStopwatchResult]()
        }
    }
    
    // MARK: - Save Core Data Context with new elements in it
    
    func saveSplitResult(_ eventName: String, timeLabel: String, date: Date, saved: Bool, current: Bool, timeOfResultSaving: Date, positionOfSavedResult: Int) {
        let dictionary : [String : AnyObject] = [
            Constants.KeysUsedInStopwatch.SplitEventName : eventName as AnyObject,
            Constants.KeysUsedInStopwatch.SplitIntervalTimeResult : timeLabel as AnyObject,
            Constants.KeysUsedInStopwatch.SplitDateAndTime : date as AnyObject,
            Constants.KeysUsedInStopwatch.Saved : saved as AnyObject,
            Constants.KeysUsedInStopwatch.Current: current as AnyObject,
            Constants.KeysUsedInStopwatch.TimeOfResultSaving: timeOfResultSaving as AnyObject,
            Constants.KeysUsedInStopwatch.PositionOfSavedResult: positionOfSavedResult as AnyObject
        ]
        let _ = SplitStopwatchResult(dictionary: dictionary, context: managedObjectContext)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    
}
