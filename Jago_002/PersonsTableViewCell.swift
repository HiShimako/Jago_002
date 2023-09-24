//
//  PersonsTableViewCell.swift
//  Jago_002
//
//  Created by user on 2023/09/16.
//

import UIKit

// MARK: - CatchProtocol
protocol CatchProtocol {
    func tapSmallImage(id: Int)
    func tapCommentButton(id: Int)
    func tapEditButton(id: Int) 
}

// MARK: - PersonsTableViewCell
class PersonsTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var smallImageButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        delegate?.tapEditButton(id: sender.tag)
    }
    
    
    
    // MARK: - Properties
    var delegate: CatchProtocol?
    
    // MARK: - Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - IBActions
    @IBAction func smallImageButton(_ sender: UIButton) {
        delegate?.tapSmallImage(id: sender.tag)
    }
    
    @IBAction func commentButton(_ sender: UIButton) {
        delegate?.tapCommentButton(id: sender.tag)
    }
}
