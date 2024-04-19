//
//  Status.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 11/5/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Status: Codable, Identifiable {
  
  @DocumentID var id: String?
  let uid: String
  let timestamp: Date
  let email: String
  let statusImageURL: String
  let expiredAt: Date
  var seenBy: [String]
  
  var username: String? {
    email.components(separatedBy: "@").first
  }
  
  mutating func addSeenBy(_ uid: String) {
    seenBy.append(uid)
  }
}
