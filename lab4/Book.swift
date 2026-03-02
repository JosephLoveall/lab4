//
//  Book.swift
//  lab4
//
//  Created by Joseph Loveall (Student) on 3/2/26.
//

import Foundation

struct Book: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var author: String
    var genre: String
    var price: Double
}
