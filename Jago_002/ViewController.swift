//
//  ViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/11.
//

import UIKit
import Photos
import Speech
import Foundation
import RealmSwift

class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate,
                      SelectImageUtilityDelegate,
                      CatchProtocol {
    
    // MARK: - Variables
    var persons: Results<Person>!
    
    // MARK: - IBOutlets
    @IBOutlet weak var personListTableView: UITableView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        personListTableView.reloadData()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        personListTableView.delegate = self
        personListTableView.dataSource = self
    }
    
    
    // MARK: - TableView DataSource Methods

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        return realm.objects(Person.self).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PersonsTableViewCell

        let realm = try! Realm()
        let persons = realm.objects(Person.self)
        
        if indexPath.row < persons.count {
            let person = persons[indexPath.row]

            // Load the smallImage for the current row
            if let data = person.smallImage, let image = UIImage(data: data) {
                cell.personImageView.image = image
            }
            
            // Setup buttons with the id of the person
            cell.smallImageButton.tag = indexPath.row
            cell.commentButton.tag = indexPath.row
            cell.editButton.tag = indexPath.row
            
            // Load the background based on the backgroundViewIndex
            let backgroundViewIndex = person.backgroundViewIndex
            let animationSet = animationSetFrom(backgroundViewIndex: backgroundViewIndex)
            if let backgroundImage = UIImage(named: "\(animationSet.rawValue)1")?.withRenderingMode(.alwaysOriginal) {
                cell.backgroundImageView.image = backgroundImage
            }
            cell.cellDelegate = self
        }
        return cell
    }
    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 1 / 3
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realm = try! Realm()
            if let personToDelete = persons?[indexPath.row] {
                try! realm.write {
                    realm.delete(personToDelete)
                }
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    let selectImageUtility = SelectImageUtility()
    func tapEditButton(id: Int) {
        let editVC = self.storyboard?.instantiateViewController(identifier: "EditAndPost") as! InputViewController
        editVC.isNewPerson = false
        editVC.editingPersonID = id
        self.navigationController?.pushViewController(editVC, animated: true)
    }

    
    
    // MARK: - IBActions
    @IBAction func addPerson(_ sender: Any) {
        selectImageUtility.delegate = self
        selectImageUtility.showAlert(from: self)
    }
    
    // MARK: - CatchProtocol Implementations
    
    func tapSmallImage(id: Int) {
        let recordingVC = self.storyboard?.instantiateViewController(identifier: "RecordingVC") as! RecordingViewController
        recordingVC.id =  id
        self.navigationController?.pushViewController(recordingVC, animated: true)
    }

    func tapCommentButton(id: Int) {
        let recordedVC = self.storyboard?.instantiateViewController(identifier: "RecordedViewController") as! RecordedViewController
        recordedVC.receivedPersonID = id
        self.navigationController?.pushViewController(recordedVC, animated: true)
    }
    
}
extension ViewController {
    func didPickImages(smallImage: UIImage?, bigImage: UIImage?) {
        let inputVC = self.storyboard?.instantiateViewController(identifier: "EditAndPost") as! InputViewController
        inputVC.isNewPerson = true
        inputVC.smallImage = smallImage
        inputVC.bigImage = bigImage
        self.navigationController?.pushViewController(inputVC, animated: true)
    }
}


