//
//  OptionsTableViewCell.swift
//  RunTracker
//
//  Created by Julia García Martínez on 18/02/2020.
//  Copyright © 2020 Julia García Martínez. All rights reserved.
//

import UIKit

class OptionsTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var optionsTitle: UILabel!
    @IBOutlet weak var optionsIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
