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
    
    var personsArray: [[String: Any]] = []
    var receivedIndexPath: IndexPath?
    
    @IBOutlet weak var recordingView: UIImageView!
    var audioEngine: AVAudioEngine!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var selectedImage: UIImage?
    var selectedCellIndexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingView.image = selectedImage
        
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
        print("stopRecording was called")
        self.dismiss(animated: true, completion: nil)

    }
    
}
