import UIKit
import AVFoundation
import Speech

class RecordingViewController: UIViewController {
    var isRecording = false
    let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine!
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var recordingView: UIImageView!
    @IBOutlet weak var backGroundView: UIImageView!
    @IBOutlet weak var animationSetSelector: UISegmentedControl!

    var personsArray: [[String: Any]]!
    var receivedRow: Int?
    var backGroundImageArray: [UIImage] = []
    var selectedSegment: Int = 0
    var comments: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = UIImage(named: "2_out001") {
            animationSetSelector.setImage(image, forSegmentAt: 0)
        }

        personsArray = UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] ?? []
        audioEngine = AVAudioEngine()

        // Initialize segments
        animationSetSelector.setTitle(" ", forSegmentAt: 0)
        animationSetSelector.setTitle(" ", forSegmentAt: 1)
        animationSetSelector.setImage(AnimationSet.setOne.firstImage, forSegmentAt: 0)
        animationSetSelector.setImage(AnimationSet.setTwo.firstImage, forSegmentAt: 1)
 

        if let segmentTitle = animationSetSelector.titleForSegment(at: animationSetSelector.selectedSegmentIndex),
           let animationSet = AnimationSet(rawValue: segmentTitle) {
            loadAnimationImages(for: animationSet)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let receivedRow = receivedRow, receivedRow < personsArray.count,
                let _ = personsArray[receivedRow]["bigImage"] as? Data else {
              return
          }
        

        
        recordingView.image = UIImage(data: personsArray[receivedRow]["bigImage"] as! Data)

        try? startLiveTranscription()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization { _ in }
    }

    enum AnimationSet: String {
        case setOne = "2_out00"
        case setTwo = "4_out00"

        var firstImage: UIImage? {
            return UIImage(named: "\(self.rawValue)1")
        }
    }

    @IBAction func animationSetChanged(_ sender: UISegmentedControl) {
        guard let segmentTitle = sender.titleForSegment(at: sender.selectedSegmentIndex),
              let animationSet = AnimationSet(rawValue: segmentTitle) else {
            return
        }
        loadAnimationImages(for: animationSet)
    }

    func loadAnimationImages(for set: AnimationSet) {
        backGroundImageArray = []
        while let backgroundImage = UIImage(named: "\(set.rawValue)\(backGroundImageArray.count+1)") {
            backGroundImageArray.append(backgroundImage)
        }
        backGroundView.animationImages = backGroundImageArray
        backGroundView.startAnimating()
    }

    func stopLiveTranscription() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionReq?.endAudio()
    }

    func startLiveTranscription() throws {
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        textView.text = ""
        recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionReq = recognitionReq else { return }
        recognitionReq.shouldReportPartialResults = true

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, _) in
            recognitionReq.append(buffer)
        }
        
        try audioEngine.start()
        recognizer.recognitionTask(with: recognitionReq) { (result, error) in
            if let _ = error { return }
            DispatchQueue.main.async {
                self.textView.text = result?.bestTranscription.formattedString
            }
        }
    }

    @IBAction func stopRecording(_ sender: Any) {
        stopLiveTranscription()
        // receivedRowを安全にアンラップ
        if let receivedRow = receivedRow {
            comments.append(createCommentDict())
            personsArray[receivedRow].updateValue(comments, forKey: "comments")
            
            UserDefaults.standard.set(personsArray, forKey: "personsArray")
            self.navigationController?.popViewController(animated: true)
        }

    }

    func createCommentDict() -> [String: Any] {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let currentDateString = formatter.string(from: currentDate)

        return [
            "time": currentDateString,
            "comment": textView.text ?? ""
        ]
    }
}
