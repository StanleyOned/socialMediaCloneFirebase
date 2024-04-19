//
//  Message.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/29/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Chat: Codable, Identifiable {
  
  @DocumentID var id: String?
  let senderID: String
  let recipientID: String
  let message: String?
  let messageType: MessageType?
  let messageImageURL: String?
  let timestamp: Date
  let email: String
  let profileImageURL: String
  
  enum MessageType: String, Codable {
    case text, image
  }
}
