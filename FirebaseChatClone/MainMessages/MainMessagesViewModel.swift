//
//  MainMessagesViewModel.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/25/23.
//

import SwiftUI

final class MainMessagesViewModel: ObservableObject {
  
  @Published var user: User?
  @Published var isUserLoggedOut = false
  @Published var recentMessages = [RecentMessage]()
  @Published var userSelected: User?
  @Published var pushChatScreen = false
  
  let service: FirebaseService
    
  init(service: FirebaseService) {
    self.service = service
    isUserLoggedOut = service.userUID == nil
    self.recentMessages.removeAll()
  }
  
  func onAppear() {
    userSelected = nil
    pushChatScreen = false
  }
  
  @MainActor
  func fetchCurrentUser() async {
    guard service.userUID != nil else {
      recentMessages.removeAll()
      isUserLoggedOut = true
      return
    }
    Task {
      let result = await service.getCurrentUser()
      switch result {
      case .success(let user):
        self.user = user
        fetchRecentMessages()
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
  }
  
  func fetchRecentMessages() {
    service.listenToRecentMessage { result in
      switch result {
      case .success(let message):
        DispatchQueue.main.async {
          if let index = self.recentMessages.firstIndex(where: { rm in
            rm.id == message.id
          }) {
            self.recentMessages.remove(at: index)
          }
          self.recentMessages.insert(message, at: 0)
        }
      default: break
      }
    }
  }
  
  func handleMessageTapped(_ message: RecentMessage) {
    Task {
      let uid = message.recipientID == user?.uid ? message.senderID : message.recipientID
      let userSelected = await service.getUser(with: uid)
      DispatchQueue.main.async {
        self.userSelected = userSelected
        self.pushChatScreen = true
      }
    }
  }
  
  func handleLongPress(_ message: RecentMessage) {
    Task {
      let success = await service.deleteRecentMessage(message)
      
      if success {
        DispatchQueue.main.async {
          self.recentMessages.removeAll { messageToCheck in
            messageToCheck == message
          }
        }
      }
    }
  }
  
  func handleSignOut() {
    recentMessages.removeAll()
    service.signOut()
    user = nil
    DispatchQueue.main.async {
      self.isUserLoggedOut = true
    }
  }
}
