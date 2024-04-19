//
//  ChatView.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/29/23.
//

import SwiftUI

struct ChatView: View {
  
  private let recipientUser: User
  @State private var showSheet = false
  @State private var selectedImage: UIImage?
  @State private var showFullImage = false
  @ObservedObject var viewModel: ChatViewModel
  
  init(recipientUser: User,
       service: FirebaseService) {
    self.recipientUser = recipientUser
    self.viewModel = ChatViewModel(service: service, recipientUser: recipientUser)
  }
  
  var body: some View {
    ScrollView {
      ScrollViewReader { proxy in
        VStack {
          ForEach(viewModel.chatMessages) { chat in
            MessageView(chat: chat, 
                        currentUserUID: viewModel.userUID) { url in
              viewModel.chatImageTappedURL = url
              showFullImage.toggle()
            }
          }
          HStack {
            Spacer()
          }.id("hello world")
        }
        .onReceive(viewModel.$count) { _ in
            withAnimation(.easeOut(duration: 0.5)) {
              proxy.scrollTo("hello world", anchor: .bottom)
            }
        }
      }
    }
    .fullScreenCover(isPresented: $showSheet) {
      print("Image: \($selectedImage)")
      viewModel.sendImageForChat(image: selectedImage)
    } content: {
      ImagePicker(selectedImage: $selectedImage)
    }
    .fullScreenCover(isPresented: $showFullImage) {
      StoryView(imageURL: viewModel.chatImageTappedURL)
    }
    .safeAreaInset(edge: .bottom) {
        textfieldBarView
            .background(Color(.systemBackground).ignoresSafeArea())
    }
    .navigationTitle(recipientUser.username ?? "")
    .onDisappear(perform: {
      viewModel.onDisappear()
    })
    .toolbarBackground(Color.white)
  }
}

private extension ChatView {
  
  var textfieldBarView: some View {
    HStack(alignment: .top) {
      Button {
        showSheet.toggle()
      } label: {
        Image(systemName: "photo.on.rectangle")
          .font(.system(size: 24))
          .foregroundStyle(Color(.darkGray))
      }

      TextField(Strings.description, text: $viewModel.textfieldText, axis: .vertical)
        .lineLimit(4)
        .textFieldStyle(.roundedBorder)
      Button(action: {
        viewModel.sendMessage()
      }, label: {
        Image(systemName: "paperplane.circle.fill")
          .resizable()
          .frame(width: 30, height: 30)
          .padding()
      })
      .frame(width: 30, height: 30)
    }
    .padding()
    .background(Color.white)
  }
}

struct MessageView: View {
  
  let chat: Chat
  let currentUserUID: String
  var didTapImage: ((String) -> Void)?

  var body: some View {
    VStack {
      if chat.senderID == currentUserUID {
        HStack {
          Spacer()
          HStack {
            if chat.messageType == .image {
              AsyncImage(url: URL(string: chat.messageImageURL ?? "")) { image in
                image
                  .resizable()
                  .scaledToFill()
                  .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                  .frame(width: 200, height: 100)
                  .clipped()
              } placeholder: {
                ZStack {
                  ProgressView()
                    .foregroundStyle(Color(.lightGray))
                    .scaleEffect(1.2)
                  RoundedRectangle(cornerRadius: 8, style: .circular)
                    .fill(Color.blue)
                    .frame(width: 200, height: 100)
                }
              }
              .onTapGesture {
                didTapImage?(chat.messageImageURL ?? "")
              }
            } else {
              Text(chat.message ?? "")
                .foregroundColor(.white)
            }
          }
          .padding(chat.messageType == .image ? 8 : 16)
          .background(chat.messageType == .image ? Color.clear : Color.blue)
          .cornerRadius(8)
        }
      } else {
        HStack {
          HStack {
            if chat.messageType == .image {
              AsyncImage(url: URL(string: chat.messageImageURL ?? "")) { image in
                image
                  .resizable()
                  .scaledToFill()
                  .frame(width: 200, height: 100)
                  .clipShape(RoundedRectangle(cornerRadius: 8, style: .circular))
                  .clipped()
              } placeholder: {
                ZStack {
                  ProgressView()
                    .foregroundStyle(Color(.lightGray))
                    .scaleEffect(1.2)
                  RoundedRectangle(cornerRadius: 8, style: .circular)
                    .fill(Color.green)
                    .frame(width: 200, height: 100)
                }
              }
              .onTapGesture {
                didTapImage?(chat.messageImageURL ?? "")
              }
            } else {
              Text(chat.message ?? "")
                .foregroundColor(.black)
            }
          }
          .padding(chat.messageType == .image ? 8 : 16)
          .background(chat.messageType == .image ? Color.clear : Color.green)
          .cornerRadius(8)
          Spacer()
        }
      }
    }
    .padding(.horizontal)
    .padding(.top, 8)
  }
}

#Preview {
  ChatView(recipientUser: .init(uid: "",
                                email: "Something@gmail.com",
                                profileImageURL: ""), service:
            FirebaseService())
}
