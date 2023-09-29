//
//  selectImageUtility.swift
//  Jago_002
//
//  Created by user on 2023/09/24.
//

import UIKit
class SelectImageUtility: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: SelectImageUtilityDelegate?
    
    var smallImage: UIImage?
    var bigImage: UIImage?
    
    func showAlert(from viewController: UIViewController) {
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { _ in
            self.checkCamera(from: viewController)
        }
        
        let albumAction = UIAlertAction(title: "アルバム", style: .default) { _ in
            self.checkAlbum(from: viewController)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true)
    }
    
    private func checkCamera(from viewController: UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = .camera
            cameraPicker.delegate = self
            viewController.present(cameraPicker, animated: true)
        }
    }
    
    private func checkAlbum(from viewController: UIViewController) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let albumPicker = UIImagePickerController()
            albumPicker.allowsEditing = true
            albumPicker.sourceType = .photoLibrary
            albumPicker.delegate = self
            viewController.present(albumPicker, animated: true)
        }
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let smallImg = info[.editedImage] as? UIImage
        let bigImg = info[.originalImage] as? UIImage

        delegate?.didPickImages(smallImage: smallImg, bigImage: bigImg)
        picker.dismiss(animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
  
        picker.dismiss(animated: true, completion: nil)
    }
    
   
}



