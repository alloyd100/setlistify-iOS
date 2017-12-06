//
//  SetlistConnectionManager.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 28/11/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import Alamofire
import Serpent
import Nodes

struct SetlistConnectionManager {
    
    static let baseURL: String = "https://api.setlist.fm/rest/"

    static var defaultHeaders: [String : String] {
        return ["x-api-key" : "2eaf32bc-3235-4044-b8a7-3a6d2176ebd8",
                "Accept" : "application/json",
                "Accept-Language" : "en",
                "Accept-Encoding" : "gzip"
        ]
    }
    
    static func search(with artist: String, venue: String, pageNumber: Int, completion: @escaping ((DataResponse<SetlistSearchResponse>) -> Void)) {

        var query = baseURL + "1.0/search/setlists?artistName=\(artist)&p=\(pageNumber)"
        
        if venue.count > 0 {
            query = query + "&venueName=\(venue)"
        }
        query = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        request(query, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: defaultHeaders).responseSerializable(completion)
    }
    
    static func searchSimilarSets(with venue: Venue, date:String, pageNumber: Int, completion: @escaping ((DataResponse<SetlistSearchResponse>) -> Void)) {
        
        var query = baseURL + "1.0/search/setlists?venueId=\(venue.id)&date=\(date)&p=\(pageNumber)"
        
        query = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        request(query, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: defaultHeaders).responseSerializable(completion)
    }
 
}

