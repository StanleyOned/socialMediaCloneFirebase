//
//  FeedViewModel.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 4/9/24.
//

import SwiftUI

final class FeedViewModel: ObservableObject {

  @Published var posts = [ReelPost]()
  
  let service: FirebaseService
  
  init(service: FirebaseService) {
    self.service = service
  }
  
  func fetchReels() async {
    Task { @MainActor in
      guard let reels = await service.getAllReels() else {
        return
      }
      posts = reels
    }
  }
  
  
  func postReel(_ movie: Movie) {
    Task { @MainActor in
      guard let reel = await service.postReel(movie: movie) else {
        return
      }
      posts.append(reel)
    }
  }
}
