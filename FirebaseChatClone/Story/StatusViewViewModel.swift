//
//  StatusViewViewModel.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 11/6/23.
//

import SwiftUI

final class StatusViewViewModel: ObservableObject {
  
  @Published var allStatus: [Status]?
  @Published var seenStatus: [Status]?
  @Published var myStatus: Status?
  @Published var isLoading = true
  
  var selectedStatus: Status?
  
  var currentUser: User? {
    service.currentUser
  }
  
  var shouldShowRecentStatusHeader: Bool {
    if let allStatus {
      return !allStatus.isEmpty
    }
    return false
  }
  
  var shouldShowSeenStatusHeader: Bool {
    if let seenStatus {
      return !seenStatus.isEmpty
    }
    return false
  }

  let service: FirebaseService
  
  init(service: FirebaseService) {
    self.service = service
  }
  
  func onDisappear() {
    if currentUser == nil {
      allStatus = nil
      myStatus = nil
    }
  }
  
  func fetchMyStatus() async {
    Task(priority: .background) {
      let stories = await service.getAllStatus()
      DispatchQueue.main.async {
        self.isLoading = false
        self.allStatus = stories
        self.seenStatus = stories?.filter { $0.seenBy.contains(self.currentUser?.uid ?? "")}
        self.allStatus?.removeAll { $0.seenBy.contains(self.currentUser?.uid ?? "") }
        self.myStatus = self.allStatus?.filter({ status in
          return status.uid == self.service.currentUser?.uid
        }).first
        self.allStatus?.removeAll(where: { status in
          return status.uid == self.service.currentUser?.uid
        })
      }
    }
  }
  
  func handleStatusSeen() {
    let success = service.markStatusAsSeen(by: currentUser?.uid ?? "", status: &selectedStatus)
    
    DispatchQueue.main.async {
      if success {
        self.allStatus?.removeAll(where: { status in
          status.uid == self.selectedStatus?.uid
        })
        if let selectedStatus = self.selectedStatus {
          self.seenStatus?.append(selectedStatus)
        }
      }
    }
  }
  
  func addStatus(image: UIImage?) {
    guard let image = image else {
      return
    }
    isLoading = true
    Task(priority: .background) {
      let story = await service.uploadStatus(image: image)
      DispatchQueue.main.async {
        self.isLoading = false
        self.myStatus = story
      }
    }
  }
  
  func handleUserStoryTap(_ status: Status?) {
    selectedStatus = status
  }
}
