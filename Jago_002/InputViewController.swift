//
//  InputViewController.swift
//  Jago_002
//
//  Created by user on 2023/09/12.
//
import UIKit

enum AnimationSet: String {
    case caseOne = "2_out00"
    case caseTwo = "4_out00"
}

class InputViewController: UIViewController {
    
    // MARK: - Properties
    var personName: String?
    var smallImage: UIImage?
    var bigImage: UIImage?
    
    // MARK: - Outlets
    @IBOutlet weak var personNameTextField: UITextField!
    @IBOutlet weak var personsSmallPhotoImageView: UIImageView!
    @IBOutlet weak var personsBigPhotoImageView: UIImageView!
    @IBOutlet weak var selectBackGroundViewSegment: UISegmentedControl!

    @IBOutlet weak var backGroundView: UIImageView!
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialImages()
        setupInitialAnimation()
    }
    
    private func setupInitialImages() {
        personsSmallPhotoImageView.image = smallImage
        personsBigPhotoImageView.image = bigImage
    }
    
    private func setupInitialAnimation() {
        applyAnimationBasedOnSegmentIndex(selectBackGroundViewSegment.selectedSegmentIndex)
    }
    
    // MARK: - Actions
    @IBAction func selectBackGroundViewAction(_ sender: Any) {
        applyAnimationBasedOnSegmentIndex(selectBackGroundViewSegment.selectedSegmentIndex)
    }
    
    @IBAction func postAction(_ sender: Any) {
        guard let personDict = createPersonDict() else { return }
        saveNewPerson(personDict)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    private func applyAnimationBasedOnSegmentIndex(_ index: Int) {
        let animationSet: AnimationSet = index == 0 ? .caseOne : .caseTwo
        BackGroundAnimationUtility.applyAnimation(on: backGroundView, withPrefix: animationSet.rawValue)
    }
    
    private func createPersonDict() -> [String: Any]? {
        guard let personName = personNameTextField.text,
              let smallImageData = personsSmallPhotoImageView.image?.jpegData(compressionQuality: 0.01),
              let bigImageData = personsBigPhotoImageView.image?.jpegData(compressionQuality: 0.01) else {
            return nil
        }
        return [
            "personName": personName,
            "smallImage": smallImageData,
            "bigImage": bigImageData,
            "comments": [] as [[String: Any]],
            "backgroundViewIndex": selectBackGroundViewSegment.selectedSegmentIndex
        ]
    }
    
    private func fetchPersonsArray() -> [[String: Any]] {
        return UserDefaults.standard.array(forKey: "personsArray") as? [[String: Any]] ?? []
    }
    
    private func saveNewPerson(_ personDict: [String: Any]) {
        var personsArray = fetchPersonsArray()
        personsArray.append(personDict)
        UserDefaults.standard.setValue(personsArray, forKey: "personsArray")
    }
}

struct BackGroundAnimationUtility {
    private static func fetchAnimationImages(withPrefix prefix: String) -> [UIImage] {
        var backGroundImageArray: [UIImage] = []
        var index = 0
        while let image = UIImage(named: "\(prefix)\(index)") {
            backGroundImageArray.append(image)
            index += 1
        }
        return backGroundImageArray
    }
    static func applyAnimation(on view: UIView, withPrefix prefix: String) {
        
        if let imageView = view as? UIImageView {
            let animationImages = fetchAnimationImages(withPrefix: prefix)
            
            if animationImages.isEmpty {
                print("No animation images found.")
                return
            }
            
            imageView.animationImages = animationImages
            imageView.animationDuration = 1.0
            imageView.animationRepeatCount = 0
            imageView.startAnimating()
        } else {
            print("The provided view is not an UIImageView.")
        }
        
    }
}
