//
//  ViewController.swift
//  Detector
//
//  Created by Andres Torres on 8/5/18.
//  Copyright © 2018 andytb. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var photoContainer: UIImageView!
    
    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Take a Photo".uppercased()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
    }
    
    func detection(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Loading coreML model fail")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else{
                fatalError("Model Failed to process image")
            }
            
            print(results)
            
            if let firstResult = results.first{
                print("---------------- \(firstResult.identifier)")
                self.navigationItem.title = firstResult.identifier.uppercased()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            
            try handler.perform([request])
            
        } catch  {
            
            print(error)
        }
        
    }



}

extension ViewController: UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage{
            photoContainer.contentMode = .scaleAspectFit
            photoContainer.image = photo
            
            guard let ciImage = CIImage(image: photo) else{
                fatalError("Couldnt convert to ciImage")
            }
        
            detection(image: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
}

extension ViewController: UINavigationControllerDelegate{
    
}

