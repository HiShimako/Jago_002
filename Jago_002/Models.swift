//
//  Models.swift
//  Jago_002
//
//  Created by user on 2023/09/27.
//
import Foundation
import RealmSwift


class Person: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var personName: String?
    @objc dynamic var smallImage: Data?
    @objc dynamic var bigImage: Data?
    @objc dynamic var backgroundViewIndex: Int = 0
    let comments = List<Comment>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Comment: Object {
    @objc dynamic var time: String = ""
    @objc dynamic var commentText: String = ""
}
