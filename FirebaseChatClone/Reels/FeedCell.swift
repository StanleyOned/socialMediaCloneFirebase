//
//  FeedCell.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 4/9/24.
//

import AVKit
import SwiftUI

struct FeedCell: View {
  let post: ReelPost
  var player: AVPlayer
  
  init(post: ReelPost, 
       player: AVPlayer) {
    self.post = post
    self.player = player
  }
  
  var body: some View {
    ZStack {
      CustomVideoPlayer(player: player)
        .containerRelativeFrame([.horizontal, .vertical])
      
      VStack {
        Spacer()
        HStack(alignment: .bottom) {
          VStack(alignment: .leading) {
            Text("Carlos Inoa")
              .fontWeight(.semibold)
            Text("subline of post")
          }
          Spacer()
          
          VStack(spacing: 32) {
            Circle()
              .frame(width: 48, height: 48)
              .foregroundStyle(.white)
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
              VStack {
                Image(systemName: "heart.fill")
                  .resizable()
                  .frame(width: 28, height: 28)
                  .foregroundStyle(.white)
                
                Text("27")
                  .font(.footnote)
                  .foregroundStyle(.white)
                  .bold()
              }
            })
            Button(action: {}, label: {
              VStack {
                Image(systemName: "ellipsis.bubble.fill")
                  .resizable()
                  .frame(width: 28, height: 28)
                  .foregroundStyle(.white)
                Text("27")
                  .font(.footnote)
                  .foregroundStyle(.white)
                  .bold()
              }
            })
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
              VStack {
                Image(systemName: "bookmark.fill")
                  .resizable()
                  .frame(width: 22, height: 28)
                  .foregroundStyle(.white)
                Text("27")
                  .font(.footnote)
                  .foregroundStyle(.white)
                  .bold()
              }
            })
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
              VStack {
                Image(systemName: "arrowshape.turn.up.right.fill")
                  .resizable()
                  .frame(width: 28, height: 28)
                  .foregroundStyle(.white)
                Text("27")
                  .font(.footnote)
                  .foregroundStyle(.white)
                  .bold()
              }
            })
          }
          .padding()
        }
      }
      .padding(.bottom, 80)
      .padding()
      .foregroundStyle(.white)
      .font(.subheadline)
    }
    .onTapGesture {
      switch player.timeControlStatus {
      case .paused:
        player.play()
      case .waitingToPlayAtSpecifiedRate:
        break
      case .playing:
        player.pause()
      @unknown default:
        break
      }
    }
  }
}
