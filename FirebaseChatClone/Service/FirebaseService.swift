//
//  FirebaseService.swift
//  FirebaseChatClone
//
//  Created by Stanley Delacruz on 10/23/23.
//

import Foundation
import DataCompression
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseDatabase

/// Wrapper class for firebase, includes implementation for storage, database and auth service
final class FirebaseService: ObservableObject {
  
  let auth: Auth
  let storage: Storage
  let fireStore: Firestore
  @Published var isUserLoggedOut = false
  @Published var showErrorAlert = false
  @Published var errorMessage = ""
  private var firestoreListener: ListenerRegistration?
  
  enum ServiceError: Error {
    case unableToGetUserID
    case unableToGetCollectionForUser
    case userDataNotFound
    
    var description: String {
      switch self {
      case .unableToGetUserID:
        return "Unable to get user ID from firebase"
      case .unableToGetCollectionForUser:
        return "Unable to get user collection from firestore"
      case .userDataNotFound:
        return "Unable to get user data from firebase"
      }
    }
  }
  
  /// Current user unique ID
  var userUID: String? {
    auth.currentUser?.uid
  }
  
  /// Current user
  var currentUser: User?
  
  init() {
    FirebaseApp.configure()
    self.auth = Auth.auth()
    self.storage = Storage.storage()
    self.fireStore = Firestore.firestore()
    Task(priority: .background) {
      await getCurrentUser()
    }
  }
  
  /// Clear error message alert that was received from a network request
  func clearErrorMessage() {
    showErrorAlert = false
    errorMessage = ""
  }
  
  /// Get the current user from firebase
  /// - Returns: A result type containing a User and Error
  func getCurrentUser() async -> Result<User, Error> {
    guard let uid = userUID else {
      let error = NSError()
      return .failure(error)
    }
    do {
      let user = try await fireStore.collection("users").document(uid).getDocument(as: User.self)
      self.currentUser = user
      return .success(user)
    } catch {
      showError(error.localizedDescription)
      return .failure(error)
    }
  }
  
  /// Get user with uid
  /// - Parameter uid: The uid that identifies the user
  /// - Returns: A User model type
  func getUser(with uid: String) async -> User? {
    do {
      return try await fireStore.collection("users").document(uid).getDocument(as: User.self)
    } catch {
      logError(error.localizedDescription)
      return nil
    }
  }
  
  func loginUser(_ email: String, password: String) async {
    do {
      try await auth.signIn(withEmail: email, password: password)
    } catch {
      showError(error.localizedDescription)
    }
  }
  
  func signOut() {
    do {
      try auth.signOut()
      firestoreListener?.remove()
    } catch {
      showError(error.localizedDescription)
    }
  }
  
  func createAccount(image: UIImage?,
                     email: String,
                     password: String) async {
    do {
      try await auth.createUser(withEmail: email, password: password)
      await saveImageToStorage(image: image, email: email, password: password)
    } catch {
      showError(error.localizedDescription)
    }
  }
  
  func getAllUsers() async throws -> [User]? {
    do {
      let documentSnapshots = try await fireStore.collection("users").getDocuments()
      var users = [User]()
      documentSnapshots.documents.forEach { document in
        do {
          let user = try document.data(as: User.self)
          if user.uid != userUID {
            users.append(user)
          }
        } catch {
          showError(error.localizedDescription)
        }
      }
      return users
    } catch {
      showError(error.localizedDescription)
      return nil
    }
  }
  
  func saveImageToStorage(image: UIImage?,
                          email: String,
                          password: String) async {
    guard let uid = userUID, let image = image else {
      return
    }
    let reference = storage.reference(withPath: uid)
    guard let data = image.jpegData(compressionQuality: 0.7) else {
      assertionFailure("Unable to decompress image")
      return
    }
    do {
      _ = try await reference.putDataAsync(data, metadata: nil, onProgress: nil)
      do {
        let imageURL = try await reference.downloadURL()
        await storeUserInfo(imageURL, email: email, password: password)
      } catch {
        showError(error.localizedDescription)
      }
    } catch {
      showError(error.localizedDescription)
    }
  }
  
  func listenToMessages(senderUID: String,
                        recipientUserUID: String,
                        completion: @escaping (Result<Chat, Never>) -> Void) {
    removeListener()
    fireStore
      .collection("messages")
      .document(senderUID)
      .collection(recipientUserUID)
      .order(by: "timestamp")
      .addSnapshotListener { documentSnapshots, error in
        documentSnapshots?.documentChanges.forEach { change in
          if change.type == .added {
            do {
              let message = try change.document.data(as: Chat.self)
              completion(.success(message))
            } catch {
              self.showError(error.localizedDescription)
            }
          }
        }
      }
  }
  
  func uploadStatus(image: UIImage) async -> Status? {
    guard let uid = userUID else {
      return nil
    }
    let reference = storage.reference().child("image_status/\(uid)")
    guard let data = image.jpegData(compressionQuality: 0.7) else {
      assertionFailure("Unable to decompress image")
      return nil
    }
    do {
      _ = try await reference.putDataAsync(data, metadata: nil, onProgress: nil)
      do {
        let imageURL = try await reference.downloadURL()
        return saveStatusForCurrentUser(imageURL: imageURL)
      } catch {
        showError(error.localizedDescription)
      }
    } catch {
      showError(error.localizedDescription)
    }
    return nil
  }
  
  func saveStatusForCurrentUser(imageURL: URL) -> Status? {
    guard let uid = userUID else {
      return nil
    }
    let timestamp = Date()
    let status = Status(uid: uid,
                        timestamp: timestamp,
                        email: currentUser?.email ?? "",
                        statusImageURL: imageURL.absoluteString, 
                        expiredAt: Calendar.current.date(byAdding: .minute, value: 25, to: timestamp) ?? Date(),
                        seenBy: [])
    do {
      try fireStore.collection("status").document(uid).setData(from: status)
      return status
    } catch {
      showError(error.localizedDescription)
    }
    return nil
  }
  
  func markStatusAsSeen(by uid: String, status: inout Status?) -> Bool {
    guard uid == userUID else {
      return false
    }
    
    if let status = status, status.seenBy.contains(uid) {
      return false
    }
    
    do {
      status?.addSeenBy(uid)
      try fireStore.collection("status").document(status?.uid ?? "").setData(from: status)
      return true
    } catch {
      showError(error.localizedDescription)
      return false
    }
  }
  
  /// Get all status/stories
  /// - Returns: An optional array of status
  func getAllStatus() async -> [Status]? {
    do {
      let documentSnapshots = try await fireStore.collection("status").getDocuments()
      var allStatus = [Status]()
      documentSnapshots.documents.forEach { document in
        do {
          let status = try document.data(as: Status.self)
          /// We just want to get the none expired stories
          if status.expiredAt > Date() {
            allStatus.append(status)
          } else {
            // TODO: Delete status from server
            // Check if it deletes the data below
            document.reference.delete()
          }
        } catch {
          showError(error.localizedDescription)
        }
      }
      return allStatus
    } catch {
      showError(error.localizedDescription)
      return nil
    }
  }
  
  /// Sends a message in the chat log
  /// - Parameters:
  ///   - recipientUser: The user who will be receiving the message
  ///   - message: The message text
  /// - Returns: A result type with a Void value that indicates success and Error if server couldn't send the message
  func sendMessage(recipientUser: User,
                   message: String) async -> Result<(), Error> {
    guard let senderUID = userUID else {
      return .failure(NSError(domain: "", code: -1))
    }
    let document = fireStore.collection("messages")
      .document(senderUID)
      .collection(recipientUser.uid)
      .document()
    
    do {
      /// Sender node
      let chat = Chat(id: nil,
                      senderID: senderUID,
                      recipientID: recipientUser.uid,
                      message: message,
                      messageType: .text,
                      messageImageURL: nil,
                      timestamp: Date(),
                      email: currentUser?.email ?? "",
                      profileImageURL: currentUser?.profileImageURL ?? "")
      try document.setData(from: chat)
      await persistRecentMessageForCurrentUser(recipientUser: recipientUser, 
                                               message: message)

      /// receiver node
      let document = fireStore.collection("messages")
        .document(recipientUser.uid)
        .collection(senderUID)
        .document()
      
      do {
        try document.setData(from: chat)
        return .success(())
      } catch {
        return .failure(error)
      }
    } catch {
      return .failure(error)
    }
  }
  
  func getAllReels() async -> [ReelPost]? {
    do {
      let documentSnapshots = try await fireStore.collection("videos").getDocuments()
      var reels = [ReelPost]()
      documentSnapshots.documents.forEach { document in
        do {
          let reel = try document.data(as: ReelPost.self)
          reels.append(reel)
        } catch {
          showError(error.localizedDescription)
        }
      }
      return reels
    } catch {
      showError(error.localizedDescription)
      return nil
    }
  }
  
  func postReel(movie: Movie) async -> ReelPost? {
    guard let userUID = userUID, let data = try? Data(contentsOf: movie.url) else {
      return nil
    }
    let reference = storage.reference().child("videos/\(movie.url.lastPathComponent)-\(userUID)")
    
    do {
      _ = try await reference.putDataAsync(data, metadata: nil, onProgress: nil)
      do {
        let videoURL = try await reference.downloadURL()
        return saveVideo(videoURL: videoURL)
      } catch {
        showError(error.localizedDescription)
      }
    } catch {
      showError(error.localizedDescription)
    }
    return nil
  }
  
  func saveVideo(videoURL: URL) -> ReelPost? {
    guard let uid = userUID else {
      return nil
    }
    let reel = ReelPost(uid: uid,
                        timestamp: Date(),
                        videoUrl: videoURL.absoluteString,
                        email: currentUser?.email ?? "")
    do {
      try fireStore.collection("videos").document("\(uid)-\(UUID().uuidString)").setData(from: reel)
      return reel
    } catch {
      showError(error.localizedDescription)
    }
    return nil
  }
  
  func sendImage(recipientUser: User,
                 image: UIImage) async -> Result<(), Error> {
    guard let senderUID = userUID else {
      return .failure(NSError(domain: "", code: -1))
    }
    let document = fireStore.collection("messages")
      .document(senderUID)
      .collection(recipientUser.uid)
      .document()
    let url = await uploadImageForMessage(image: image)
    do {
      /// Sender node
      let chat = Chat(id: nil,
                      senderID: senderUID,
                      recipientID: recipientUser.uid,
                      message: nil,
                      messageType: .image,
                      messageImageURL: url?.absoluteString,
                      timestamp: Date(),
                      email: currentUser?.email ?? "",
                      profileImageURL: currentUser?.profileImageURL ?? "")
      try document.setData(from: chat)
      await persistRecentMessageForCurrentUser(recipientUser: recipientUser,
                                               message: "Image")

      /// receiver node
      let document = fireStore.collection("messages")
        .document(recipientUser.uid)
        .collection(senderUID)
        .document()
      
      do {
        try document.setData(from: chat)
        return .success(())
      } catch {
        return .failure(error)
      }
    } catch {
      return .failure(error)
    }
  }
  
  /// Deletes the recent message from the chat log messages screen
  /// - Parameter recentMessage: The recent message model
  /// - Returns: A boolean indicating if we succeeded deleting the recent message
  func deleteRecentMessage(_ recentMessage: RecentMessage) async -> Bool {
    guard let uid = userUID else {
      return false
    }
    let uidForReceiver = recentMessage.senderID == uid ? recentMessage.recipientID : recentMessage.senderID
    do {
      try await fireStore.collection("recent_messages")
        .document(uid)
        .collection("messages")
        .document(uidForReceiver).delete()
      
      do {
        let snapshots = try await fireStore.collection("messages")
          .document(uid)
          .collection(recentMessage.recipientID)
          .getDocuments()
        snapshots.documents.forEach { documentSnapshot in
          documentSnapshot.reference.delete()
        }

      } catch {
        logError(error.localizedDescription)
      }
      return true
    } catch {
      showError(error.localizedDescription)
      return false
    }
  }
  
  func listenToRecentMessage(completion: @escaping (Result<RecentMessage, Never>) -> Void) {
    guard let uid = userUID else {
      return
    }

    firestoreListener = fireStore.collection("recent_messages")
      .document(uid)
      .collection("messages")
      .order(by: "timestamp")
      .addSnapshotListener { querySnapshot, error in
        querySnapshot?.documentChanges.forEach { change in
          do {
            let message = try change.document.data(as: RecentMessage.self)
            completion(.success(message))
          } catch {
            self.showError(error.localizedDescription)
          }
        }
      }
  }
  
  func removeListener() {
    firestoreListener?.remove()
  }
}

// MARK: - Private Functions

private extension FirebaseService {
  
  func showError(_ message: String) {
    errorMessage = message
    showErrorAlert = true
  }
  
  func storeUserInfo(_ url: URL, email: String, password: String) async {
    guard let uid = userUID else {
      return
    }
    let user = User(uid: uid, email: email, profileImageURL: url.absoluteString)
    do {
      try fireStore.collection("users").document(uid).setData(from: user)
    } catch {
      showError(error.localizedDescription)
    }
  }
  
  func persistRecentMessageForCurrentUser(recipientUser: User, message: String) async {
    guard let uid = userUID else {
      return
    }
    let document = fireStore.collection("recent_messages")
                                      .document(uid)
                                      .collection("messages")
                                      .document(recipientUser.uid)
    let chat = Chat(id: nil,
                    senderID: uid,
                    recipientID: recipientUser.uid,
                    message: message,
                    messageType: .text,
                    messageImageURL: nil,
                    timestamp: Date(),
                    email: recipientUser.email,
                    profileImageURL: recipientUser.profileImageURL)
    
    do {
      try document.setData(from: chat)
      persistRecentMessageForReceiverUser(recipientUser, message: message)
    } catch {
      showError(error.localizedDescription)
    }
  }
  
  func persistRecentMessageForReceiverUser(_ receiverUser: User, message: String) {
    guard let uid = userUID else {
      return
    }
    let document = fireStore.collection("recent_messages")
                                      .document(receiverUser.uid)
                                      .collection("messages")
                                      .document(uid)
    let chat = Chat(id: nil,
                    senderID: uid,
                    recipientID: receiverUser.uid,
                    message: message,
                    messageType: .text,
                    messageImageURL: nil,
                    timestamp: Date(),
                    email: currentUser?.email ?? "",
                    profileImageURL: currentUser?.profileImageURL ?? "")
    
    do {
      try document.setData(from: chat)
    } catch {
      showError(error.localizedDescription)
    }
  }
  
  func logError(_ message: String) {
    let errorMessage =
    """
    ***
    \(message)
    ***
    """
    print(errorMessage)
  }
  
  func uploadImageForMessage(image: UIImage) async -> URL? {
    guard let uid = userUID else {
      return nil
    }
    let reference = storage.reference().child("message_image/\(uid)/\(UUID().uuidString)")
    guard let data = image.jpegData(compressionQuality: 0.7) else {
      assertionFailure("Unable to decompress image")
      return nil
    }
    do {
      _ = try await reference.putDataAsync(data, metadata: nil, onProgress: nil)
      do {
        let imageURL = try await reference.downloadURL()
        return imageURL
      } catch {
        showError(error.localizedDescription)
      }
    } catch {
      showError(error.localizedDescription)
    }
    return nil
  }
}
