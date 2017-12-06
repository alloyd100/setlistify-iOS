//
//  SpotifyConnectionManager.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 04/12/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import Alamofire
import Serpent
import Nodes


struct SpotifyConnectionManager {
    
    static var authToken = ""
    
    static func addSpotifyInfoToSetlist(setlist: Setlist, completion: @escaping (((Setlist) -> Void))) {
        
        var setlistWithSpotify = setlist
        getArtistFor(artistName: setlist.artist.name) { (artist) in
            setlistWithSpotify.artist.spotifyArtist = artist
            guard let _ = artist else {
                completion(setlist)
                return
            }
 
            var count = 0
            var completionSetCount = setlist.sets.songCount()

            if setlistWithSpotify.sets.setArray.count == 0 {
                completion(setlistWithSpotify)
                return
            }
            
            for setIndex in 0..<setlistWithSpotify.sets.setArray.count {
                
                let set = setlistWithSpotify.sets.setArray[setIndex]
                for songIndex in 0..<set.song.count {
                    
                    var song = set.song[songIndex]
                    if song.name.count > 0 {
                        
                        getTrackFor(artist: artist!, trackName: song.name, completion: { (spotifyTrack) in
                            
                            if spotifyTrack == nil && song.cover.name.count > 0 {
                                getArtistFor(artistName: song.cover.name, completion: { (response) in
                                    
                                    if let coverArtist = response {
                                        
                                        getTrackFor(artist: coverArtist, trackName: song.name, completion: { (coverTrack) in
                                            song.spotifyTrack = coverTrack
                                            setlistWithSpotify.sets.setArray[setIndex].song[songIndex] = song
                                            
                                            count = count + 1
                                            print(coverTrack?.name)
                                            ///if count == completionCount {
                                                completion(setlistWithSpotify)
                                            //}
                                            
                                        })
                                    }
                                    else {
                                        print("FAIL")
                                        count = count + 1
                                        //if count == completionCount {
                                            completion(setlistWithSpotify)
                                        //}
                                    }
                                })
                            }
                            else {
                                song.spotifyTrack = spotifyTrack
                                setlistWithSpotify.sets.setArray[setIndex].song[songIndex] = song
                                
                                print(spotifyTrack?.name)
                                count = count + 1
                                //if count == completionCount {
                                    completion(setlistWithSpotify)
                               // }
                            }
                        })
                    }
                }
            }
        }
    }
    
    static func getArtistFor(artistName: String, completion: @escaping (((SPTArtist?) -> Void))) {

        SPTSearch.perform(withQuery: artistName, queryType: .queryTypeArtist, accessToken: SpotifyConnectionManager.authToken, callback: { (error, listPage) in
            
            guard let listPage = listPage as? SPTListPage else {
                completion(nil)
                return
            }
            guard let artists = listPage.items as? [SPTPartialArtist] else {
                completion(nil)
                return
            }
            if artists.count > 0 {
                
                let firstPartialArtist = artists[0]
                SPTArtist.artist(withURI: firstPartialArtist.uri, accessToken: SpotifyConnectionManager.authToken, callback: { (error, response) in
                    
                    guard let artist = response as? SPTArtist else {
                        print("FAILED")
                        completion(nil)
                        return
                    }
                   
                    print("SUCCESS")
                    completion(artist)
                })
            }
        })
    }
    
    static func getTrackFor(artist: SPTArtist, trackName: String, completion: @escaping (((SPTTrack?) -> Void))) {
        
        SPTSearch.perform(withQuery: trackName + " " + artist.name, queryType: .queryTypeTrack, accessToken: SpotifyConnectionManager.authToken, callback: { (error, listPage) in
            
            guard let listPage = listPage as? SPTListPage else {
                completion(nil)
                return
            }
            guard let partialTracks = listPage.items as? [SPTPartialTrack] else {
                completion(nil)
                return
            }
            if partialTracks.count > 0 {
                
                var correctArtistsPartialTracks:[SPTPartialTrack] = []
                for trk in partialTracks {
                    for trackArtist in (trk.artists as! [SPTPartialArtist]) {
                        if trackArtist.identifier == artist.identifier {
                            correctArtistsPartialTracks.append(trk)
                        }
                    }
                }
                
                if correctArtistsPartialTracks.count > 0 {
                    
                    var exactMatchTracks: [SPTPartialTrack] = []
                    for trk in correctArtistsPartialTracks {
                        if trk.name.lowercased().contains(trackName.lowercased()) {
                            exactMatchTracks.append(trk)
                        }
                    }
                    
                    //use first object if no names match exactly
                    var track = correctArtistsPartialTracks[0]
                    if exactMatchTracks.count > 0 {
                        track = exactMatchTracks[0]
                    }
                    SPTTrack.track(withURI: track.uri, accessToken: SpotifyConnectionManager.authToken, market: nil, callback: { (error, response) in
                        
                        guard let track = response as? SPTTrack else {
                            print("FAILED")
                            completion(nil)
                            return
                        }
                        
                        print("SUCCESS")
                        completion(track)
                    })
                    
                }
                else {
                    //use first partial track, no artists seem to relate
                    let track = partialTracks[0]
                    SPTTrack.track(withURI: track.uri, accessToken: SpotifyConnectionManager.authToken, market: nil, callback: { (error, response) in
                        
                        guard let track = response as? SPTTrack else {
                            print("FAILED")
                            completion(nil)
                            return
                        }
                        
                        print("SUCCESS")
                        completion(track)
                    })
                }
            }
            else {
                completion(nil)
            }
        })
    }
    
    static func makePlaylistFor(setlist: Setlist, completion: @escaping (((Bool) -> Void))) {
        
        SPTUser.requestCurrentUser(withAccessToken: SpotifyConnectionManager.authToken) { (error, response) in
            if let user = response as? SPTUser {
                
                SPTPlaylistList.createPlaylist(withName: "\(setlist.artist.name) at \(setlist.venue.venueFullName()). \(Date.presentableDateFromDate(eventDate: setlist.eventDate))", forUser: user.canonicalUserName, publicFlag: true, accessToken: SpotifyConnectionManager.authToken) { (error, response) in

                    if let playlist = response as? SPTPlaylistSnapshot {
                
                        playlist.addTracks(toPlaylist: setlist.sets.fullSongSpotifyIds(), withAccessToken: SpotifyConnectionManager.authToken, callback: { (error) in
                            
                            if error == nil {
                                completion(true)
                                print("SUCCESS")
                            }
                        })
                    }
                }
            }
            else {
                completion(false)
            }
        }
    }
    
    static func logInToPlayer(setlistVC: SetlistViewController) {
        setlistVC.player = SPTAudioStreamingController.sharedInstance()
        setlistVC.player?.delegate = setlistVC
        setlistVC.player?.playbackDelegate = setlistVC
        do {
            try setlistVC.player?.start(withClientId: "75de10a1a38b4feaa8ea4a941bb7362f")
        }
        catch {
            print("whoops")
        }
        setlistVC.player?.login(withAccessToken: self.authToken)
    }
}
