//
//  MyChatViewController.swift
//  Chat App
//
//  Created by fahad on 28/11/2018.
//  Copyright © 2018 Fahad. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import MessageInputBar


 let  mypopVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StartChatWithFriend") as! StartChatWithFriend


class MyChatViewController: MessagesViewController {
    
    var chat: Chat! { didSet { getChatHistory() } }
    var partnerUser: User!
    let currentUser = UserManager.shared.currentUser!
    
    var messages: [Message] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.title = partnerUser?.name ?? ""
       // postToken()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        (messagesCollectionView.inputAccessoryView as? MessageInputBar)?.delegate = self
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.videoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.videoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.locationMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.locationMessageSizeCalculator.incomingAvatarSize = .zero
            layout.emojiMessageSizeCalculator.incomingAvatarSize = .zero
            layout.emojiMessageSizeCalculator.outgoingAvatarSize = .zero
        }
        
        addKeyboardNotifications()
       fixNavStackOrder()
    }
    
       private func addKeyboardNotifications() {
                        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppearanceChanged(notification:)),
                                                                                                                                                                     name:UIResponder.keyboardDidHideNotification, object: nil)
                        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppearanceChanged(notification:)),
                                                                                                                                                                     name: UIResponder.keyboardDidShowNotification,object: nil)
                }
    
    private func fixNavStackOrder() {
        if let index = navigationController?.viewControllers.firstIndex(where: {$0 is AllContactsVC}) {
            var vcs = navigationController!.viewControllers
            vcs.remove(at: index)
            navigationController?.viewControllers = vcs
        }
    }
    
    @objc func keyboardAppearanceChanged(notification: Notification) {
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
    
    private func buttonSendTapped(_ text: String) {
        let message = Message(id: "", toId: partnerUser.id, fromId: currentUser.id, message: text, timeStamp: Date().timeIntervalSince1970, chatId: chat.id)
        message.id = Database.database().reference().child("ChatMessages/\(chat.id)").childByAutoId().key!
        
        if chat.lastMessage == "" {
            // new chat. Add it to users chatIds
            currentUser.addChatID(key: partnerUser.id,value: chat.id)
            partnerUser.addChatID(key: currentUser.id,value: chat.id)
            
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
      //  chat.id = "-LbYEe6elNOtLsX3wpy-"
     
        Database.database().reference().child("ChatMessages/\(chat.id)/").observe(.childAdded, with: { (snapshot) in
            
            guard let json = snapshot.value as? [String:Any] else {
                return
            }
            
            let message = Message(json: json)
            if message.id == "" {
                message.id = snapshot.key
            }
            
            self.messages += [ message ]
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom(animated: true)
            //            self.tableView.reloadRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .fade)
        }) { (error) in
            print("***ChatTableViewController.getChatHistory Error: \(error.localizedDescription)")
        }
    }
    
    
    
    
    
    
    
    @IBAction func Done(_ sender: Any) {

        
        self.performSegue(withIdentifier: "animationsegue", sender: nil)
        //self.dismiss(animated: true, completion: nil)
        
//        let date = Date().addingTimeInterval(5)
//        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(MyChatViewController.runCode), userInfo: nil, repeats: false)
//        RunLoop.main.add(timer, forMode: .common)
//        showAndicator()
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "animationsegue"{
            let desti = segue.destination as! StartChatWithFriend
            desti.animationDelegat = self
        }
    }
    
    
  
    
    
    func showAndicator(){
        
       
        mypopVC.animationDelegat = self
        self.addChild(mypopVC)
        mypopVC.view.frame = self.view.frame
        self.view.addSubview(mypopVC.view)
        mypopVC.didMove(toParent: self)
    }
    func removeAndicator(){
        // popVC.removeFromParentViewController()
         mypopVC.stopAnimation()
        mypopVC.view.removeFromSuperview()
       // self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}



// MARK: - Message data source
extension MyChatViewController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return Sender(id: currentUser.id, displayName: currentUser.name)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}


// MARK: - Message Input Bar delegate
extension MyChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = text.trimmingCharacters(in: [" "])
        if message == "" {
            return
        }
        buttonSendTapped(message)
        inputBar.inputTextView.text = ""
    }
}

extension MyChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
}


extension MyChatViewController:AnimationProtocol{
    func removeAnimation() {
        // self.navigationController?.popViewController(animated: true)
//        let vc = storyboard?.instantiateViewController(withIdentifier: "AllContactsVC") as! AllContactsVC
//        self.navigationController?.show(vc, sender: vc.self)
        
        DispatchQueue.main.async {
            
          self.dismiss(animated: false, completion: nil)
        }
     
       // self.dismiss(animated: true, completion: nil)
        
    }
   
}
////////Delegate for animation
protocol AnimationProtocol:class {
    func removeAnimation()
}
