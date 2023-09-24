//
//  selectImageUtility.swift
//  Jago_002
//
//  Created by user on 2023/09/24.
//

import UIKit

class selectImageUtility {
    static func showAlert(_ viewController: UIViewController) {
        let alertController = UIAlertController(title: "選択", message: "どちらを使用しますか", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { _ in
            checkCamera(viewController)
        }
        
        let albumAction = UIAlertAction(title: "アルバム", style: .default) { _ in
            checkAlbum(viewController)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        viewController.present(alertController, animated: true)
    }
    
    static func checkCamera(_ viewController: UIViewController) {
        let sourceType: UIImagePickerController.SourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraPicker = UIImagePickerController()
            cameraPicker.allowsEditing = true
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = viewController as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
            viewController.present(cameraPicker, animated: true)
        }
    }
    
    static func checkAlbum(_ viewController: UIViewController) {
        let sourceType: UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let albumPicker = UIImagePickerController()
            albumPicker.allowsEditing = true
            albumPicker.sourceType = sourceType
            albumPicker.delegate = viewController as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
            viewController.present(albumPicker, animated: true)
        }
    }
}
