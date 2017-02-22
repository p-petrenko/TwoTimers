//
//  SavedResultsTableTableViewController.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 27.06.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit
import CoreData

class SavedResultsTableTableViewController: UITableViewController {

    fileprivate var savedStopwatchResults = [SplitStopwatchResult]()
    fileprivate var coreDataStackManager = CoreDataStackManager.sharedInstance()
    fileprivate var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savedStopwatchResults = coreDataStackManager.fetchSavedSplitResult()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func changeEventName(_ sender: UIButton) {
        let eventNameTextField = UITextField()
        let alert = UIAlertController(title: Constants.StringsForAlert.RenameTitle, message: "Rename this result", preferredStyle: UIAlertControllerStyle.alert)
        var alertTextField = [UITextField]()
        
        alert.addTextField(){ textField in
            eventNameTextField.keyboardType = UIKeyboardType.default
        }
        if alert.textFields != nil {
            alertTextField = alert.textFields as [UITextField]!
            alertTextField[0].placeholder = "Event name"
            alertTextField[0].text = savedStopwatchResults[sender.tag].splitEventName
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {[unowned self] (alert : UIAlertAction) in
            
            self.savedStopwatchResults[sender.tag].splitEventName = alertTextField[0].text!
            self.coreDataStackManager.saveContext()
            
            self.tableView.reloadData()
        } )
        alert.addAction(UIAlertAction(title: "Cancel" , style: UIAlertActionStyle.cancel, handler: nil))
        alert.view.setNeedsLayout()
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedStopwatchResults.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 89.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Saved Results", for: indexPath) as! SavedResultTableViewCell
        cell.pencilButton.tag = indexPath.row
        cell.savedResult = savedStopwatchResults[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let savedResult = savedStopwatchResults[indexPath.row]
            let current = Bool(savedResult.current!)
            if !current {
                sharedContext.delete(savedResult)
            } else {
                savedResult.saved = false
            }
            coreDataStackManager.saveContext()
            savedStopwatchResults.remove(at: indexPath.row)
            
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        let valueAtOldPosition = savedStopwatchResults[fromIndexPath.row]
        
        savedStopwatchResults.remove(at: fromIndexPath.row)
        savedStopwatchResults.insert(valueAtOldPosition, at: toIndexPath.row)
        for (index,value) in savedStopwatchResults.enumerated() {
            // value.positionOfSavedResult = index + 1
            value.positionOfSavedResult = NSNumber(value: index + 1)
        }
        coreDataStackManager.saveContext()
        tableView.reloadData()
    }

}
