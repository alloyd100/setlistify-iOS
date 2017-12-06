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
import  Alamofire


class SearchViewController: UIViewController, KeyboardHelperDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var logoIV: UIImageView!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var venueTextField: UITextField!
    
    @IBOutlet weak var spotifyLoginContainer: UIView!
    
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
        
        self.loginButton?.setTitle("Logged In", for: .normal)
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
    
    func search() {
        let spinner = SpinnerView.showSpinner(inButton: self.searchButton)
        
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
    
    //MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            if view.isKind(of: UITextField.self) || view.isKind(of: UIButton.self) {
                return false
            }
        }
        
        return true
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

