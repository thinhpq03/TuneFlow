//
//  MP3File.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 19/3/25.
//


import RealmSwift

class MP3File: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var title: String = ""
    @Persisted var artist: String = "Unknown"
    @Persisted var album: String? = nil
    @Persisted var localPath: String? = nil
    @Persisted var source: String = "Local"
    @Persisted var artworkURL: String? = nil
    @Persisted var dateAdded: Date = Date()
    @Persisted var appleMusicID: Int = 0

    override class func primaryKey() -> String? {
        return "id"
    }
}
