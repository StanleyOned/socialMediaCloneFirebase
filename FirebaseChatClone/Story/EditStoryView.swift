//
//  EditStoryView.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 11/22/23.
//

import SwiftUI

struct EditStoryView: View {
  
  @State private var text = ""
  @State private var textFieldText = "" {
    didSet {
      text = textFieldText
    }
  }
  @Environment(\.dismiss) var dismiss
  @Binding var image: UIImage?
  @State private var bottomPadding: CGFloat = 42
  @Environment(\.displayScale) var displayScale
  let action: ((UIImage) -> Void)

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      RenderView(image: $image, text: $text)
      VStack {
        closeButton
        Spacer()
        TextField(Strings.addDescriptionToStory, text: $text, axis: .vertical)
          .extensionTextFieldView(roundedCornes: 6, startColor: .orange, endColor: .purple)
          .lineLimit(4)
        HStack {
          Spacer()
          Button(action: {
            render()
          }, label: {
            Image(systemName: "paperplane.circle.fill")
              .resizable()
              .frame(width: 30, height: 30)
              .padding()
          })
          .frame(width: 30, height: 30)
        }
      }
      .padding(.horizontal)
      .padding(.bottom, bottomPadding)
    }
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
  
  @MainActor func render() {
    let renderer = ImageRenderer(content: RenderView(image: $image, text: $text))
    
    // make sure and use the correct display scale for this device
    renderer.scale = displayScale
    
    if let uiImage = renderer.uiImage {
      action(uiImage)
      dismiss()
    }
  }
}

extension TextField {
  
  func extensionTextFieldView(roundedCornes: CGFloat, startColor: Color,  endColor: Color) -> some View {
    self
      .padding()
      .background(LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .topLeading, endPoint: .bottomTrailing))
      .cornerRadius(roundedCornes)
      .shadow(color: .purple, radius: 3)
  }
}

struct RenderView: View {
  
  @Binding var image: UIImage?
  @Binding var text: String

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      Image(uiImage: self.image ?? UIImage())
        .resizable()
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        .scaledToFill()
        .clipShape(Rectangle())
      VStack {
        Spacer()
        Text(text)
            .font(.custom("AmericanTypewriter", fixedSize: 24))
            .lineLimit(100)
            .frame(maxWidth: UIScreen.main.bounds.size.width - 32)
            .bold()
            .foregroundStyle(Color.white)
            .shadow(color: .black,radius: 5)
            .padding(.horizontal, 16)
            .padding(.top, 32)
        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 42)
    }
  }
}
