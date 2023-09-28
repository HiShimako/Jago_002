// InputViewController.swift
// Jago_002
//
// Created by user on 2023/09/11.

import UIKit
import RealmSwift

enum AnimationSet: String {
    case case0 = "2_out00"
    case case1 = "4_out00"
    case case2 = "6_out00"
    case case3 = "ezgif-frame-0"
    case case4 = "ezgif-frame-1"
}

class InputViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var personName: String?
    var smallImage: UIImage?
    var bigImage: UIImage?
    var isNewPerson: Bool = true
    var editingPersonID: Int?
    var backgroundViewIndex: Int?

    // MARK: - Outlets
    @IBOutlet weak var personNameTextField: UITextField!
    @IBOutlet weak var personsSmallPhotoImageView: UIImageView!
    @IBOutlet weak var personsBigPhotoImageView: UIImageView!
    @IBOutlet weak var selectBackGroundViewSegment: UISegmentedControl!
    @IBOutlet weak var backGroundView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialStates()
    }

    // MARK: - Initialization Methods
    private func setupInitialStates() {
        setupInitialImages()
        if let bgIndex = backgroundViewIndex {
            selectBackGroundViewSegment.selectedSegmentIndex = bgIndex
        }
        setupInitialAnimation()
        setupSegmentedControl()
    }

    private func setupInitialImages() {
        personsSmallPhotoImageView.image = smallImage
        personsBigPhotoImageView.image = bigImage
    }
    
    private func setupInitialAnimation() {
        applyAnimationBasedOnSegmentIndex(selectBackGroundViewSegment.selectedSegmentIndex)
    }
    
    private func setupSegmentedControl() {
        let originalImages = [
            AnimationSet.case0.rawValue,
            AnimationSet.case1.rawValue,
            AnimationSet.case2.rawValue,
            AnimationSet.case3.rawValue,
            AnimationSet.case4.rawValue
        ]
        
        for (index, imageName) in originalImages.enumerated() {
            if let image = UIImage(named: "\(imageName)1")?.withRenderingMode(.alwaysOriginal) {
                selectBackGroundViewSegment.setImage(image, forSegmentAt: index)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func selectBackGroundViewSegmentChanged(_ sender: Any) {
        applyAnimationBasedOnSegmentIndex((sender as AnyObject).selectedSegmentIndex)
        selectBackGroundViewSegment.addTarget(self, action: #selector(selectBackGroundViewSegmentChanged(_:)), for: .valueChanged)
    }
    
    @IBAction func postAction(_ sender: Any) {
        let realm = try! Realm()
        if isNewPerson {
            let newPerson = Person()
            newPerson.id = (realm.objects(Person.self).max(ofProperty: "id") as Int? ?? 0) + 1
            newPerson.personName = personNameTextField.text
            newPerson.smallImage = smallImage?.jpegData(compressionQuality: 0.01)
            newPerson.bigImage = bigImage?.jpegData(compressionQuality: 0.01)
            newPerson.backgroundViewIndex = selectBackGroundViewSegment.selectedSegmentIndex
            do {
                try realm.write {
                    realm.add(newPerson)
                }
            } catch {
                print("Error saving new person to Realm: \(error)")
            }
        } else {
            guard let id = editingPersonID, let personToUpdate = realm.object(ofType: Person.self, forPrimaryKey: id) else {
                return
            }
            do {
                try realm.write {
                    personToUpdate.personName = personNameTextField.text
                    personToUpdate.smallImage = smallImage?.jpegData(compressionQuality: 0.01)
                    personToUpdate.bigImage = bigImage?.jpegData(compressionQuality: 0.01)
                    personToUpdate.backgroundViewIndex = selectBackGroundViewSegment.selectedSegmentIndex
                }
            } catch {
                print("Error updating the person in Realm: \(error)")
            }
        }
        if let navController = navigationController {
            navController.popViewController(animated: true)
        }
    }

    @IBAction func editPersonImageTapped(_ sender: Any) {
        selectImageUtility.showAlert(self)
    }
    
    // MARK: - Helper Functions
    private func applyAnimationBasedOnSegmentIndex(_ index: Int) {
        let animationSet: AnimationSet
        switch index {
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
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            smallImage = selectedImage
            personsSmallPhotoImageView.image = smallImage
        }

        if let originalImage = info[.originalImage] as? UIImage {
            bigImage = originalImage
            personsBigPhotoImageView.image = bigImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - BackGroundAnimationUtility
struct BackGroundAnimationUtility {
    static func applyAnimation(on view: UIView, withPrefix prefix: String) {
        guard let imageView = view as? UIImageView,
              let animationImages = fetchAnimationImages(withPrefix: prefix),
              !animationImages.isEmpty else {
            return
        }
        
        imageView.animationImages = animationImages
        imageView.animationDuration = 1.0
        imageView.animationRepeatCount = 0
        imageView.startAnimating()
    }
    
    private static func fetchAnimationImages(withPrefix prefix: String) -> [UIImage]? {
        var backGroundImageArray: [UIImage] = []
        var index = 1
        while let image = UIImage(named: "\(prefix)\(index)") {
            backGroundImageArray.append(image)
            index += 1
        }
        return backGroundImageArray.isEmpty ? nil : backGroundImageArray
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

