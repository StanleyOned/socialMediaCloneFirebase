//
//  ImageView.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 11/5/23.
//

import SwiftUI

struct ImageView: View {
  
  let imageURLString: String?
  let showPlusButton: Bool
  let borderColor: Color
  
  var body: some View {
    AsyncImage(url: URL(string: imageURLString ?? "")) {
      $0
        .resizable()
        .scaledToFill()
        .frame(width: 44, height: 44)
        .clipShape(Circle())
        .padding(2)
        .overlay {
          RoundedRectangle(cornerRadius: 44).stroke(borderColor, lineWidth: 2)
          if showPlusButton {
            plusImage
          }
        }
        .shadow(radius: 10)
    } placeholder: {
      ProgressView()
        .frame(width: 44, height: 44)
        .foregroundStyle(Color(.gray))
    }
  }
  
  private var plusImage: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        Image(systemName: "plus.circle.fill")
          .foregroundStyle(Color(.white))
          .padding(.trailing, 4)
          .frame(width: 5, height: 5, alignment: .bottom)
      }
    }
    .frame(width: 44, height: 44)
  }
}
