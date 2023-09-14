//
//  RecordingViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/13.
//

import UIKit
import AVFoundation
import Speech

class RecordingViewController: UIViewController {
    
    var personsArray: [[String: Any]]!
    var receivedIndexPath: IndexPath!
    var receivedImageData: Data?
    
    @IBOutlet weak var recordingView: UIImageView!
    var audioEngine: AVAudioEngine!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var selectedImage: UIImage?
    var selectedCellIndexPath: IndexPath?
    
    
    func instantiateAndPresentRecordingVC(with imageData: Data?, at indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let RecordingVC = storyboard.instantiateViewController(withIdentifier: "RecordingVC") as? RecordingViewController {
            RecordingVC.receivedImageData = imageData
            RecordingVC.receivedIndexPath = indexPath // ここでindexPathを渡す
            RecordingVC.audioEngine = self.audioEngine
            self.present(RecordingVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedPersonsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] {
               self.personsArray = savedPersonsArray
           } else {
               print("No personsArray found in UserDefaults.")
           }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = receivedIndexPath,
               let imageData = personsArray[indexPath.row]["bigImage"] as? Data,
               let image = UIImage(data: imageData) {
                recordingView.image = image
            print("Image was set successfully")
        } else {
            print("receivedImageData is nil")
        }
        
    }
    @IBAction func stopRecording(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        self.dismiss(animated: true, completion: nil)

    }
    
}
