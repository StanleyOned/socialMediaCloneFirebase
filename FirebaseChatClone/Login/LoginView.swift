//
//  ContentView.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/23/23.
//

import Firebase
import SwiftUI

struct LoginView: View {
  
  @State private var isLoginMode = false
  @State private var email = ""
  @State private var password = ""
  @State private var errorMessage: String?
  @State private var image: UIImage?
  @State private var showSheet = false
  @Binding var isUserLoggedOut: Bool
  
  private let service: FirebaseService
  
  init(isLoginMode: Bool = false, 
       email: String = "",
       password: String = "",
       isUserLoggedOut: Binding<Bool>,
       service: FirebaseService) {
    self.isLoginMode = isLoginMode
    self.email = email
    self.password = password
    self.service = service
    self._isUserLoggedOut = isUserLoggedOut
  }
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          pickerView
          if !isLoginMode {
            avatarButton
          }
          fieldUI
          loginButton
        }
        .padding()
        
        Text(errorMessage ?? "")
          .foregroundStyle(Color.red)
          .padding()
      }
      .navigationTitle(isLoginMode ? "Log In" : "Create Account")
      .background(Color(.init(white: 0, alpha: 0.05)))
    }
    .fullScreenCover(isPresented: $showSheet) {} content: {
      ImagePicker(selectedImage: $image)
    }
  }
  
  private var avatarButton: some View {
    Button(action: {
      showSheet.toggle()
    }, label: {
      Group {
        if let image = image {
          Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: 128, height: 128)
            .clipShape(Circle())
        } else {
          Image(systemName: "person.fill")
        }
      }
      .font(.system(size: 64))
      .tint(.black)
      .padding()
    })
  }
  
  private var fieldUI: some View {
    Group {
      TextField("Email", text: $email)
        .textContentType(.emailAddress)
        .foregroundStyle(Color(.label))
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.none)
      SecureField("Password", text: $password)
    }
    .padding(12)
    .background(Color.white)
  }
  
  private var loginButton: some View {
    Button(action: {
      Task {
        await handleAction()
      }
    }, label: {
      HStack {
        Spacer()
        Text(isLoginMode ? Strings.login : Strings.createAccount)
          .foregroundColor(.white)
          .padding(.vertical, 10)
          .font(.system(size: 14, weight: .semibold))
        Spacer()
      }
      .background(Color.accentColor)
    })
    .clipShape(Capsule())
    .padding(.top, 16)
    
  }
  
  private var pickerView: some View {
    Picker(selection: $isLoginMode,
           content: {
      Text(Strings.login)
        .tag(true)
      Text(Strings.createAccount)
        .tag(false)
    }, label: {
      Text("Picker here")
    })
    .pickerStyle(SegmentedPickerStyle())
    .padding()
  }
  
  private func handleAction() async {
    if isLoginMode {
      await service.loginUser(email, password: password)
      DispatchQueue.main.async {
        if errorMessage == nil {
          isUserLoggedOut = false
        }
      }
    } else {
      await service.createAccount(image: image,
                                  email: email,
                                  password: password)
      DispatchQueue.main.async {
        if errorMessage == nil {
          isUserLoggedOut = false
        }
      }
    }
  }
}

#Preview {
  LoginView(isUserLoggedOut: .constant(true),
            service: FirebaseService())
}
