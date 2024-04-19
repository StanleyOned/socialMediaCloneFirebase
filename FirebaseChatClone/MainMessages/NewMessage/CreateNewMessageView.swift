//
//  CreateNewMessageView.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/27/23.
//

import Foundation
import SwiftUI

struct CreateNewMessageView: View {
  
  @Environment(\.dismiss) private var dismiss
  @ObservedObject private var viewModel: CreateNewMessageViewModel
  @Binding var userSelected: User?
  @Binding var pushChatScreen: Bool
  
  init(service: FirebaseService, 
       userSelected: Binding<User?>,
       pushChatScreen: Binding<Bool>) {
    self.viewModel = CreateNewMessageViewModel(service: service)
    self._userSelected = userSelected
    self._pushChatScreen = pushChatScreen
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack {
          if viewModel.isLoading {
            progressView
          } else {
            UserList
          }
        }
      }
      .padding(.horizontal, 12)
      .navigationTitle(Strings.newMessage)
      .toolbar {
        ToolbarItemGroup(placement: .topBarLeading) {
          Button {
            dismiss()
          } label: {
            Text(Strings.cancel)
          }
        }
      }.onAppear {
        Task {
          await viewModel.fetchAllUsers()
        }
      }
    }
  }
  
  private var UserList: some View {
    LazyVStack {
      ForEach(viewModel.users) { user in
        Button {
          self.userSelected = user
          pushChatScreen.toggle()
          dismiss()
        } label: {
          userRow(user)
          Divider()
        }
        .padding(.top)
        .buttonStyle(PlainButtonStyle())
        Divider()
      }
      .padding(.top)
    }
  }
  
  private var progressView: some View {
    VStack {
      Spacer()
      ProgressView {
        Text(Strings.loading)
          .foregroundColor(Color(.lightGray))
          .bold()
      }
      Spacer()
    }
  }
  
  private func userRow(_ user: User) -> some View {
    HStack(alignment: .top, spacing: 16) {
      AsyncImage(url: URL(string: user.profileImageURL)) {
        $0
          .resizable()
          .scaledToFill()
          .frame(width: 54, height: 54)
          .clipShape(Circle())
          .overlay {
            RoundedRectangle(cornerRadius: 44).stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
          }
      } placeholder: {
        ProgressView()
          .frame(width: 54, height: 54)
          .foregroundStyle(Color(.gray))
      }
      .padding(.top, -16)
      
      Text(user.username ?? "")
        .font(.system(size: 18, weight: .bold))
        .multilineTextAlignment(.leading)
        .padding(.bottom, 6)
      Spacer()
    }
  }
}
