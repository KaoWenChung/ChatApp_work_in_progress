//
//  PhotoCaptureController.swift
//  ChatApp
//
//  Created by wyn on 2023/4/13.
//

import UIKit
import SwiftUI

final class PhotoCaptureController: UIImagePickerController {
    @EnvironmentObject var state: AppState

    private var photoTaken: ((PhotoCaptureController, Photo) -> Void)?
    private var photo = Photo()
    private let imageSizeThumbnails: CGFloat = 102
    private let maximumImageSize = 1024 * 1024 // 1 MB

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    static func show(source: UIImagePickerController.SourceType,
                     photoToEdit: Photo = Photo(),
                     photoTaken: ((PhotoCaptureController, Photo) -> Void)? = nil) {
        let picker = PhotoCaptureController()
        picker.photo = photoToEdit
        picker.setup(source)
        picker.photoTaken = photoTaken
        picker.present()
    }

    func setup(_ requestedSource: UIImagePickerController.SourceType) {
        if PhotoCaptureController.isSourceTypeAvailable(.camera) && requestedSource == .camera {
            sourceType = .camera
        } else {
            sourceType = .photoLibrary
        }
        allowsEditing = true
        delegate = self
    }

    func present() {
        UIViewController.keyWindow?.rootViewController?.present(self, animated: true)
    }

    private func compressImageIfNeeded(image: UIImage) -> UIImage? {
        let resultImage = image
        if let data = resultImage.jpegData(compressionQuality: 1),
            data.count > maximumImageSize {
            let neededQuality = CGFloat(maximumImageSize) / CGFloat(data.count)
            if let resized = resultImage.jpegData(compressionQuality: neededQuality),
               let resultImage = UIImage(data: resized) {
                return resultImage
            }
        }
        return resultImage
    }

    func hide() {
        photoTaken = nil
        dismiss(animated: true)
    }
}

extension PhotoCaptureController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let editImage = info[.editedImage] as? UIImage,
              let result = compressImageIfNeeded(image: editImage) else { return }
        photo.date = Date()
        photo.picture = result.jpegData(compressionQuality: 0.8)
        photo.thumbNail = result.thumbnail(size: imageSizeThumbnails)?.jpegData(compressionQuality: 0.8)
        photoTaken?(self, photo)
    }
}

private extension UIViewController {
    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
}
