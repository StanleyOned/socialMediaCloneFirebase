//
//  ReelsView.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 12/18/23.
//

import AVKit
import SwiftUI
import PhotosUI

struct FeedView: View {
  @ObservedObject var viewModel: FeedViewModel
  @State private var scrollPosition: String?
  @State private var player = AVPlayer()
  @State private var media: PhotosPickerItem?
  
  init(service: FirebaseService) {
    self.viewModel = FeedViewModel(service: service)
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        if viewModel.posts.isEmpty {
          addMediaView
        } else {
//          addMediaView
          ForEach(viewModel.posts) { post in
            FeedCell(post: post,
                     player: player)
              .id(post.id)
              .onAppear {
                playInitialVideoIfNeccesary()
              }
          }
        }
      }
      .scrollTargetLayout()
    }.onChange(of: media) {
      Task {
        if let movie = try? await media?.loadTransferable(type: Movie.self) {
          viewModel.postReel(movie)
        } else {
          print("Failed")
        }
      }
    }
    .onAppear { player.play() }
    .task {
      await viewModel.fetchReels()
    }
    .scrollPosition(id: $scrollPosition)
    .scrollTargetBehavior(.paging)
    .ignoresSafeArea()
    .onChange(of: scrollPosition) { oldValue, newValue in
      playVideoOnChange(postID: newValue)
    }
  }
  
  var addMediaView: some View {
    Group {
      Spacer()
      PhotosPicker("Select media", selection: $media)
      Spacer()
    }
  }
  
  func playInitialVideoIfNeccesary() {
    guard scrollPosition == nil, let post = viewModel.posts.first, player.currentItem == nil else {
      return
    }
    let item = AVPlayerItem(url: URL(string: post.videoUrl)!)
    player.replaceCurrentItem(with: item)
  }
  
  func playVideoOnChange(postID: String?) {
    guard let currentPost = viewModel.posts.first(where: { $0.id == postID }) else {
      return
    }
    player.replaceCurrentItem(with: nil)
    let item = AVPlayerItem(url: URL(string: currentPost.videoUrl)!)
    player.replaceCurrentItem(with: item)
  }
}
