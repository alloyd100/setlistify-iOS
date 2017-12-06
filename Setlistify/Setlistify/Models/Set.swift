//
//  Set.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 01/12/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import Serpent

struct GigSet {
    var name = ""
    var encore = 0
    var song: [Song] = []
}
extension GigSet: Serializable {
    init(dictionary: NSDictionary?) {
        name   <== (self, dictionary, "name")
        encore <== (self, dictionary, "encore")
        song   <== (self, dictionary, "song")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "name")   <== name
        (dict, "encore") <== encore
        (dict, "song")   <== song
        return dict
    }
}

struct Song {
    var name = ""
    var with:Artist = Artist()
    var cover: Artist = Artist()
    var info = ""
    var tape = false
    
    var spotifyTrack: SPTTrack?
}
extension Song: Serializable {
    init(dictionary: NSDictionary?) {
        name  <== (self, dictionary, "name")
        with  <== (self, dictionary, "with")
        cover <== (self, dictionary, "cover")
        info  <== (self, dictionary, "info")
        tape  <== (self, dictionary, "tape")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "name")  <== name
        (dict, "with")  <== with
        (dict, "cover") <== cover
        (dict, "info")  <== info
        (dict, "tape")  <== tape
        return dict
    }
    
    func fullInfo() -> String {
        var result = ""

        if tape {
            result = result + "Tape "
        }
        if cover.name.count > 0 {
            if tape {
                result = result + "(\(cover.name) song)"
            }
            else {
                result = result + "(\(cover.name) cover)"
            }
        }
        if with.name.count > 0 {
            if result.count > 0 && !result.starts(with: "Tape") {
                result = result + ", "
            }
            result = result + "(With \(with.name))"
        }
        if info.count > 0 {
            if result.count > 0 && !result.starts(with: "Tape") {
                result = result + ", "
            }
            result = result + "(\(info))"
        }
        
        return result
    }
}
