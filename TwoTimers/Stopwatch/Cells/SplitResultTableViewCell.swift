//
//  SplitResultTableViewCell.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 27.06.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit

class SplitResultTableViewCell: UITableViewCell {

    var cellDateTime = NSDate()
    var cellTimeInterval = String()
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    
    @IBOutlet weak var resultName: UILabel!
    @IBOutlet weak var numOfSplitResult: UILabel!
    @IBOutlet weak var timeInterval: UILabel!
    @IBOutlet weak var dateAndTimeOfSplitPressing: UILabel!
    @IBOutlet weak var saveThisResultButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
