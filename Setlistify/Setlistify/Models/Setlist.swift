//
//  Setlist.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 30/11/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import Serpent

struct Setlist {
    var artist: Artist = Artist()
    var venue: Venue = Venue()
    var tour = ""
    var sets: SetsWrapper = SetsWrapper()
    var info = ""
    var url = ""
    var id = ""
    var versionId = ""
    var eventDate = ""
    var lastUpdated = ""
}

extension Setlist: Serializable {
    init(dictionary: NSDictionary?) {
        artist      <== (self, dictionary, "artist")
        venue       <== (self, dictionary, "venue")
        tour        <== (self, dictionary, "tour")
        sets        <== (self, dictionary, "sets")
        info        <== (self, dictionary, "info")
        url         <== (self, dictionary, "url")
        id          <== (self, dictionary, "id")
        versionId   <== (self, dictionary, "versionId")
        eventDate   <== (self, dictionary, "eventDate")
        lastUpdated <== (self, dictionary, "lastUpdated")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "artist")      <== artist
        (dict, "venue")       <== venue
        (dict, "tour")        <== tour
        (dict, "sets")        <== sets
        (dict, "info")        <== info
        (dict, "url")         <== url
        (dict, "id")          <== id
        (dict, "versionId")   <== versionId
        (dict, "eventDate")   <== eventDate
        (dict, "lastUpdated") <== lastUpdated
        return dict
    }
}

extension Setlist {
    func setlistPlaylistName() -> String {
        return "\(self.artist.name) at "
    }
}

struct SetsWrapper {
    var setArray: [GigSet] = []
}
extension SetsWrapper: Serializable {
    init(dictionary: NSDictionary?) {
        setArray <== (self, dictionary, "set")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "set") <== setArray
        return dict
    }
}

extension SetsWrapper {

    func songCount() -> Int {
        var count = 0
        for set in setArray {
            for song in set.song {
                if song.name.count > 0 {
                    count = count + 1
                }
            }
        }
        return count
    }
    
    func fullSongSpotifyIds() -> [SPTTrack] {
        var result: [SPTTrack] = []
        for set in self.setArray {
            for song in set.song {
                if let sTrack = song.spotifyTrack {
                    result.append(sTrack)
                }
            }
        }
        
        return result
    }
}
