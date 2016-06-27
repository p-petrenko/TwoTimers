//
//  SavedResultTableViewCell.swift
//  TwoTimers
//
//  Created by Polina Petrenko on 27.06.16.
//  Copyright © 2016 Polina Petrenko. All rights reserved.
//

import UIKit

class SavedResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var resultName: UILabel!
    @IBOutlet weak var savedTime: UILabel!
    @IBOutlet weak var dAndTFromSplit: UILabel!
    @IBOutlet weak var pencilButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
