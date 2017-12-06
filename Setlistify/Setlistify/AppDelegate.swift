//
//  AppDelegate.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 28/11/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import UIKit
import SpotifyLogin
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sptConnectionManager = SpotifyConnectionManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let redirectURL: URL = URL(string: "setlistify://callback")!
        SpotifyLogin.shared.configure(clientID: "75de10a1a38b4feaa8ea4a941bb7362f",
                                      clientSecret: "4f3feefe0d6944a9a908ba993a67bc75",
                                      redirectURL: redirectURL)

        UINavigationBar.appearance().tintColor = UIColor.setlistifyBlack
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            //print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                //print("AVAudioSession is Active")
            } catch _ as NSError {
                //print(error.localizedDescription)
            }
        } catch _ as NSError {
            //print(error.localizedDescription)
        }
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        let handled = SpotifyLogin.shared.applicationOpenURL(url) { _ in }
        return handled
    }
}

