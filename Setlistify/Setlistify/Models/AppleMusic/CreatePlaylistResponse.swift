//
//  CreatePlaylistResponse.swift
//  Setlistify
//
//  Created by Andrew Lloyd on 06/11/2018.
//  Copyright © 2018 alloyd. All rights reserved.
//

import Foundation
import Serpent

struct CreatePlaylistResponse {
    var data: Playlist = Playlist()
}

extension CreatePlaylistResponse: Serializable {
    init(dictionary: NSDictionary?) {
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        return dict
    }
}

struct Playlist {
    var attributes: PlaylistResponseAttributes = PlaylistResponseAttributes()
    var id = ""
    var type = ""
    var href = ""
}

extension Playlist: Serializable {
    init(dictionary: NSDictionary?) {
        attributes <== (self, dictionary, "attributes")
        id         <== (self, dictionary, "id")
        type       <== (self, dictionary, "type")
        href       <== (self, dictionary, "href")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "attributes") <== attributes
        (dict, "id")         <== id
        (dict, "type")       <== type
        (dict, "href")       <== href
        return dict
    }
}

struct PlaylistResponseAttributes {
    var name = ""
    var canEdit = false
    var description:Description = Description()
    var artwork:Artwork = Artwork()
    var playParams:PlayParams = PlayParams()
}

struct PlayParams {
    var id = ""
    var kind = ""
    var isLibrary = false
}

extension PlayParams: Serializable {
    init(dictionary: NSDictionary?) {
        id        <== (self, dictionary, "id")
        kind      <== (self, dictionary, "kind")
        isLibrary <== (self, dictionary, "isLibrary")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "id")        <== id
        (dict, "kind")      <== kind
        (dict, "isLibrary") <== isLibrary
        return dict
    }
}

struct Artwork {
    var width = 0
    var height = 0
    var url = ""
}

extension Artwork: Serializable {
    init(dictionary: NSDictionary?) {
        width  <== (self, dictionary, "width")
        height <== (self, dictionary, "height")
        url    <== (self, dictionary, "url")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "width")  <== width
        (dict, "height") <== height
        (dict, "url")    <== url
        return dict
    }
}

struct Description {
    var standard = ""
}

extension Description: Serializable {
    init(dictionary: NSDictionary?) {
        standard <== (self, dictionary, "standard")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "standard") <== standard
        return dict
    }
}
