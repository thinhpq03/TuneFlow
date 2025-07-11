//
//  Playlist.swift
//  TuneFlow
//
//  Created by Phạm Quý Thịnh on 21/3/25.
//


import RealmSwift

class Playlist: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var name: String = ""
    @Persisted var desc: String = ""
    @Persisted var imageData: Data? = nil
    @Persisted var musicIDs: List<String>
}
