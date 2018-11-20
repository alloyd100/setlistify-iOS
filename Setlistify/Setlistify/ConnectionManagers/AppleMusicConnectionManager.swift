//
//  AppleMusicConnectionManager.swift
//  Setlistify
//
//  Created by Andrew Lloyd on 06/11/2018.
//  Copyright © 2018 alloyd. All rights reserved.
//

import Alamofire
import Serpent
import Nodes
import Cider
import CloudKit

struct AppleMusicConnectionManager {
    
    static let baseURL: String = "https://api.music.apple.com/v1/"
    
    static var defaultHeaders: [String : String] {
        return [ "Authorization" : "Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjhSWllZWjk5QlgifQ.eyJpc3MiOiJNTUVBUVU1UE5YIiwiaWF0IjoxNTQxNjEwNzUwLCJleHAiOjE1NDE2NTM5NTB9.MW3HE48J0eq_CJZGdMWB-sZWjwzoBT1emp3LX7M-8cx1N3f1SpaTOMD-YZ3009IEoy5HODnyC_EMQ2sjZFsyzw",
                 "Music-User-Token" : AppleMusicManager.userToken
        ]
    }
    
    
    static func search(with artist: String, trackName: String, completion: @escaping ((DataResponse<SetlistSearchResponse>) -> Void)) {
        
        var query = baseURL + "search?term=\(artist)+\(trackName)"
        query = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        request(query, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: defaultHeaders).responseSerializable(completion)
    }
    
    static func getStoreFront( completion: @escaping ((DataResponse<SetlistSearchResponse>) -> Void)) {
        
        var query = baseURL + "me/storefront"
        query = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        request(query, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: defaultHeaders).responseSerializable(completion)
    }
    

    static func addPlaylist(name: String, completion: @escaping ((DataResponse<CreatePlaylistResponse>) -> Void)) {
        var attributes = PlaylistAttributes()
        attributes.name = name
        var params = CreatePlaylistRequest()
        params.attributes = attributes

        let query = baseURL + "me/library/playlists"
        request(query, method: .post, parameters: params.encodableRepresentation() as! [String: Any], encoding: JSONEncoding.default, headers: defaultHeaders).responseSerializable(completion)
    }
}


