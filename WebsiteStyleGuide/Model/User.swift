//
//  User.swift
//  WebsiteStyleGuide
//
//  Created by Pavel Shabliy on 04.11.2024.
//

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let phone: String
    let position: String
    let photo: String
}

struct UsersResponse: Codable {
    let success: Bool
    let users: [User]
}
