//
//  CreatePlaylistRequest.swift
//  Setlistify
//
//  Created by Andrew Lloyd on 06/11/2018.
//  Copyright © 2018 alloyd. All rights reserved.
//

import Foundation
import Serpent

struct CreatePlaylistRequest {
    var attributes: PlaylistAttributes = PlaylistAttributes()
}

extension CreatePlaylistRequest: Serializable {
    init(dictionary: NSDictionary?) {
        attributes <== (self, dictionary, "attributes")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "attributes") <== attributes
        return dict
    }
}

struct PlaylistAttributes {
    var name = ""
    var description = ""
}

extension PlaylistAttributes: Serializable {
    init(dictionary: NSDictionary?) {
        name        <== (self, dictionary, "name")
        description <== (self, dictionary, "description")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "name")        <== name
        (dict, "description") <== description
        return dict
    }
}
