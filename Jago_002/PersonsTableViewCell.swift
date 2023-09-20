//
//  PersonsTableViewCell.swift
//  Jago_002
//
//  Created by user on 2023/09/16.
//

import UIKit

protocol CatchProtocol {
    func tapSmallImage(id:Int)
    func tapCommentButton(id:Int)
}


class PersonsTableViewCell: UITableViewCell, UINavigationControllerDelegate {

    
    
//
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var smallImageButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    


    var delegate : CatchProtocol?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Action

    
    
    @IBAction func smallImageButton(_ sender: UIButton) {
        delegate?.tapSmallImage(id: sender.tag)
    }
    
    @IBAction func commentButton(_ sender: UIButton) {
        delegate?.tapCommentButton(id: sender.tag)
    }
    
    
    
}
