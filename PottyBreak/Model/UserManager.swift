//
//  UserManager.swift
//  Talgo
//
//  Created by fahad on 17/11/2018.
//  Copyright © 2018 Fahad. All rights reserved.
//

import Foundation
import Firebase

class UserManager {
    
    static var shared = UserManager()
    
    
    weak var delegate: UserManagerDelegate?
    var observer: UInt?
    var currentUser: User? {
        didSet {
            delegate?.userManager(self, didChangeUser: currentUser)
            if observer != nil && currentUser == nil {
                Database.database().reference().removeObserver(withHandle: observer!)
            }
        }
    }
    
    
    
    
    private init() { setupAuthListener() }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] (Auth, user) in
            self?.currentUser = nil
            if let user = user {
                self?.currentUser = User(id: user.uid, name: "", email: "")
                self?.observeDataChange(user.uid)
            }
        }
    }
    
    private func observeDataChange(_ id: String) {
        observer = Database.database().reference().child("Users/\(id)").observe(.value, with: { (snapshot) in
            
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            let user = User(json: json)
            if user.id == "" {
                user.id = snapshot.key
            }
            self.currentUser = user
        }) { (error) in
            print("***UserManager.getDate Error: \(error.localizedDescription)")
        }
    }
    
    func updateUserData() {
        guard let user = currentUser else {
            return
        }
        Database.database().reference().child("Users/\(user.id)").setValue(user.jsonData())
    }
    
}


extension UserManager {
    
    func updateUsers(_ users: [User]) {
        
        var updates: [String:Any] = [:]
        for user in users {
            updates["Users/\(user.id)"] = user.jsonData()
        }
        
        Database.database().reference().updateChildValues(updates) { (error, _) in
            
            if let error = error {
                print("***UserManager.updateUsers Error: \(error.localizedDescription)")
            }
        }
    }
}




protocol UserManagerDelegate: class {
   func userManager(_ userManager: UserManager, didChangeUser user: User?)
}
