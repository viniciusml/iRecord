//
//  Model.swift
//  AudioRecorder
//
//  Created by Vinicius Leal on 13/07/19.
//  Copyright © 2019 Vinicius Leal. All rights reserved.
//

import Foundation

class Audio: NSObject, NSCoding {
    var name: String
    var duration: String
    var url: URL
    var storedName: String

    init(name: String, duration: String, url: URL, storedName: String) {
        self.name = name
        self.duration = duration
        self.url = url
        self.storedName = storedName
    }

    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.duration = aDecoder.decodeObject(forKey: "duration") as! String
        self.url = aDecoder.decodeObject(forKey: "url") as! URL
        self.storedName = aDecoder.decodeObject(forKey: "storedName") as! String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(duration, forKey: "duration")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(storedName, forKey: "storedName")
    }
}

class AudiosStored {
    static let shared = AudiosStored()

    var audios = [Audio]()
}
