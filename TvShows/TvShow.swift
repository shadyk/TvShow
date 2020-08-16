//
//  TvShow.swift
//  TvShows
//
//  Created by Shady Kahaleh on 7/26/20.
//

import Foundation

public enum Genre {
    case comedy, action
}

public struct TvShow : Equatable{
    var id : UUID
    var name: String
    var language: String
    var genres : [String]?
    var status : String
    var message : String?
    var code : Int?

    public init(id : UUID,name: String, language: String, status: String, genres : [String]? = nil){
        self.id = id
        self.name = name
        self.language = language
        self.status = status
        self.genres = genres
    }
}

extension TvShow : Decodable{
    private enum CodingKeys : String, CodingKey{
        case id
        case name
        case status
        case language
        case genres
        case message
        case code
    }
}



public struct ErrorObject : Decodable{
    var status : Int
    var message : String
    var code : Int
    var name : String
}





