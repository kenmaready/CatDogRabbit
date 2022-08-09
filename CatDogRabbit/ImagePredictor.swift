//
//  ImagePredictor.swift
//  CatDogRabbit
//
//  Created by Ken Maready on 8/8/22.
//

import Vision
import UIKit

class ImagePredictor {
    private static var instance: VNCoreMLModel?
    private static var model: VNCoreMLModel {
        get {
            if let existingModel = instance {
                return existingModel
            } else {
                instance = createModel()
                return instance!
            }
        }
    }
    typealias ImagePredictionHandler = (_ predictions: [Prediction]?) -> Void
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()
    
    struct Prediction {
        let classification: String
        let confidence: Float
    }
    
    static func createModel() -> VNCoreMLModel {
        
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()

        // Create an instance of the image classifier's wrapper class.
        let imageClassifierWrapper = try? CatDogClassifier(configuration: defaultConfig)

        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }

        // Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model

        // Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }

        return imageClassifierVisionModel
    }
    
    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler.")
        }
        
        var predictions: [Prediction]? = nil
        
        defer {
            predictionHandler(predictions)
        }
        
        if let error = error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }
        
        if request.results == nil {
            print("Vision request had no results.")
            return
        }
        
        guard let observations = request.results as? [VNClassificationObservation] else {
            print("VNRequest produceed the wrong result type: \(type(of: request.results))")
            return
        }
        
        predictions = observations.map { observation in
            Prediction(classification: observation.identifier, confidence: observation.confidence)
        }
    }
    
    func predict(for image: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) else {
            fatalError("Selected photo does not have associated orientation.")
        }
            
        guard let cgImage = image.cgImage else {
            fatalError("Selected photo does not have underlying CGImage.")
        }
        
        let request = createImageClassificationRequest()
        predictionHandlers[request] = completionHandler
        
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)
        let requests: [VNRequest] = [request]
        
        try handler.perform(requests)
    }
    
    private func createImageClassificationRequest() -> VNImageBasedRequest {
        let request = VNCoreMLRequest(model: ImagePredictor.model, completionHandler: visionRequestHandler)
        request.imageCropAndScaleOption = .centerCrop
        return request
    }
}
