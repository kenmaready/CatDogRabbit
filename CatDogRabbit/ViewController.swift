//
//  ViewController.swift
//  CatDogRabbit
//
//  Created by Ken Maready on 8/7/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var mainImage: UIImageView!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerSetup()
        mainImage.image = UIImage(named: "select image")
    }

    @IBAction func selectImageTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerSetup() {
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            print("Camera is not available on this device/simulator. Select image from photo library.")
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mainImage.contentMode = .scaleAspectFit
            mainImage.image = image
            
            guard let ciImage = CIImage(image: image) else {
                fatalError("Error occurred while converting selected image to CIImage.")
            }
            
            analyze(ciImage)
        } else {
            print("unable to convert image to UIImage...")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func analyze(_ image: CIImage) {
        guard let model = try? VNCoreMLModel(for: CatDogClassifier().model) else {
            fatalError("Error occurred during instantiation of CatDogRabbitClassifier model.")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Error occurred during processing image via classification model.")
            }
            
            let classification = results.first
            for result in results {
                print("\(result.identifier): \(result.confidence)")
            }
            
            self.navigationItem.title = classification?.identifier.capitalized
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Error occurred in submitting request to classification model.")
        }
    }
}

