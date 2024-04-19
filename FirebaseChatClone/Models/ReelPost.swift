//
//  ReelPost.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 4/9/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ReelPost: Identifiable, Codable {
  @DocumentID var id: String?
  let uid: String
  let timestamp: Date
  let videoUrl: String
  private let email: String
  
  var username: String? {
    email.components(separatedBy: "@").first
  }
  
  init(id: String? = nil, 
       uid: String,
       timestamp: Date,
       videoUrl: String,
       email: String) {
    self.id = id
    self.uid = uid
    self.timestamp = timestamp
    self.videoUrl = videoUrl
    self.email = email
  }
}
