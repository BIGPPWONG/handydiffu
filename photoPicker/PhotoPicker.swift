/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var inputImg: [UIImage]
    @Binding var result: Bool
//    @EnvironmentObject var dataModel: DataModel
    
    /// A dismiss action provided by the environment. This may be called to dismiss this view controller.
    @Environment(\.dismiss) var dismiss
    
    /// Creates the picker view controller that this object represents.
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoPicker>) -> PHPickerViewController {
        
        // Configure the picker.
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        // Limit to images.
        configuration.filter = .images
        // Avoid transcoding, if possible.
        configuration.preferredAssetRepresentationMode = .current

        let photoPickerViewController = PHPickerViewController(configuration: configuration)
        photoPickerViewController.delegate = context.coordinator
        return photoPickerViewController
    }
    
    /// Creates the coordinator that allows the picker to communicate back to this object.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// Updates the picker while it’s being presented.
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PhotoPicker>) {
        // No updates are necessary.
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    let parent: PhotoPicker
    
    /// Called when one or more items have been picked, or when the picker has been canceled.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // Dismisss the presented picker.
        self.parent.dismiss()
        
        guard
            let result = results.first,
            result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        else { return }
        
        // Load a file representation of the picked item.
        // This creates a temporary file which is then copied to the app’s document directory for persistent storage.
        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
            if let error = error {
                print("Error loading file representation: \(error.localizedDescription)")
            } else if let url = url {
  
                    if let savedUrl = FileManager.default.copyItemToDocumentDirectory(from: url) {
                        // Add the new item to the data model.
                        Task {
//                        Task { @MainActor [dataModel = self.parent.dataModel] in
                            withAnimation {
                                let imageData:NSData = NSData(contentsOf: savedUrl)!
                                let image = UIImage(data: imageData as Data)
                                if let image = image {
                                    self.parent.inputImg = [image]
                                    self.parent.result = true
                                } else {
                                    self.parent.result = false
                                }
                                FileManager.default.removeItemFromDocumentDirectory(url: savedUrl)
//                                let item = Item(url: savedUrl)
//                                dataModel.addItem(item)
                            }
                        }
                    }
                
            }
        }
    }
    
    init(_ parent: PhotoPicker) {
        self.parent = parent
    }
}
