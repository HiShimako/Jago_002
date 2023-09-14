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

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var personsArray: [[String: Any]] = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecordingViewController", let vc = segue.destination as? RecordingViewController, let (image, indexPath) = sender as? (UIImage, IndexPath) {
            vc.selectedImage = image
            vc.selectedCellIndexPath = indexPath
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSpeechRecognition()
        setupTableView()
        loadSavedPersons()
    }

    func setupSpeechRecognition() {
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status {
            case .authorized: break // 権限がある場合、何もしない
            default: print("Speech recognition authorization not granted")
            }
        }
    }

    func setupTableView() {
        personListTableView.delegate = self
        personListTableView.dataSource = self
    }

    func loadSavedPersons() {
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
            personsArray = savedPersonsArray
        } else {
            personsArray = []
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = UserDefaults.standard
        
        if let perArray = userDefaults.object(forKey: "personsArray") as? [[String: Any]] {
            personsArray = perArray
        }
        //tableViewを更新
        personListTableView.reloadData()
    }

    @IBOutlet weak var personListTableView: UITableView!

    // MARK: テーブルビューデータ系

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let imageView = cell.viewWithTag(4) as? UIImageView {
            if let data = personsArray[indexPath.row]["smallImage"] as? Data {
                let image = UIImage(data: data)
                imageView.image = image
            } else {
                imageView.image = nil // Optionally set to a default image
            }
        }
        return cell
    }

    // MARK: テーブルビュー動作系

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 1 / 3
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellData = personsArray[indexPath.row]
        if let imageData = cellData["bigImage"] as? Data, let image = UIImage(data: imageData) {
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

    // MARK: 録音開始ボタンですること
    @IBAction func tappedSmallImage(_ sender: Any) {

        startRecording()
        
   
        guard let tappedImageView = gestureToImageView(sender: sender),
              let indexPath = findIndexPathFromImageView(tappedImageView),
              let selectedImageData = personsArray[indexPath.row]["bigImage"] as? Data else { return }
    
        instantiateAndPresentRecordingVC(with: selectedImageData, at: indexPath)
    }

    func gestureToImageView(sender: Any) -> UIImageView? {
        guard let gesture = sender as? UITapGestureRecognizer,
              let tappedImageView = gesture.view as? UIImageView else { return nil }
        return tappedImageView
    }

    func findIndexPathFromImageView(_ imageView: UIImageView) -> IndexPath? {
        guard let cell = imageView.superview?.superview as? UITableViewCell,
              let indexPath = personListTableView.indexPath(for: cell) else { return nil }
        print("Cell number is: \(indexPath.row)")
        return indexPath
    }

    func instantiateAndPresentRecordingVC(with imageData: Data?, at indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let RecordingVC = storyboard.instantiateViewController(withIdentifier: "RecordingVC") as? RecordingViewController {
            RecordingVC.audioEngine = self.audioEngine
            RecordingVC.receivedIndexPath = indexPath // Pass the indexPath to RecordingVC
            self.present(RecordingVC, animated: true, completion: nil)
        }
    }
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
    }
    
    func saveTextData(personName: String, textData: String) {
        let textDict: [String: Any] = [
            "personName": personName,
            "text": textData
        ]
        
        var textsArray = UserDefaults.standard.array(forKey: "textsArray") as? [[String: Any]] ?? []
        textsArray.append(textDict)
        UserDefaults.standard.set(textsArray, forKey: "textsArray")
    }
    
    func getCurrentTimeAsString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
    

    
    
    // MARK: 初期設定関係
    
    @IBAction func addPerson(_ sender: Any) {
        showAlert()
    }
    
    
    func showAlert(){
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (alert) in
            self.checkCamera()
        }
        
        let albamAction = UIAlertAction(title: "アルバム", style: .default) { (alert) in
            self.checkAlbam()
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        
        
        alertController.addAction(cameraAction)
        alertController.addAction(albamAction)
        alertController.addAction(cancelAction)
        present(alertController,animated: true,completion: nil)
    }
    
    //    カメラ立ち上げメソッド
    func checkCamera(){
        let sourceType:UIImagePickerController.SourceType = .camera
        
        //        カメラ利用可能かチェック
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            present(cameraPicker, animated: true,completion: nil)
            
        }
    }
    
    //    フォトライブラリの使用
    func checkAlbam() {
        let sourceType:UIImagePickerController.SourceType = .photoLibrary
        
        //        フォトライブラリのチェック
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            present(cameraPicker, animated: true,completion: nil)
        }
    }
   
    
    //    キャンセル時の処理
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.editedImage] as! UIImage
        let originalImage = info[.originalImage] as! UIImage
        
        //        ナビゲーションを用いて画面遷移
        let editPostVC = self.storyboard?.instantiateViewController(identifier: "EditAndPost") as! InputViewController
        
        editPostVC.smallImage = selectedImage
        editPostVC.bigImage = originalImage
        
        self.navigationController?.pushViewController(editPostVC, animated: true)
        
        //        ピッカーを閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
}
