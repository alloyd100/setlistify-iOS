//
//  AppleMusicManager.swift
//  Setlistify
//
//  Created by Andrew Lloyd on 02/11/2018.
//  Copyright © 2018 alloyd. All rights reserved.
//

import Foundation
import StoreKit
import MediaPlayer

struct AppleMusicManager {
    
    static var userToken = ""
    
    // Check if the device is capable of playback
    static func appleMusicCheckIfDeviceCanPlayback() {
        let serviceController = SKCloudServiceController()
        serviceController.requestCapabilities { (capability:SKCloudServiceCapability, err:Error?) in
            
            switch capability {
            case SKCloudServiceCapability.musicCatalogPlayback:
                
                print("The user has an Apple Music subscription and can playback music!")
                
            case SKCloudServiceCapability.addToCloudMusicLibrary:
                
                print("The user has an Apple Music subscription, can playback music AND can add to the Cloud Music Library")
                
            default:
                
                print("The user doesn't have an Apple Music subscription available. Now would be a good time to prompt them to buy one?")
                
            }
        }
    }
    
    static func appleMusicRequestPermission(completion: @escaping ((Bool) -> Void)) {
        
        SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
            
            switch status {
                
            case .authorized:
                self.getUserToken(completion: completion)
                
            case .denied:
                completion(false)
                print("The user tapped 'Don't allow'. Read on about that below...")
                
            case .notDetermined:
                print("The user hasn't decided or it's not clear whether they've confirmed or denied.")
                
            case .restricted:
                completion(false)
                print("User may be restricted; for example, if the device is in Education mode, it limits external Apple Music usage. This is similar behaviour to Denied.")
                
            }
        }
    }
    
    static func getUserToken(completion: @escaping ((Bool) -> Void)) {
        SKCloudServiceController().requestUserToken(forDeveloperToken: "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjhSWllZWjk5QlgifQ.eyJpc3MiOiJNTUVBUVU1UE5YIiwiaWF0IjoxNTQyNzMwNDc4LCJleHAiOjE1NDI3NzM2Nzh9.KDIQfRKQVfW6_NvbjDySG-Mwu7q5KBAk4JDpReh4oQ0bte8TWnvUTQc0OQLvKL-VZQnr22_YIZm4nKwLwulbkg") { (tokenResponse, error) in
            
            if let token = tokenResponse {
                print(token)
                self.userToken = token
                completion(true)
            }
            else {
                print(error?.localizedDescription ?? "Unknown error")
                completion(false)
            }
        }
    }
}
