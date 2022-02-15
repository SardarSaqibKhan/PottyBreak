//
//  AllContactsVC.swift
//  PottyBreak
//
//  Created by MacBook Pro on 09/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class AllContactsVC: UIViewController {

    @IBOutlet weak var allContactTableView:UITableView!
    @IBOutlet weak var searchcontactSearchBar: UISearchBar!
    
    var chats: [Chat] = []
    var users = [User]()
    var usersCopy: [User] = []
    var toID:String?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllUsers()
        //setupNavBar()
        
        users = users.filter { $0.id != UserManager.shared.currentUser!.id}
        usersCopy = users
        allContactTableView.rowHeight = 63
      //  tableView.tableFooterView = UIView()
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
            self?.allContactTableView.reloadData()
        }) { (error) in
            print(("***AllContactsTableViewController.loadAllUsers Error: \(error.localizedDescription)"))
        }
    }
    
    
    

}
extension AllContactsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AllContactTableViewCell
        let user = users[indexPath.row]
 
        cell.titleLabel.text = user.name
        cell.detailLabel.text = user.email
        cell.profileImageView.sd_setShowActivityIndicatorView(true)
        cell.profileImageView.image = nil
        
        if let urlString = user.photoUrl {
            cell.profileImageView.sd_setImage(with: URL(string: urlString))
        }else{
            cell.profileImageView.image = UIImage(named: "avatar")
        }
        
        if let id = toID
        {
            if user.id == id
            {
                toID = nil
                cell.titleLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                cell.detailLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            }
        }
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.height/2
        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
///// segue preparing
extension AllContactsVC{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
            
        case "Show MyChat VC":
            // self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            let Nav = segue.destination as! UINavigationController
            let dastination = Nav.viewControllers.first as! MyChatViewController
            let data = sender as! (Chat, User)
            
            dastination.partnerUser = data.1
            dastination.chat = data.0
     
        default:
            break
        }
    }
}
extension AllContactsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let text = searchText.trimmingCharacters(in: [" "]).lowercased()
        if text == "" {
            users = usersCopy
        } else {
            users = usersCopy.filter { $0.email.lowercased().contains(text) || $0.name.lowercased().contains(text)}
        }
        allContactTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
///// unwind segues
extension AllContactsVC{
    @IBAction func unwindtoAllContacts(segue:UIStoryboardSegue){
        print("hello")
    }
}
class AllContactTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var detailLabel:UILabel!
    
}
