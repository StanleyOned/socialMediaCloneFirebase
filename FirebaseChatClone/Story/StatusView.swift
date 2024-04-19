//
//  StatusView.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 11/5/23.
//

import SwiftUI

struct StatusView: View {
  
  @State private var didSelectImage = false
  @State private var showAddStatusSheet = false
  @State private var showMyStatusSheet = false
  @State private var showFriendStatusSheet = false
  @State private var image: UIImage?
  @ObservedObject private var viewModel: StatusViewViewModel
    
  init(showAddStatusSheet: Bool = false, 
       image: UIImage? = nil,
       selectedStatus: Status? = nil,
       service: FirebaseService) {
    self.showAddStatusSheet = showAddStatusSheet
    self.image = image
    self.viewModel = StatusViewViewModel(service: service)
  }
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(Strings.updates)
            .font(.system(size: 31, weight: .bold))
            .multilineTextAlignment(.leading)
          Spacer()
          if viewModel.isLoading {
            ProgressView()
              .foregroundStyle(Color(.lightGray))
              .scaleEffect(1.2)
              .padding(.trailing)
          }
        }
        Text(Strings.updates.uppercased())
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(Color(.lightGray))
          .multilineTextAlignment(.leading)
          .padding(.vertical)
        myStatus()
        unseenStatusList()
        seenStatusList()
      }
      .padding(.horizontal)
    }
    .onAppear {
      Task(priority: .background) {
        await viewModel.fetchMyStatus()
      }
    }
    .onDisappear(perform: {
      viewModel.onDisappear()
    })
    .padding(.top)
    .fullScreenCover(isPresented: $showAddStatusSheet) {
      didSelectImage.toggle()
    } content: {
      ImagePicker(selectedImage: $image)
    }
    .fullScreenCover(isPresented: $showMyStatusSheet) {
      StoryView(imageURL: viewModel.myStatus?.statusImageURL)
    }
    .fullScreenCover(isPresented: $showFriendStatusSheet) {
      StoryView(imageURL: viewModel.selectedStatus?.statusImageURL) {
        viewModel.handleStatusSeen()
      }
    }
    .fullScreenCover(isPresented: $didSelectImage) {
      EditStoryView(image: $image, action: { image in
        viewModel.addStatus(image: image)
      })
    }
  }
  
  private func myStatus() -> some View {
    Button(action: {
      if viewModel.myStatus == nil {
        showAddStatusSheet.toggle()
      } else {
        showMyStatusSheet.toggle()
      }
    }, label: {
      HStack(spacing: 8) {
        if viewModel.myStatus == nil {
          ImageView(imageURLString: viewModel.currentUser?.profileImageURL, showPlusButton: true, borderColor: Color(.lightGray))
          VStack(alignment: .leading, spacing: 4) {
            Text(Strings.myStatus)
              .font(.system(size: 16, weight: .semibold))
            Text(Strings.addAStory)
              .font(.system(size: 12, weight: .light))
              .foregroundStyle(Color(.lightGray))
          }
          Spacer()

        } else {
          Group {
            ImageView(imageURLString: viewModel.myStatus?.statusImageURL, showPlusButton: false, borderColor: Color(.black))
            Text(viewModel.myStatus?.username ?? "")
              .font(.system(size: 16, weight: .semibold))
            Spacer()
            Text(Strings.replace)
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(Color(.accent))
              .onTapGesture {
                showAddStatusSheet.toggle()
              }
              .padding(.trailing)
          }
        }
      }
      .padding(.top)
    })
    .buttonStyle(PlainButtonStyle())
  }
  
  @ViewBuilder
  private func unseenStatusList() -> some View {
    if viewModel.shouldShowRecentStatusHeader {
      Text(Strings.recentUpdates.uppercased())
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(Color(.lightGray))
        .multilineTextAlignment(.leading)
        .padding(.vertical)
    }
    ForEach(viewModel.allStatus ?? []) { status in
      HStack(spacing: 8) {
        ImageView(imageURLString: status.statusImageURL, 
                  showPlusButton: false,
                  borderColor: Color(.blue))
        
        Text(status.username ?? "")
          .font(.system(size: 16, weight: .semibold))
        Spacer()
      }
      .onTapGesture {
        viewModel.handleUserStoryTap(status)
        showFriendStatusSheet.toggle()
      }
      .padding(.vertical, 4)
      Divider()
    }
  }
  
  @ViewBuilder
  private func seenStatusList() -> some View {
    if viewModel.shouldShowSeenStatusHeader {
      Text(Strings.viewedUpdates.uppercased())
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(Color(.lightGray))
        .multilineTextAlignment(.leading)
        .padding(.vertical)
    }
    ForEach(viewModel.seenStatus ?? []) { status in
      HStack(spacing: 8) {
        ImageView(imageURLString: status.statusImageURL,
                  showPlusButton: false,
                  borderColor: Color(.lightGray))
        
        Text(status.username ?? "")
          .font(.system(size: 16, weight: .semibold))
        Spacer()
      }
      .onTapGesture {
        viewModel.handleUserStoryTap(status)
        showFriendStatusSheet.toggle()
      }
      .padding(.vertical, 4)
      Divider()
    }
  }
}

#Preview {
  StatusView(service: FirebaseService())
}
