//
//  Tour.swift
//  Setlistify
//
//  Created by Andrew Lloyd - Nodes on 01/12/2017.
//  Copyright © 2017 alloyd. All rights reserved.
//

import Serpent

struct Tour {
    var name = ""
}

extension Tour: Serializable {
    init(dictionary: NSDictionary?) {
        name <== (self, dictionary, "name")
    }
    
    func encodableRepresentation() -> NSCoding {
        let dict = NSMutableDictionary()
        (dict, "name") <== name
        return dict
    }
}
