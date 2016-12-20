//
//  SplitResultsTableViewController.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 27.06.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit
import CoreData

class SplitResultsTableViewController: UITableViewController {
    
    fileprivate var splitStopwatchResults = [SplitStopwatchResult]()
    fileprivate var coreDataStackManager = CoreDataStackManager.sharedInstance()
    fileprivate var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    @IBOutlet weak var folderButton: UIButton!
    
    @IBAction func saveThisSplitResult(_ sender: UIButton) {
        let eventNameTextField = UITextField()
        let alert = UIAlertController(title: Constants.StringsForAlert.SaveResultQuestion, message: Constants.StringsForAlert.EnterName, preferredStyle: UIAlertControllerStyle.alert)
        var alertTextField = [UITextField]()
        
        alert.addTextField(){ textField in
            eventNameTextField.keyboardType = UIKeyboardType.default
        }
        if alert.textFields != nil {
            alertTextField = alert.textFields as [UITextField]!
            alertTextField[0].placeholder = "Event name"
            alertTextField[0].text = splitStopwatchResults[sender.tag].splitEventName
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default){[unowned self] (alert : UIAlertAction) in

            // change 'event name' and 'saved' for current cell
            self.splitStopwatchResults[sender.tag].saved = true
            self.splitStopwatchResults[sender.tag].splitEventName = alertTextField[0].text!
            self.splitStopwatchResults[sender.tag].timeOfResultSaving = Date()
            self.coreDataStackManager.saveContext()
            
            if self.folderButton.isHidden == true {
                self.folderButton.alpha = 0
                self.folderButton.isHidden = false
                UIView.animate(withDuration: 1,
                    animations: {[unowned self] () in
                        self.folderButton.alpha = 1
                    }, completion: nil
                )
            }
            self.tableView.reloadData()
        } )
        alert.addAction(UIAlertAction(title: "Cancel" , style: UIAlertActionStyle.cancel, handler: nil))
        alert.view.setNeedsLayout()
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        splitStopwatchResults = coreDataStackManager.fetchCurrentSplitResult()
        self.tableView.reloadData()

        if !coreDataStackManager.fetchSavedSplitResult().isEmpty {
            folderButton.isHidden = false
        } else {
            folderButton.isHidden = true
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return splitStopwatchResults.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Split Results", for: indexPath) as! SplitResultTableViewCell
        cell.saveThisResultButton.tag = indexPath.row
        cell.currentResult = splitStopwatchResults[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let currentResult = splitStopwatchResults[indexPath.row]
            let saved = Bool(currentResult.saved!)
            if !saved {
                sharedContext.delete(currentResult)
            } else {
                currentResult.current = false
            }
            coreDataStackManager.saveContext()
            splitStopwatchResults.remove(at: indexPath.row)

            tableView.reloadData()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        if identifier == "Folder in SRTVC Segue" && !coreDataStackManager.fetchSavedSplitResult().isEmpty {
            return true
        }
        return false
    }
    
}
