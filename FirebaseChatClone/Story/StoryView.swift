//
//  StoryView.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 11/6/23.
//

import SwiftUI

struct StoryView: View {

  @State var showButton = false
  @Environment(\.dismiss) var dismiss

  let imageURL: String?
  var handleUserSeenStatus: (() -> Void)?
  
  var body: some View {
    GeometryReader { proxy in
      ZStack {
        AsyncImage(url: URL(string: imageURL ?? "")) { image in
          image
            .resizable()
            .scaledToFill()
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            .clipped()
        } placeholder: {
          Color.black.ignoresSafeArea()
        }
        
        if showButton {
          closeButton
        }
      }
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          showButton = true
        }
        handleUserSeenStatus?()
      }
    }
    .ignoresSafeArea(.all)
  }
  
  private var closeButton: some View {
    VStack {
      HStack {
        Button(action: {
          dismiss()
        }, label: {
          Image(systemName: "x.circle")
            .resizable()
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .shadow(radius: 5)
        })
        Spacer()
      }
      .padding(.top, 45)
      Spacer()
    }
    .padding(.horizontal, 32)
  }
}

#Preview {
  StoryView(imageURL: "background", 
            handleUserSeenStatus: nil)
}
