//
//  CustomNavBar.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/24/23.
//

import SwiftUI

struct CustomNavBar: View {
  
  @Binding var shouldShowNewMessage: Bool
  @Binding var shouldShowSettings: Bool
  @ObservedObject var viewModel: MainMessagesViewModel
  
  var body: some View {
    HStack(spacing: 16) {
      ImageView(imageURLString: viewModel.user?.profileImageURL, showPlusButton: false, borderColor: Color(.black))
      
      VStack(alignment: .leading, spacing: 4) {
        Text(viewModel.user?.username ?? "")
          .font(.system(size: 24, weight: .bold))
        HStack {
          Circle()
            .foregroundStyle(Color(.green))
            .frame(width: 14, height: 14)
          Text(Strings.online)
            .font(.system(size: 14))
            .foregroundStyle(Color(.lightGray))
        }
      }
      Spacer()
      Button {
        shouldShowNewMessage.toggle()
      } label: {
        Image(systemName: "arrow.up.message.fill")
          .font(.system(size: 24, weight: .bold))
          .foregroundStyle(Color(.label))
      }
      Button {
        shouldShowSettings.toggle()
      } label: {
        Image(systemName: "gear")
          .font(.system(size: 24, weight: .bold))
          .foregroundStyle(Color(.label))
      }
    }
    .padding()
    .confirmationDialog(Strings.settings, isPresented: $shouldShowSettings) {
      Button(Strings.signOut , role: .destructive) {
        viewModel.handleSignOut()
      }
      Button(Strings.cancel, role: .cancel) { }
    } message: {
      Text(Strings.whatWouldYouLikeEtc)
    }
  }
}

#Preview {
  CustomNavBar(shouldShowNewMessage: .constant(false),
               shouldShowSettings: .constant(false),
               viewModel: MainMessagesViewModel(service: FirebaseService()))
  .background(Color(.init(white: 1, alpha: 0.2)))
}
