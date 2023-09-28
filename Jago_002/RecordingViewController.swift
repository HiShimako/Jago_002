//  RecordingViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/12.
//

import UIKit
import AVFoundation
import Speech
import RealmSwift

class RecordingViewController: UIViewController {
    
    // MARK: - Properties
    var isRecording = false
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine!
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var person: Person?
    var receivedPerson: Person?
    var receivedPersonID: Int?
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var recordingView: UIImageView!
    @IBOutlet weak var backGroundView: UIImageView!
    
    // MARK: - Variables
    var receivedRow: Int?
    var bestTranscriptionString: String?
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🌝 Current receivedRow: \(String(describing: receivedRow))")
        guard let realm = try? Realm() else {
            print("🌝Failed to initialize Realm")
            return
        }
        
        if let receivedID = receivedPersonID {
            person = realm.object(ofType: Person.self, forPrimaryKey: receivedID)
            
            print("🌝🌝🌝🌝🌝Loaded personName for ID \(receivedID): \(person?.personName ?? "nil")")
            
            
            if let personUnwrapped = person {
                // bigImageをrecordingViewに設定
                if let bigImageData = personUnwrapped.bigImage {
                    recordingView.image = UIImage(data: bigImageData)
                } else {
                    print("🌝bigImageData is nil")
                }
                
                // backgroundViewIndexをもとに背景アニメーションを設定
                let backgroundViewIndex = personUnwrapped.backgroundViewIndex
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
                BackGroundAnimationUtility.applyAnimation(on: backGroundView, withPrefix: animationSet.rawValue)
                print("Applying animation for backgroundViewIndex: \(backgroundViewIndex)")
            } else {
                //                    print("🌝No person object found for receivedRow: \(receivedRow)")
            }
        } else {
            print("🌝receivedRow is nil")
        }
        
        audioEngine = AVAudioEngine()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        try? startLiveTranscription()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization { _ in }
    }
    
    // MARK: - Helper Functions
    
    func stopLiveTranscription() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionReq?.endAudio()
    }
    
    func startLiveTranscription() throws {
        // Cancel any existing recognition task
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Initialize new recognition request
        bestTranscriptionString = ""
        recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionReq = recognitionReq else { return }
        recognitionReq.shouldReportPartialResults = true
        
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Configure input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, _) in
            recognitionReq.append(buffer)
        }
        
        // Start audio engine and recognition task
        try audioEngine.start()
        recognizer.recognitionTask(with: recognitionReq) { (result, error) in
            if error != nil { return }
            DispatchQueue.main.async {
                self.bestTranscriptionString = result?.bestTranscription.formattedString
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func stopRecording(_ sender: Any) {
        stopLiveTranscription()
            
        if let receivedID = receivedPersonID, let commentText = bestTranscriptionString {
            let comment = createComment(commentText: commentText)
            if let validReceivedRow = receivedRow {
                saveCommentToPerson(comment: comment, id: validReceivedRow)
            }
        }
            
        self.navigationController?.popViewController(animated: true)
    }

    func createComment(commentText: String) -> Comment {
        let comment = Comment()
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        comment.time = formatter.string(from: currentDate)
        comment.commentText = commentText
        return comment
    }
    
    func saveCommentToPerson(comment: Comment, id: Int)  {
        guard let realm = try? Realm() else {
            print("Error initializing Realm")
            return
        }
        
        if let receivedID = receivedPersonID {
            person = realm.object(ofType: Person.self, forPrimaryKey: receivedID)
        }
        
        if let receivedID = receivedPersonID, let commentText = bestTranscriptionString {
            let comment = createComment(commentText: commentText)
            if let person = realm.object(ofType: Person.self, forPrimaryKey: receivedID) {
                try? realm.write {
                    person.comments.append(comment)
                }
            }
        }
        
    }
    
}
