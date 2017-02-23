//
//  SplitResultTableViewCell.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 27.06.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit

class SplitResultTableViewCell: UITableViewCell {
    
    var currentResult: SplitStopwatchResult? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var resultName: UILabel!
    @IBOutlet weak var numOfSplitResult: UILabel!
    @IBOutlet weak var timeInterval: UILabel!
    @IBOutlet weak var dateAndTimeOfSplitPressing: UILabel!
    @IBOutlet weak var saveThisResultButton: UIButton!
    
    
    fileprivate func updateUI() {
        resultName.text = nil
        timeInterval.text = nil
        dateAndTimeOfSplitPressing.text = nil
        numOfSplitResult.text = nil
        
        if let result = self.currentResult {
            resultName.text = result.splitEventName
            timeInterval.text = result.splitTimeLabel
            dateAndTimeOfSplitPressing.text = transferNSDateIntoString(result.splitDateAndTimeOfSplit! as Date)
            numOfSplitResult.text = "#" + String(saveThisResultButton.tag + 1) + " "
            if let resultIsSaved = result.saved as? Bool, resultIsSaved {
                saveThisResultButton.isHidden = true
            } else {
                if saveThisResultButton.isHidden {
                    saveThisResultButton.isHidden = false
                }
            }
        }
    }
    
    fileprivate func transferNSDateIntoString(_ fullDate: Date) -> String {
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
