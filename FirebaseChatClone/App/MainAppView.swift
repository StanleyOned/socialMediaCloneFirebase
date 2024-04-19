//
//  MainAppView.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 11/5/23.
//

import SwiftUI

struct MainAppView: View {
  
  @ObservedObject private var service = FirebaseService()
  
  var body: some View {
    NavigationStack {
      TabView {
        StatusView(service: service)
          .tabItem {
            Label(Strings.updates, systemImage: "message.badge.circle")
          }
        MainMessagesView(service: service)
          .tabItem {
            Label(Strings.messages, systemImage: "message.fill")
          }
        
        FeedView(service: service)
          .tabItem {
            Label(Strings.reels, systemImage: "video.bubble")
          }
      }
    }
    .alert(service.errorMessage,
           isPresented: $service.showErrorAlert) {
      Button(Strings.ok, role: .cancel) {
        service.clearErrorMessage()
      }
    }
  }
}

#Preview {
    MainAppView()
}
