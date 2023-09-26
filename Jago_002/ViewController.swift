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

class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource,
                      UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate,
                      CatchProtocol {
    
    // MARK: - Variables
    var personsArray: [[String: Any]] = []
    
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
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
            personsArray = savedPersonsArray
        }
    }
    
    // MARK: - TableView DataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PersonsTableViewCell
        
        if let data = personsArray[indexPath.row]["smallImage"] as? Data,
           let image = UIImage(data: data) {
            cell.personImageView.image = image
        }
        
        if let backgroundViewIndex = personsArray[indexPath.row]["backgroundViewIndex"] as? Int {
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
                animationSet = .case4            }
            
            if let backgroundImage = UIImage(named: "\(animationSet.rawValue)1")?.withRenderingMode(.alwaysOriginal) {
                cell.backgroundImageView.image = backgroundImage
            }
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
            personsArray.remove(at: indexPath.row)
            UserDefaults.standard.set(personsArray, forKey: "personsArray")
            tableView.reloadData()
        }
    }
    func tapEditButton(id: Int) {
        let editVC = self.storyboard?.instantiateViewController(identifier: "EditAndPost") as! InputViewController
        editVC.isNewPerson = false // 既存のPersonなのでfalse
            editVC.editingPersonID = id // 編集するPersonのID
        let personDict = personsArray[id]
        editVC.personName = personDict["personName"] as? String
        if let smallImageData = personDict["smallImage"] as? Data,
           let smallImage = UIImage(data: smallImageData) {
            editVC.smallImage = smallImage
        }
        if let bigImageData = personDict["bigImage"] as? Data,
           let bigImage = UIImage(data: bigImageData) {
            editVC.bigImage = bigImage
        }
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    // MARK: - IBActions
    @IBAction func addPerson(_ sender: Any) {
        selectImageUtility.showAlert(self)
//        showAlert()
    }
    
    // MARK: - Custom Methods
//    private func showAlert() {
//        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか", preferredStyle: .actionSheet)
//
//        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { _ in
//            self.checkCamera()
//        }
//
//        let albumAction = UIAlertAction(title: "アルバム", style: .default) { _ in
//            self.checkAlbam()
//        }
//
//        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
//
//        alertController.addAction(cameraAction)
//        alertController.addAction(albumAction)
//        alertController.addAction(cancelAction)
//        present(alertController, animated: true)
//    }
//
//    private func checkCamera() {
//        let sourceType: UIImagePickerController.SourceType = .camera
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            let cameraPicker = UIImagePickerController()
//            cameraPicker.allowsEditing = true
//            cameraPicker.sourceType = sourceType
//            cameraPicker.delegate = self
//            present(cameraPicker, animated: true)
//        }
//    }
//
//    private func checkAlbam() {
//        let sourceType: UIImagePickerController.SourceType = .photoLibrary
//        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//            let albumPicker = UIImagePickerController()
//            albumPicker.allowsEditing = true
//            albumPicker.sourceType = sourceType
//            albumPicker.delegate = self
//            present(albumPicker, animated: true)
//        }
//    }
    
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
        let VC = self.storyboard?.instantiateViewController(identifier: "RecordingVC") as! RecordingViewController
        VC.receivedRow = id
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func tapCommentButton(id: Int) {
        let VC = self.storyboard?.instantiateViewController(identifier: "RecordedViewController") as! RecordedViewController
        VC.receivedRow = id
        self.navigationController?.pushViewController(VC, animated: true)
    }
}

