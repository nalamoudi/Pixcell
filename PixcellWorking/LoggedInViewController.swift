//
//  LoggedInViewController.swift
//  PixcellWorking
//
//  Created by Muaawia Janoudy on 2018-10-17.
//  Copyright © 2018 Pixcell Inc. All rights reserved.
//

//This controller is what the user sees after logging in and/or finishing picking their photos

import UIKit
import Firebase

class LoggedInViewController: UIViewController {
    
    var RemainingimagesCounter: Int?
    
    // Creating Firebase Reference for Read/Write Operations
    let ref = Database.database().reference(fromURL: "https://pixcell-working.firebaseio.com/")
    let uid = Auth.auth().currentUser!.uid

    @IBOutlet var firstAlbumRemaingingImageCounter: UILabel!
    @IBOutlet var firstAlbumObject: UIView!
    @IBOutlet var firstAlbumStatusLabel: UILabel!
    @IBOutlet var firstAlbumNameLabel: UILabel!
    @IBOutlet var firstAlbumCheckoutNotification: UILabel!
    @IBOutlet var secondAlbumObject: UIView!
    @IBOutlet var secondAlbumStatusLabel: UILabel!
    @IBOutlet var secondAlbumNameLabel: UILabel!
    @IBOutlet var secondAlbumRemainingImageCounter: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        firstAlbumObject.isHidden = true
        secondAlbumObject.isHidden = true
        firstAlbumObject.layer.cornerRadius = 10
        secondAlbumObject.layer.cornerRadius = 10
        firstAlbumNameLabel.text = "\(Date().getMonthName())"
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.RemainingimagesCounter = value?["Remaining Photos"] as? Int ?? 0
            if self.RemainingimagesCounter! < 50 {
                self.firstAlbumObject.isHidden = false
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //reading from Firebase to get the Remaining Photos
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.RemainingimagesCounter = value?["Remaining Photos"] as? Int ?? 0
            if self.RemainingimagesCounter! <= 50 && self.RemainingimagesCounter! > 0 {
                self.firstAlbumRemaingingImageCounter.text = "\(50-self.RemainingimagesCounter!)/50"
                self.firstAlbumObject.isHidden = false
                self.firstAlbumStatusLabel.text = "Selecting Images"
            } else if self.RemainingimagesCounter! == 0 {
                self.firstAlbumRemaingingImageCounter.text = "\(50-self.RemainingimagesCounter!)/50"
                self.firstAlbumStatusLabel.text = "Ready to Submit"
                self.firstAlbumCheckoutNotification.text = "Click anywhere to Checkout"
                self.firstAlbumObject.isHidden = false
            }
        })

    }
    
    //display an error message as a UIAlertController
    func displayErrorMessage(message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action: UIAlertAction) in }
        alertView.addAction(okAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    //loads the main login page - ViewController
    func loadLoginScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(viewController, animated: true, completion: nil)
    }
    
    //Logout IBAction to sign the user out. The Auth.auth() method is part of the Firebase pod.
    
    @IBAction func logOut(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            loadLoginScreen()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func SelectImagesorCheckoutClicked(_ sender: Any) {
        if firstAlbumStatusLabel.text == "Ready to Submit" {
            performSegue(withIdentifier: "CheckoutSegue", sender: UIButton.self)
        } else {
            performSegue(withIdentifier: "PickImagesSegue", sender: UIButton.self)
        }
    }
    
    @IBAction func addAlbumButtonPressed(_ sender: Any) {
        if firstAlbumObject.isHidden {
            firstAlbumObject.isHidden = false
        } else if !firstAlbumObject.isHidden {
            let nameSelectionAlert = UIAlertController(title: "Pick a name for your extra Album", message: nil, preferredStyle: .alert)
            nameSelectionAlert.addTextField { (textField) in
                textField.placeholder = "Enter Album Name Here"
                textField.enablesReturnKeyAutomatically = true
            }
            nameSelectionAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
                guard let name = nameSelectionAlert.textFields![0].text else {
                    return
                }
                self.secondAlbumNameLabel.text = name
                self.secondAlbumObject.isHidden = false
            }))
            present(nameSelectionAlert, animated: true)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let imagesRemaining = RemainingimagesCounter else {return}
        if segue.identifier == "PickImagesSegue" && imagesRemaining < 50 {
            if let dest = segue.destination as? CustomAssetCellController {
                dest.imagesRemaining = imagesRemaining
            }
        }
    }
    
}
