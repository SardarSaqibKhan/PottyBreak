//
//  NewMessageTableViewController.swift
//  GameOfChats
//
//  Created by Fahad Masood on 05/08/2017.
//  Copyright © 2017 Fahad Masood. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class AllContactsTableViewController: UITableViewController {

    var chats: [Chat] = []
    
    var users = [User]()
    var usersCopy: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        loadAllUsers()
        users = users.filter { $0.id != UserManager.shared.currentUser!.id}
        usersCopy = users
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    private func setupNavBar() {
      //  title = "New Message"
    //    navigationItem.hidesBackButton = true
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonPressed))
    }
    func myUser(id:String)
    {
        Database.database().reference(withPath: "Users").child("\(id)").observe(.value) { (snapshot) in
            let json = snapshot.value as! [String: Any]
            UserManager.shared.currentUser = User(json: json)
            
        }
    }
    private func loadAllUsers() {
        if let uid = Auth.auth().currentUser?.uid
        {
          myUser(id: uid)
            print(uid)
        }
        else{
        myUser(id: "943289348dkfjd")
        }
        
        Database.database().reference().child("Users").observeSingleEvent(of: DataEventType.value, with: { [weak self] (snapshot) in
            
            guard let usersData = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            for snap in usersData {
                let user = User(json: snap.value as! [String:Any])
                if user.id == "" {
                    user.id = snap.key
                }
                if user.id != UserManager.shared.currentUser!.id {
                    self?.users += [ user ]
                }
            }
            self!.usersCopy = self!.users
            self?.tableView.reloadData()
        }) { (error) in
            print(("***AllContactsTableViewController.loadAllUsers Error: \(error.localizedDescription)"))
        }
    }
    
    @objc func cancelBarButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
       
        case "Show MyChat VC":
           // self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            let chatVC = segue.destination as! MyChatViewController
            let data = sender as! (Chat, User)
            
            chatVC.partnerUser = data.1
            chatVC.chat = data.0
           
        default:
            break
        }
    }

}



// MARK: - Table view data source
extension AllContactsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserDetailsTableViewCell
        let user = users[indexPath.row]
        cell.titleLabel.text = user.name
        cell.detailLabel.text = user.email
        cell.profileIImageView.sd_setShowActivityIndicatorView(true)
        cell.profileIImageView.image = nil
        
        if let urlString = user.photoUrl {
            cell.profileIImageView.sd_setImage(with: URL(string: urlString))
        }else{
             cell.profileIImageView.image = UIImage(named: "avatar")
        }
        
        cell.profileIImageView.layer.cornerRadius = cell.profileIImageView.frame.height/2
        return cell
    }
}


// MARK: - Table view delegate
extension AllContactsTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userId = users[indexPath.row].id
        var path = "Users/\(UserManager.shared.currentUser!.id)/chatIds/\(userId)/"
        Database.database().reference().child(path).observe(.value) { (snapshot) in
            let chatID = snapshot.value as? String
            if let CID = chatID{
                Database.database().reference().child("Chats/\(CID)/").observe(.value) { (snapshot) in
                    let json = snapshot.value as! [String:Any]
                    let chat = Chat(json: json)
                    chat.id = CID;
                    self.performSegue(withIdentifier: "Show MyChat VC", sender: (chat, self.users[indexPath.row]))
                }
            }
            else
            {
                let newId = Database.database().reference().child("Chats").childByAutoId().key!
                var chat = Chat(id: newId, user1Id: UserManager.shared.currentUser!.id, user2Id: userId, lastMessageId: "", timeStamp: 0)
                self.performSegue(withIdentifier: "Show MyChat VC", sender: (chat, self.users[indexPath.row]))
            }
            
           }
    
       
    }
}



// MARK: - Search Bar delegate
extension AllContactsTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let text = searchText.trimmingCharacters(in: [" "]).lowercased()
        if text == "" {
            users = usersCopy
        } else {
            users = usersCopy.filter { $0.email.lowercased().contains(text) || $0.name.lowercased().contains(text)}
        }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
extension AllContactsTableViewController{
    
//    @IBAction func unwindtoAllContacts(segue:UIStoryboardSegue){
//        print("hello")
//    }
}
