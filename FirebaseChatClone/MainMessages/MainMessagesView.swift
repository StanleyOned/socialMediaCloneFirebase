//
//  MainMessagesView.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/24/23.
//

import SwiftUI


struct MainMessagesView: View {
  
  // MARK: - Properties
  
  @State private var shouldShowSettings = false
  @State private var shouldShowNewMessage: Bool

  @ObservedObject private var viewModel: MainMessagesViewModel
  
  init(shouldShowSettings: Bool = false,
       shouldShowNewMessage: Bool = false,
       service: FirebaseService) {
    self.shouldShowSettings = shouldShowSettings
    self.shouldShowNewMessage = shouldShowNewMessage
    self.viewModel = MainMessagesViewModel(service: service)
  }
  
  // MARK: - Body
  
  var body: some View {
    NavigationStack {
      VStack {
        CustomNavBar(shouldShowNewMessage: $shouldShowNewMessage,
                     shouldShowSettings: $shouldShowSettings,
                     viewModel: viewModel)
        messageListView
      }
      .task {
        guard !viewModel.isUserLoggedOut else {
          return
        }
        await viewModel.fetchCurrentUser()
      }
    }
    .toolbarBackground(Color.pink, for: .navigationBar)
    .fullScreenCover(isPresented: $viewModel.isUserLoggedOut, onDismiss: {
      Task {
        await viewModel.fetchCurrentUser()
      }
    }, content: {
      LoginView(isUserLoggedOut: $viewModel.isUserLoggedOut,
                service: viewModel.service)
    })
    .onAppear {
      viewModel.onAppear()
    }
    .fullScreenCover(isPresented: $shouldShowNewMessage) {
      CreateNewMessageView(service: viewModel.service,
                           userSelected: $viewModel.userSelected,
                           pushChatScreen: $viewModel.pushChatScreen)
    }
  }
}

// MARK: - Private Functions

private extension MainMessagesView {
  
  private var messageListView: some View {
    ScrollView {
      ForEach(viewModel.recentMessages) { recentMessage in
        LazyVStack {
          messageRow(recentMessage)
            .onTapGesture {
              viewModel.handleMessageTapped(recentMessage)
            }
            .onLongPressGesture {
              viewModel.handleLongPress(recentMessage)
            }
          Divider()
            .padding(.vertical, 8)
        }
      }
    }
    .padding(.bottom, 32)
    .navigationBarHidden(true)
    .padding()
    .navigationDestination(isPresented: $viewModel.pushChatScreen) {
      pushChatView
    }
  }
  
  @ViewBuilder
  var pushChatView: some View {
    if let userSelected = viewModel.userSelected {
      ChatView(recipientUser: userSelected,
               service: viewModel.service)
    }
  }
  
  func messageRow(_ recentMessage: RecentMessage) -> some View {
    HStack(alignment: .top, spacing: 16) {
      
      AsyncImage(url: URL(string: recentMessage.profileImageURL)) {
        $0
          .resizable()
          .scaledToFill()
          .frame(width: 44, height: 44)
          .clipShape(Circle())
          .padding(2)
          .overlay {
            RoundedRectangle(cornerRadius: 44).stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/).shadow(radius: 1)

          }
      } placeholder: {
        ProgressView()
          .scaleEffect(1.2)
          .foregroundStyle(Color(.gray))
      }
      
      VStack(alignment: .leading, spacing: 4) {
        Text(recentMessage.username ?? "")
          .font(.system(size: 16, weight: .bold))
        Text(recentMessage.message)
          .font(.system(size: 14))
          .foregroundStyle(Color(.lightGray))
      }
      .multilineTextAlignment(.leading)
      
      Spacer()
      
      Text(recentMessage.timeAgo)
        .font(.system(size: 14, weight: .semibold))
    }
  }
  
}

#Preview {
  MainMessagesView(service: FirebaseService())
}
