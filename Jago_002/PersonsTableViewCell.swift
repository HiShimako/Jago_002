//
//  PersonsTableViewCell.swift
//  Jago_002
//
//  Created by user on 2023/09/16.
//

import UIKit

// MARK: - CatchProtocol
protocol CatchProtocol: AnyObject  {
    func tapSmallImage(id: Int)
    func tapCommentButton(id: Int)
    func tapEditButton(id: Int) 
}

// MARK: - PersonsTableViewCell
class PersonsTableViewCell: UITableViewCell {
  
    weak var cellDelegate: CatchProtocol?
    // MARK: - IBOutlets
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var smallImageButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    // MARK: - Properties
    var delegate: CatchProtocol?
    
    // MARK: - IBActions
    @IBAction func smallImageButton(_ sender: UIButton) {
        cellDelegate?.tapSmallImage(id: sender.tag)
    }
    
    @IBAction func commentButton(_ sender: UIButton) {
        cellDelegate?.tapCommentButton(id: sender.tag)
    }
    @IBAction func editButtonTapped(_ sender: UIButton) {
           cellDelegate?.tapEditButton(id: sender.tag)
       }
}
