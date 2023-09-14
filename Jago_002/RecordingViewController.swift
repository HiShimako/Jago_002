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
    
    var receivedImageData: Data?
    
    
    @IBOutlet weak var recordingView: UIImageView!
    var audioEngine: AVAudioEngine!
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var selectedImage: UIImage?
    var selectedCellIndexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordingView.image = selectedImage
        print("RecordingViewController was loaded")
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let imageData = receivedImageData {
            let image = UIImage(data: imageData)
            recordingView.image = image
        }
    }
    @IBAction func stopRecording(_ sender: Any) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            // 他の停止に関する処理もこちらに追加することができます。
        }
        print("stopRecording was called")
        // RecordingViewControllerを閉じ、その下にあるViewControllerに戻る
        self.dismiss(animated: true, completion: nil)

        
    }
    
}
