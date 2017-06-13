//
//  ViewController.swift
//  InstaFilter
//
//  Created by Trevor MacGregor on 2017-06-13.
//  Copyright © 2017 TeevoCo. All rights reserved.
//

import UIKit
import CoreImage

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var intensity: UISlider!
    var currentImage:UIImage!
   
    //handles rendering
    var context:CIContext!
    //will store whatever filter we have activated
    var currentFilter:CIFilter!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        dismiss(animated: true)
        //we set our currentImage image to be the one selected in the image picker. This is required so we can have a copy of what was originally imported
        currentImage = image
        
        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }

    @IBAction func changeFilter(_ sender: Any) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumpDistortion",style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur",style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate",style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone",style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion",style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask",style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette",style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    @IBAction func save(_ sender: Any) {
         UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func applyProcessing() {
        
        //we check each of our four keys to see whether the current filter supports it, and, if so, we set the value
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey)
        { currentFilter.setValue(intensity.value, forKey:
            kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey)
        { currentFilter.setValue(intensity.value * 200, forKey:
            kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey)
        { currentFilter.setValue(intensity.value * 10, forKey:
            kCIInputScaleKey) }
        if inputKeys.contains(kCIInputCenterKey)
        { currentFilter.setValue(CIVector(x: currentImage.size.width /
            2, y: currentImage.size.height / 2), forKey:
            kCIInputCenterKey) }

        //creates a new data type and renders all of it:
        if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
            //creates a new UIImage from the CGImage
            let processedImage = UIImage(cgImage: cgimg)
            //assigns it to our imageview
            imageView.image = processedImage
        }
    }
    
    func setFilter(action: UIAlertAction) {
        //make sure we have a valid image before continuing
        guard currentImage != nil else {return}
        
        currentFilter = CIFilter(name: action.title!)
        let beginImage = CIImage(image: currentImage)
        //sets the intensity of the current filter
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error:
        Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            //we got back an error
            let ac = UIAlertController(title: "Save error", message:
                error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message:
                "Your altered image has been saved to your photos.",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)

        }
    }
    
    
}

