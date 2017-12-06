//
//  Artist.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 30/11/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import Serpent

struct Artist {
    var mbid = ""
    var tmid = 0
    var name = ""
    var sortName = ""
    var disambiguation = ""
    var url = ""
    
    var spotifyArtist: SPTArtist?
}

extension Artist: Serializable {
    init(dictionary: NSDictionary?) {
        mbid           <== (self, dictionary, "mbid")
        tmid           <== (self, dictionary, "tmid")
        name           <== (self, dictionary, "name")
        sortName       <== (self, dictionary, "sortName")
        disambiguation <== (self, dictionary, "disambiguation")
        url            <== (self, dictionary, "url")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "mbid")           <== mbid
        (dict, "tmid")           <== tmid
        (dict, "name")           <== name
        (dict, "sortName")       <== sortName
        (dict, "disambiguation") <== disambiguation
        (dict, "url")            <== url
        return dict
    }
}
