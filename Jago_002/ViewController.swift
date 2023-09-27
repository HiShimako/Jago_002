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
        loadSavedPersons()
        personListTableView.reloadData()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        personListTableView.delegate = self
        personListTableView.dataSource = self
    }
    
    private func loadSavedPersons() {
        let realm = try! Realm()
        persons = realm.objects(Person.self)
    }
    
    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PersonsTableViewCell
        
        let person = persons[indexPath.row]
        if let data = person.smallImage,
           let image = UIImage(data: data) {
            cell.personImageView.image = image
        }
        
        cell.smallImageButton.tag = person.id
           cell.commentButton.tag = person.id
           cell.editButton.tag = person.id
        
        let backgroundViewIndex = person.backgroundViewIndex
        let animationSet: AnimationSet
        switch backgroundViewIndex {
        case 0:
            animationSet = .case0
        case 1:
            animationSet = .case1
        case 2:
            animationSet = .case2
        case 3:
            animationSet = .case3
        case 4:
            animationSet = .case4
        default:
            animationSet = .case4
        }
        
        if let backgroundImage = UIImage(named: "\(animationSet.rawValue)1")?.withRenderingMode(.alwaysOriginal) {
            cell.backgroundImageView.image = backgroundImage
        }
        
        
        cell.delegate = self
        cell.smallImageButton.tag = indexPath.row
        cell.commentButton.tag = indexPath.row
        cell.editButton.tag = indexPath.row
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
    func tapEditButton(id: Int) {
        let editVC = self.storyboard?.instantiateViewController(identifier: "EditAndPost") as! InputViewController
        editVC.isNewPerson = false
        
        let person = persons[id]
        editVC.editingPersonID = person.id
        editVC.personName = person.personName
        editVC.backgroundViewIndex = person.backgroundViewIndex 
        if let smallImageData = person.smallImage,
           let smallImg = UIImage(data: smallImageData) {
            editVC.smallImage = smallImg
        }

        if let bigImageData = person.bigImage,
           let bigImg = UIImage(data: bigImageData) {
            editVC.bigImage = bigImg
        }

        self.navigationController?.pushViewController(editVC, animated: true)
    }

//    func tapEditButton(id: Int) {
//        let editVC = self.storyboard?.instantiateViewController(identifier: "EditAndPost") as! InputViewController
//        editVC.isNewPerson = false
//        editVC.editingPersonID = id
//        //        let person = personsArray[id]
//        //        editVC.personName = person.personName
//        //
//
//        if let person = persons?.first(where: { $0.id == id }) {
//            editVC.personName = person.personName
//            if let smallImageData = person.smallImage,
//               let smallImg = UIImage(data: smallImageData) {
//                editVC.smallImage = smallImg
//            }
//
//            if let bigImageData = person.bigImage,
//               let bigImg = UIImage(data: bigImageData) {
//                editVC.bigImage = bigImg
//            }
//
//            self.navigationController?.pushViewController(editVC, animated: true)
//        }
//    }
    
    // MARK: - IBActions
    @IBAction func addPerson(_ sender: Any) {
        selectImageUtility.showAlert(self)
    }
    
    
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage,
           let originalImage = info[.originalImage] as? UIImage {
            let editPostVC = self.storyboard?.instantiateViewController(identifier: "EditAndPost") as! InputViewController
            editPostVC.smallImage = selectedImage
            editPostVC.bigImage = originalImage
            self.navigationController?.pushViewController(editPostVC, animated: true)
            picker.dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - CatchProtocol Implementations
    func tapSmallImage(id: Int) {
        let recordingVC = self.storyboard?.instantiateViewController(identifier: "RecordingVC") as! RecordingViewController
        recordingVC.receivedPersonID = id
        self.navigationController?.pushViewController(recordingVC, animated: true)
    }

    func tapCommentButton(id: Int) {
        let recordedVC = self.storyboard?.instantiateViewController(identifier: "RecordedViewController") as! RecordedViewController
        recordedVC.receivedPersonID = id
        self.navigationController?.pushViewController(recordedVC, animated: true)
    }

}

