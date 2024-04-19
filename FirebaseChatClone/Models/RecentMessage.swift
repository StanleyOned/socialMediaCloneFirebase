//
//  RecentMessage.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 11/2/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct RecentMessage: Identifiable, Decodable, Equatable {
  @DocumentID var id: String?
  let email, profileImageURL: String
  let message, recipientID, senderID: String
  let timestamp: Date
  
  var username: String? {
    email.components(separatedBy: "@").first
  }
  
  var timeAgo: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    return formatter.localizedString(for: timestamp, relativeTo: Date())
  }
}
