//
//  ChatTableViewController.swift
//  Chat App
//
//  Created by fahad on 27/11/2018.
//  Copyright © 2018 Fahad. All rights reserved.
//

import UIKit
import Firebase

class ChatTableViewController: UITableViewController {
    
    @IBOutlet weak var textFieldMessage: UITextField!
    
    var chat: Chat! { didSet { getChatHistory() } }
    var partnerUser: User!
    let currentUser = UserManager.shared.currentUser!
    
    var messages: [Message] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        setupNavbar()
        
    }
    
    private func setupNavbar() {
        
        let sendButton = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(buttonSendTapped))
        navigationItem.rightBarButtonItem = sendButton
    }
    
    @objc private func buttonSendTapped() {
        let message = Message(id: "", toId: partnerUser.id, fromId: currentUser.id, message: textFieldMessage.text!, timeStamp: Date().timeIntervalSince1970, chatId: chat.id)
        message.id = Database.database().reference().child("ChatMessages/\(chat.id)").childByAutoId().key!

        if chat.lastMessage == "" {
            // new chat. Add it to users chatIds
            currentUser.addChatID(key: partnerUser.id, value: chat.id)
            partnerUser.addChatID(key: currentUser.id, value: chat.id)

            UserManager.shared.updateUsers([currentUser, partnerUser])
        }
        chat.lastMessage = message.message
        chat.timeStamp = message.timeStamp
        Database.database().reference().child("Chats/\(chat.id)").setValue(chat.jsonData()) { (error, _) in
            
            if let error = error {
                print("***ChatTableViewController.buttonSendTapped Error: \(error.localizedDescription)")
            }
        }
//        chat.lastMessage = message.id
        Database.database().reference().child("ChatMessages/\(chat.id)/\(message.id)").setValue(message.jsonData())
    }
    
    private func getChatHistory() {
        
        Database.database().reference().child("ChatMessages/\(chat.id)/").observe(.childAdded, with: { (snapshot) in
            
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            let message = Message(json: json)
            if message.id == "" {
                message.id = snapshot.key
            }
            
            self.messages.insert(message, at: 0)
            self.tableView.reloadData()
//            self.tableView.reloadRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .fade)
        }) { (error) in
            print("***ChatTableViewController.getChatHistory Error: \(error.localizedDescription)")
        }
    }

    
}


// MARK: - Table View delegate
extension ChatTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.message
        cell.detailTextLabel?.text = "\(message.timeStamp)"
        cell.contentView.backgroundColor = message.fromId == currentUser.id ? .white : .lightGray
        
        return cell
    }
}
