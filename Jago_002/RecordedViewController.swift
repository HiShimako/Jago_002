//
//  RecordedViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/16.
//

import UIKit
import RealmSwift

class RecordedViewController: UIViewController {
    
    var receivedPersonID: Int?
    
    @IBOutlet weak var commentView: UITextView!
    @IBOutlet weak var personName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Realmから指定したIDのPersonを取得
        let realm = try! Realm()
        if let personID = receivedPersonID,
           let person = realm.object(ofType: Person.self, forPrimaryKey: personID) {
            
            personName.text = person.personName
            
            var displayText = ""
            for comment in person.comments {
                displayText += "時間: \(comment.time)\nコメント: \(comment.commentText)\n\n"
            }
            
            commentView.text = displayText
        }
    }
}
