//
//  detailsVC.swift
//  ArtBook
//
//  Created by Yusuf ÇAĞLAR on 07/10/2018.
//  Copyright © 2018 Yusuf ÇAĞLAR. All rights reserved.
//

import UIKit
import CoreData

class detailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    var chosenPainting = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let keyboardRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailsVC.hideKeyboard))
        self.view.addGestureRecognizer(keyboardRecognizer)
        
        if chosenPainting != "" {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.predicate = NSPredicate(format: "name = %@", self.chosenPainting)
            fetchRequest.returnsDistinctResults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        nameText.text = chosenPainting
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                    
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            self.imageView.image = image
                        }
                    }
                }
                
            } catch{
                
            }
        }
        
        
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(detailsVC.selectImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        print(chosenPainting)
        
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    
    }
    
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newArt = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
       
        newArt.setValue(artistText.text, forKey: "artist")
        newArt.setValue(nameText.text, forKey: "name")
        
        if let year = Int(yearText.text!) {
            
            newArt.setValue(year, forKey: "year")
            
        }
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newArt.setValue(data, forKey: "image")
        
        do {
            try context.save()
        } catch {
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPainting"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
