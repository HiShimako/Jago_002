//
//  FirstTableViewCell.swift
//  Jago_002
//
//  Created by user on 2023/09/11.
//

import UIKit

class FirstTableViewCell: UITableViewCell {
    
    var personImageData = Data()
    var personImage = UIImage()
    
    var contentsArray = [Contents]()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
