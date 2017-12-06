//
//  SetlistSearchResponse.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 30/11/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import Serpent

struct SetlistSearchResponse {
    var type = ""
    var itemsPerPage = 0
    var page = 1
    var total = 0
    var setlist: [Setlist] = []
}

extension SetlistSearchResponse: Serializable {
    init(dictionary: NSDictionary?) {
        type         <== (self, dictionary, "type")
        itemsPerPage <== (self, dictionary, "itemsPerPage")
        page         <== (self, dictionary, "page")
        total        <== (self, dictionary, "total")
        setlist      <== (self, dictionary, "setlist")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "type")         <== type
        (dict, "itemsPerPage") <== itemsPerPage
        (dict, "page")         <== page
        (dict, "total")        <== total
        (dict, "setlist")      <== setlist
        return dict
    }
}
