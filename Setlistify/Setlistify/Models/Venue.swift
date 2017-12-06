//
//  Venue.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 01/12/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import Serpent

struct Venue {
    var city: City = City()
    var id = ""
    var name = ""
    var url = ""
}
extension Venue: Serializable {
    init(dictionary: NSDictionary?) {
        city <== (self, dictionary, "city")
        id   <== (self, dictionary, "id")
        name <== (self, dictionary, "name")
        url  <== (self, dictionary, "url")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "city") <== city
        (dict, "id")   <== id
        (dict, "name") <== name
        (dict, "url")  <== url
        return dict
    }
    
    func venueFullName() -> String {
        return "\(self.name), \(self.city.name), \(self.city.country.code)"
    }
}

//Mark: SubStructs

struct City {
    var id = ""
    var name = ""
    var stateCode = ""
    var state = ""
    var country: Country = Country()
    var coords: Coords = Coords()
}
extension City: Serializable {
    init(dictionary: NSDictionary?) {
        id        <== (self, dictionary, "id")
        name      <== (self, dictionary, "name")
        stateCode <== (self, dictionary, "stateCode")
        state     <== (self, dictionary, "state")
        country   <== (self, dictionary, "country")
        coords    <== (self, dictionary, "coords")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "id")        <== id
        (dict, "name")      <== name
        (dict, "stateCode") <== stateCode
        (dict, "state")     <== state
        (dict, "country")   <== country
        (dict, "coords")    <== coords
        return dict
    }
}

struct Country {
    var code = ""
    var name = ""
}
extension Country: Serializable {
    init(dictionary: NSDictionary?) {
        code <== (self, dictionary, "code")
        name <== (self, dictionary, "name")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "code") <== code
        (dict, "name") <== name
        return dict
    }
}

struct Coords {
    var long = 0.0
    var lat = 0.0
}
extension Coords: Serializable {
    init(dictionary: NSDictionary?) {
        long <== (self, dictionary, "long")
        lat  <== (self, dictionary, "lat")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "long") <== long
        (dict, "lat")  <== lat
        return dict
    }
}
