//
//  Course.swift
//  Networking
//
//  Created by Valera Vasilevich on 2.08.21.
//

import Foundation

struct Course: Decodable {
    
    let id:Int?
    let name: String?
    let link: String?
    let imageUrl: String?
    let numberOfLessons: Int?
    let numberOfTests: Int?
    
}
