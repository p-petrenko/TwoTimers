//
//  SavedResultTableViewCell.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 27.06.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit

class SavedResultTableViewCell: UITableViewCell {
 
    var savedResult: SplitStopwatchResult? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var resultName: UILabel!
    @IBOutlet weak var savedTime: UILabel!
    @IBOutlet weak var dAndTFromSplit: UILabel!
    @IBOutlet weak var pencilButton: UIButton!

    fileprivate func updateUI() {
        resultName.text = nil
        savedTime.text = nil
        dAndTFromSplit.text = nil

        if let result = self.savedResult {
            resultName.text = result.splitEventName
            savedTime.text = result.splitTimeLabel
            dAndTFromSplit.text = transferDateIntoString(result.splitDateAndTimeOfSplit! as Date)
        }
    }

    fileprivate func transferDateIntoString(_ fullDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.medium
        let date = dateFormatter.string(from: fullDate)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = DateFormatter.Style.short
        timeFormatter.dateStyle = DateFormatter.Style.none
        let time = timeFormatter.string(from: fullDate)
        
        let localizedUserTandD = NSLocalizedString("%@ at %@",comment: "Reports date and time when Split button was pressed")
        let textOfDate = String.localizedStringWithFormat(localizedUserTandD, date , time)
        
        return textOfDate
    }
}
