//
//  ViewController.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 28/11/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import UIKit
import SpotifyLogin
import KeyboardHelper
import Spinner
import Alamofire


class SearchViewController: UIViewController, KeyboardHelperDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var logoIV: UIImageView!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var venueTextField: UITextField!
    @IBOutlet weak var userTextfield: UITextField!
    
    @IBOutlet weak var spotifyLoginContainer: UIView!
    
    @IBOutlet weak var appleMusicContainer: UIView! {
        didSet {
            appleMusicContainer.makeViewCircle()
        }
    }
    @IBOutlet weak var appleMusicLabel: UILabel!
    @IBOutlet weak var appleMusicButton: UIButton!
    
    var keyboardHelper: KeyboardHelper!

    var loginButton: UIButton?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        keyboardHelper = KeyboardHelper(delegate: self)
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if error != nil, token == nil {
                self?.showLoginButton()
            }
            else {
                SpotifyConnectionManager.authToken = token ?? ""
                self?.showLoginButton()
                self?.loginSuccessful()
            }
        }
        
        artistTextField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        venueTextField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
        userTextfield.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.viewTapped))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.isEnabled = true
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        searchButton.roundCorners(.allCorners, radius: 20)
        self.view.sendSubview(toBack: self.backgroundImageView)
    }
    
    
    
    func showLoginButton() {
        //self.performSegue(withIdentifier: "home_to_login", sender: self)
        let button = SpotifyLoginButton(viewController: self,
                                        scopes: [.streaming,
                                                 .userReadTop,
                                                 .playlistReadPrivate,
                                                 .userLibraryRead,
                                                 .playlistModifyPublic,
                                                 .playlistModifyPrivate,
                                                 .userModifyPlaybackState,
                                                ])
        self.spotifyLoginContainer.addSubview(button)
        button.center = CGPoint(x: self.spotifyLoginContainer.bounds.size.width / 2, y: self.spotifyLoginContainer.bounds.size.height / 2)
        self.loginButton = button
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginSuccessful),
                                               name: .SpotifyLoginSuccessful,
                                               object: nil)
    }
    
    @objc func loginSuccessful() {
        
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if token != nil {
                SpotifyConnectionManager.authToken = token ?? ""
            }
        }
        
        self.loginButton?.setTitle("Activated Spotify", for: .normal)
        self.loginButton?.isEnabled = false
        print("Login Succesful")
    }
    
    @objc func viewTapped() {
        resignAll()
    }
    
    func resignAll() {
        self.view.endEditing(true)
    }
    
    //MARK: Actions
    @IBAction func searchPressed(_ sender: Any) {
        search()
    }
    
    @IBAction func activateAppleMusic(_ sender: Any) {
        AppleMusicManager.appleMusicRequestPermission { (success) in
            if success {
                self.appleMusicLabel.text = "Apple Music Activated"
                self.appleMusicButton.isEnabled = false
            }
            else {
                let myalert = UIAlertController(title: "Sorry", message: "We couldn't connect to your Apple Music account. Please check you have a valid subscription.", preferredStyle: UIAlertControllerStyle.alert)
                myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Selected")
                })
                self.present(myalert, animated: true)
            }
        }
    }
    
    func search() {
        let spinner = SpinnerView.showSpinner(inButton: self.searchButton)
        
        if userTextfield.text?.count ?? 0 > 0 {
            
            if artistTextField?.text?.count ?? 0 > 0 || venueTextField?.text?.count ?? 0 > 0 {
                
                let myalert = UIAlertController(title: "Sorry", message: "We cant search by Setlist.fm users and Artists/Venues at the same time. Please only fill in one search type.", preferredStyle: UIAlertControllerStyle.alert)
                myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Selected")
                })
                self.present(myalert, animated: true)
                return
            }
            
            //users setlists
            SetlistConnectionManager.getUsersSetlists(with: userTextfield.text ?? "", pageNumber: 1) { (response) in
                
                spinner.dismiss()
                switch response.result {
                case .success(let data):
                    print(data.itemsPerPage)
                    
                    if data.total > 0 {
                        self.title = ""
                        
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetlistResultsViewController") as! SetlistResultsViewController
                        vc.dataSource = data
                        vc.userSearch = self.userTextfield.text ?? ""
                        
                        vc.title = self.artistTextField.text ?? "Results"
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                case .failure:
                    
                    let myalert = UIAlertController(title: "Sorry", message: "We couldn't find any setlists for that user.", preferredStyle: UIAlertControllerStyle.alert)
                    myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        print("Selected")
                    })
                    self.present(myalert, animated: true)
                }
            }
        }
        else {
            //search setlists
            SetlistConnectionManager.search(with: artistTextField.text ?? "", venue: venueTextField.text ?? "", pageNumber: 1) { (response) in
                
                spinner.dismiss()
                switch response.result {
                case .success(let data):
                    print(data.itemsPerPage)
                    
                    if data.total > 0 {
                        self.title = ""
                        
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetlistResultsViewController") as! SetlistResultsViewController
                        vc.dataSource = data
                        vc.artistSearch = self.artistTextField.text ?? ""
                        vc.venueSearch = self.venueTextField.text ?? ""
                        
                        vc.title = self.artistTextField.text ?? "Results"
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                case .failure:
                    
                    let myalert = UIAlertController(title: "Sorry", message: "We couldn't find any setlists.", preferredStyle: UIAlertControllerStyle.alert)
                    myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        print("Selected")
                    })
                    self.present(myalert, animated: true)
                }
            }
        }
    }
    
    //MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            if view.isKind(of: UITextField.self) || view.isKind(of: UIButton.self) {
                return false
            }
        }
        
        return true
    }
    
    func disableUserTextfield() {
        userTextfield.backgroundColor = UIColor.setlistifyCreamDisabled
        userTextfield.isEnabled = false
    }
    
    func disableArtistAndVenueTextfield() {
        artistTextField.backgroundColor = UIColor.setlistifyCreamDisabled
        artistTextField.isEnabled = false
        venueTextField.backgroundColor = UIColor.setlistifyCreamDisabled
        venueTextField.isEnabled = false
    }
    
    func enableAllTextFields() {
        userTextfield.backgroundColor = UIColor.white
        userTextfield.isEnabled = true
        artistTextField.backgroundColor = UIColor.white
        artistTextField.isEnabled = true
        venueTextField.backgroundColor = UIColor.white
        venueTextField.isEnabled = true
    }
    
    //MARK: NOKeyboardHandlerDelegate
    
    func keyboardWillAppear(_ info: KeyboardAppearanceInfo) {
        logoHeight.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.logoIV.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillDisappear(_ info: KeyboardAppearanceInfo) {
        logoHeight.constant = 91
        UIView.animate(withDuration: 0.2) {
            self.logoIV.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: UITextFieldDelegate
    
    @objc func textFieldDidChange(textField : UITextField){
        
        if textField == artistTextField || textField == venueTextField {
            if textField.text?.count ?? 0 > 0 {
                //artist/venue entered
                disableUserTextfield()
            }
            else {
                enableAllTextFields()
            }
        }
        else {
            //user textfield
            if textField.text?.count ?? 0 > 0 {
                //artist/venue entered
                disableArtistAndVenueTextfield()
            }
            else {
                enableAllTextFields()
            }
        }

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == artistTextField {
            venueTextField.becomeFirstResponder()
        }
        else {
            search()
        }
        
        return true
    }

}

