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
                      SFSpeechRecognizerDelegate,
                      UIGestureRecognizerDelegate,
                      CatchProtocol {
    
    // MARK: - Variables
    var personsArray: [[String: Any]] = []
    
    // MARK: - IBOutlets
    @IBOutlet weak var personListTableView: UITableView!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadSavedPersons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = UserDefaults.standard
        if let perArray = userDefaults.object(forKey: "personsArray") as? [[String: Any]] {
            personsArray = perArray
        }
        personListTableView.reloadData()
    }
    
    // MARK: - Setup
    func setupTableView() {
        personListTableView.delegate = self
        personListTableView.dataSource = self
    }
    
    func loadSavedPersons() {
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
        cell.delegate = self
        cell.smallImageButton.tag = indexPath.row
        cell.commentButton.tag = indexPath.row
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 1 / 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = personsArray[indexPath.row]
        if let imageData = cellData["bigImage"] as? Data,
           let image = UIImage(data: imageData) {
            performSegue(withIdentifier: "showRecordingViewController", sender: (image, indexPath))
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            personsArray.remove(at: indexPath.row)
            UserDefaults.standard.set(personsArray, forKey: "personsArray")
            tableView.reloadData()
        }
    }
    
    // MARK: - IBActions
    @IBAction func addPerson(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func tapComment(_ sender: UIButton) {
        debugPrint(sender)
    }
    
    // MARK: - Custom Methods
    func showAlert() {
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { _ in
            self.checkCamera()
        }
        
        let albumAction = UIAlertAction(title: "アルバム", style: .default) { _ in
            self.checkAlbam()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func checkCamera() {
        let sourceType: UIImagePickerController.SourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            present(cameraPicker, animated: true, completion: nil)
        }
    }
    
    func checkAlbam() {
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let albumPicker = UIImagePickerController()
            albumPicker.allowsEditing = true
            albumPicker.sourceType = sourceType
            albumPicker.delegate = self
            present(albumPicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage,
           let originalImage = info[.originalImage] as? UIImage {
            let editPostVC = self.storyboard?.instantiateViewController(identifier: "EditAndPost") as! InputViewController
            editPostVC.smallImage = selectedImage
            editPostVC.bigImage = originalImage
            self.navigationController?.pushViewController(editPostVC, animated: true)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Protocol Implementations (CatchProtocol etc.)
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
