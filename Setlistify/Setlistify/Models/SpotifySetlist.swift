//
//  SpotifySetlist.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 04/12/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import Serpent

struct SpotifySetlist {
    var artist: SPTArtist?
    var sets: [SpotifySets] = []
}

struct SpotifySets {
    var tracks: [SPTTrack] = []
}
