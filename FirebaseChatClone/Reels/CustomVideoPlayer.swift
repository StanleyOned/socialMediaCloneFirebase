//
//  CustomVideoPlayer.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 4/9/24.
//

import AVKit
import SwiftUI

struct CustomVideoPlayer: UIViewControllerRepresentable {
  var player: AVPlayer
  
  func makeUIViewController(context: Context) -> UIViewController {
    let controller = AVPlayerViewController()
    controller.player = player
    controller.showsPlaybackControls = false
    controller.exitsFullScreenWhenPlaybackEnds = true
    controller.allowsPictureInPicturePlayback = true
    controller.videoGravity = .resizeAspectFill // makes video full screen
    return controller
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    
  }
}
