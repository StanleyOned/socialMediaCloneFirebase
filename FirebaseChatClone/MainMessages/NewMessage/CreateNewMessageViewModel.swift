//
//  CreateNewMessageViewModel.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/27/23.
//

import SwiftUI

final class CreateNewMessageViewModel: ObservableObject {
  
  @Published var users = [User]()
  @Published var isLoading = false
  
  let service: FirebaseService
    
  init(service: FirebaseService) {
    self.service = service
  }
  
  @MainActor
  func fetchAllUsers() async {
    guard service.userUID != nil else {
      return
    }
    isLoading = true
    
    Task(priority: .background) {
      do {
        let users = try await service.getAllUsers()
        self.users = users ?? []
        isLoading = false
      } catch {
        print(error.localizedDescription)
        isLoading = false
      }
    }
  }
}
