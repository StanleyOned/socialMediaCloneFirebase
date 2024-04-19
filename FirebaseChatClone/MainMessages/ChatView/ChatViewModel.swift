//
//  ChatViewModel.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/29/23.
//

import Firebase
import Foundation
import SwiftUI
import FirebaseDatabase

final class ChatViewModel: ObservableObject {
  
  @Published var textfieldText = ""
  @Published var chatMessages = [Chat]()
  @Published var count = 0
  var chatImageTappedURL: String?
  
  var userUID: String {
    service.userUID ?? ""
  }
  
  private let service: FirebaseService
  private let recipientUser: User
  
  init(service: FirebaseService, recipientUser: User) {
    self.service = service
    self.recipientUser = recipientUser
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.getMessages()
    }
  }
  
  func onDisappear() {
    service.removeListener()
  }
  
  @MainActor
  func getMessages() {
    guard let senderUID = service.userUID else {
      return
    }
    service.listenToMessages(senderUID: senderUID,
                             recipientUserUID: recipientUser.uid) { result in
      switch result {
      case .success(let message):
        self.chatMessages.append(message)
        self.count += 1
      case .failure:
        print("dont care")
      }
    }
  }
  
  func sendMessage(messageImageURL: String? = nil) {
    Task {
      let result = await service.sendMessage(recipientUser: recipientUser,
                                             message: textfieldText)
      DispatchQueue.main.async {
        switch result {
        case .success:
          self.textfieldText = ""
          self.count += 1
        case .failure(let error):
          print(error.localizedDescription)
        }
      }
    }
  }
  
  func sendImageForChat(image: UIImage?) {
    guard let image else {
      return
    }
    Task {
      let result = await service.sendImage(recipientUser: recipientUser, image: image)
      
      DispatchQueue.main.async {
        switch result {
        case .success:
          print("Success")
          print("****")
          self.count += 1
        case .failure(let error):
          print(error.localizedDescription)
        }
      }
    }
  }
}
