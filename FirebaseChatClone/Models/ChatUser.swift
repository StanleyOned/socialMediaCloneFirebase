//
//  User.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/25/23.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable, Hashable {
  
  @DocumentID var id: String?
  let uid: String
  let email: String
  let profileImageURL: String
  
  var username: String? {
    email.components(separatedBy: "@").first
  }
}
