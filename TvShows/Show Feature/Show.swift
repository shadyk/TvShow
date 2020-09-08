//
//  TvShow.swift
//  TvShows
//
//  Created by Shady Kahaleh on 7/26/20.
//

import Foundation

//public enum Genre {
//    case comedy, action
//}

public struct Show : Equatable{
    var id : String
    var name: String
    var language: String
    var genres : [String]?
    var status : String

    public init(id : String,name: String, language: String, status: String, genres : [String]? = nil){
        self.id = id
        self.name = name
        self.language = language
        self.status = status
        self.genres = genres
    }
}








