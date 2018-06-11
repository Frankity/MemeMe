//
//  ViewController.swift
//  MemeMe
//
//  Created by CB on 21/05/18.
//  Copyright © 2018 Frankity. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var textFieldBotton: UITextField!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -4.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textFieldStyle(textField: textFieldTop, text: "TOP")
        self.textFieldStyle(textField: textFieldBotton, text: "BOTTOM")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldStyle(textField: UITextField, text: String){
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.textAlignment = .center
        textField.text = text
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clear(_ sender: Any){
        textFieldTop.text = "TOP"
        textFieldBotton.text = "BOTTOM"
        imagePickerView.image = nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .scaleAspectFit
            imagePickerView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func pickImage(sourceType: UIImagePickerControllerSourceType){
        let iPicker = UIImagePickerController()
        iPicker.sourceType = sourceType
        iPicker.delegate = self
        present(iPicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any){
       pickImage(sourceType: .photoLibrary)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any){
        pickImage(sourceType: .camera)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyBoardWillShow(_ notification: Notification){
        if textFieldBotton.isEditing != true{
            view.frame.origin.y = 0
        }else{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyBoardWillHide(_ notification: Notification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat{
            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func save() -> Meme {
        return Meme(topField: textFieldTop.text, bottomField: textFieldBotton.text, pickedImage: imagePickerView.image, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage{
        
        toolbar.isHidden = true
        navbar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolbar.isHidden = false
        navbar.isHidden = false
        
        return memedImage
    }
    
    @IBAction func shareClicked(_ sender: Any) {
        let myMeme =  generateMemedImage()
        let viewController = UIActivityViewController(activityItems: [myMeme], applicationActivities: nil)
        viewController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(viewController, animated: true, completion: nil)
    }
}

