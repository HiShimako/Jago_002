//
//  RecordedViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/16.
//

import UIKit

class RecordedViewController: UIViewController {
    
//    var receivedIndexPath: IndexPath! = [0]
    var receivedRow: Int!

    @IBOutlet weak var commentView: UITextView!
    @IBOutlet weak var personName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UserDefaultsからpersonsArrayを取得
        guard let personsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] else {
            print("Could not retrieve personsArray.")
            return
        }
        
        let person = personsArray[receivedRow]
//        let person = personsArray[0]
        
        if let personNameString = person["personName"] as? String {
            personName.text = personNameString
        }
        
        guard let comments = person["comments"] as? [[String: Any]] else {
            commentView.text = ""
            return
        }
        
        if comments.isEmpty {
            commentView.text = ""
            return
        }
        
        var displayText = ""
        for comment in comments {
            if let time = comment["time"] as? String, let commentText = comment["comment"] as? String {
                displayText += "時間: \(time)\nコメント: \(commentText)\n\n"
            }
        }
        
        commentView.text = displayText
    }
    
}
