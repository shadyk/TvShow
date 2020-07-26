//
//  TvShow.swift
//  TvShows
//
//  Created by Shady Kahaleh on 7/26/20.
//

import Foundation

enum Genre{
    case comedy, action
}

struct TvShow{
    var id : UUID
    var name: String
    var language: String
    var genres : [Genre]
}
