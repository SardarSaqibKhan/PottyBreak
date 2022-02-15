//
//  RateABathroomVC.swift
//  PottyBreak
//
//  Created by abdul on 02/04/2019.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage
import CoreLocation

class RateABathroomVC: UIViewController {
    
    @IBOutlet weak var bathroomTitleLabel: UILabel!
    // @IBOutlet weak var ReviewTextFeild: UITextView!
    @IBOutlet weak var Submitbtn: UIButton!
    // @IBOutlet weak var UploadPhotobtn: UIButton!
    @IBOutlet weak var ratingoneImage: UIImageView!
    @IBOutlet weak var ratingtwoImage: UIImageView!
    @IBOutlet weak var ratingthreeImage: UIImageView!
    @IBOutlet weak var ratingfourImage: UIImageView!
    
    @IBOutlet weak var wheelchairimage: UIImageView!
    @IBOutlet weak var wheelchairLabel: UILabel!
    
    @IBOutlet weak var changingstationimage: UIImageView!
    @IBOutlet weak var changingStationLabel: UILabel!
    
    @IBOutlet weak var waterfountainimage: UIImageView!
    @IBOutlet weak var waterFountainLabel: UILabel!
    
    
    @IBOutlet weak var wifiaccessimage: UIImageView!
    @IBOutlet weak var wifiLabel: UILabel!
    
    @IBOutlet weak var familybathroomimage: UIImageView!
    @IBOutlet weak var familyLabel: UILabel!
    
    @IBOutlet weak var uploadedphotoCollectionView: UICollectionView!
    @IBOutlet weak var tumbsupDownbackgroundView:UIView!
    
    
    
    var bathroomid:String?
    var location:String?
    var totatRatedUser:Int  = 0
    var rating = Double()
    var currentUserRating = Double()
    var ref: DatabaseReference!
    var services = ["WheelChair":false,"Fontain":false,"Stations":false,"Wifi":false,"Family":false]
    var uploadingImage:UIImage?
    var uploadingImagesArray = [UIImage]()
    var washroomTitle = String()
    var placeholderLabel : UILabel!
    
    //@IBOutlet weak var questioniareView: UIView!
    @IBOutlet weak var thumbsUpImageView: UIImageView!
    @IBOutlet weak var thumbsDownImageView: UIImageView!
    @IBOutlet weak var qustionNavigationBar: UINavigationBar!
    
    var questionNumber = 0;
    var questions = ["Toilet Paper Quality","Cleanliness","Soap Quality","Hand Dryer","Waste Can"]
    var answers = ["Skip","Skip","Skip","Skip","Skip"]
    @IBOutlet weak var questionTitleItem: UINavigationItem!
    ////after integration
    var recivingMarker:customMarker?
    var ratings:Double?
    var numberofuser:Int?
    var bathroomID=String()
    let storageRef = StorageReference()
    let greenColor = UIColor.init(red: 34/255, green: 168/255, blue: 2/255, alpha: 1)
    let redColor = UIColor.init(red: 145/255, green: 4/255, blue: 4/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ref = Database.database().reference()
        
        
        bathroomID = (recivingMarker?.id)!
        bathroomTitleLabel.text = self.recivingMarker?.snippet!;
        print(bathroomID)
        
        ratingoneImage.customCheckBoxs()
        ratingtwoImage.customCheckBoxs()
        ratingthreeImage.customCheckBoxs()
        ratingfourImage.customCheckBoxs()
        wheelchairimage.customCheckBoxs()
        changingstationimage.customCheckBoxs()
        waterfountainimage.customCheckBoxs()
        wifiaccessimage.customCheckBoxs()
        familybathroomimage.customCheckBoxs()
        Submitbtn.carveButton()
        // UploadPhotobtn.carveButton()
        uploadedphotoCollectionView.hightLightBorder()
        
        //ReviewTextFeild.text = ""
        settingTapGesturseOnRatingImages()
        settingOnReviewTextView()
        //abdul commment this
        
        //stylingQuestioniare()
        tumbsupDownbackgroundView.carveViewborder()
        
    }
    
    func checkRatingFlags()
    {
        if let id = UserDefaults.standard.string(forKey: "placeID")
        {
            if id == recivingMarker?.id
            {
                UserDefaults.standard.set(nil, forKey: "placeID")
            }
        }
    }
    @IBAction func submit(_ sender: Any) {
        checkRatingFlags();
        let latitude = UserDefaults.standard.value(forKey: "UserCurrentLatitude") as? CLLocationDegrees ?? (37.773972)
        let longitude = UserDefaults.standard.value(forKey: "UserCurrentLongitude") as? CLLocationDegrees ?? CLLocationDegrees(-122.431297)
        let address =  UserDefaults.standard.value(forKey: "UserCurrentAddress") as? String ?? "San Francisco"
        print(latitude)
        print(longitude)
        print(address)
        var userLocation = CLLocation(latitude: latitude, longitude: longitude)
        var washroomLocation = CLLocation(latitude: (recivingMarker?.position.latitude)!, longitude: (recivingMarker?.position.longitude)!)
        var meters = washroomLocation.distance(from: userLocation)
        if meters < 1000
        {
            print("More than 25")
            if let id = Auth.auth().currentUser?.uid
            {
                
                Database.database().reference().child("Users").child("\(id)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let json1 = snapshot.value as? [String: Any]
                    if let user = json1
                    {
                        
                        
                        var score = 25 + (user["score"] as? Int ?? 0);
                        
                        
                        Database.database().reference().child("Users").child("\(id)").child("score").setValue(score);
                        self.calculateRating()
                    }
                })
            }
        }
        else
        {
            print("Less Than 25")
            print(Auth.auth().currentUser?.uid)
            calculateRating()
        }
        
        
    }
    
    
    func setColor(answer:String)
    {
        
        switch answer {
        case "Yes":
            thumbsUpImageView.tintColor = greenColor
            thumbsDownImageView.tintColor = UIColor.white
            break;
        case "No":
            thumbsUpImageView.tintColor = UIColor.white
            thumbsDownImageView.tintColor = redColor
            break;
        default:
            thumbsUpImageView.tintColor = UIColor.white
            thumbsDownImageView.tintColor = UIColor.white
        }
        
    }
    func next()
    {
        if questionNumber == 0
        {
            // questionPreviousItem.title = "Previous"
        }
        if questionNumber < 4
        {
            questionNumber += 1
        }
        if questionNumber == 4
        {
            // questionNextItem.title = ""
            questionTitleItem.title = questions[4]
            setColor(answer: answers[4])
        }
        else
        {
            
            questionTitleItem.title = questions[questionNumber]
            
            setColor(answer: answers[questionNumber])
            
        }
    }
    
    @IBAction func uploadPhoto(_ sender: Any) {
        if uploadingImagesArray.count == 3
        {
            AlertMessage(message: "You can Upload 5 Images at a time")
            return
        }
        Action_Sheet()
    }
}
extension RateABathroomVC: UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
        
        //       if ReviewTextFeild.textColor == UIColor.lightGray {
        //            textView.text = nil
        //            textView.textColor = UIColor.black
        //    }
    }
}

//////////setting Gestures on Rating images
extension RateABathroomVC{
    
    func settingTapGesturseOnRatingImages(){
        let tap1 = ratingGesture(target: self, action: #selector(RateABathroomVC.handleTap(_:)))
        ratingoneImage.addGestureRecognizer(tap1)
        tap1.id = 0
        let tap2 = ratingGesture(target: self, action: #selector(RateABathroomVC.handleTap(_:)))
        ratingtwoImage.addGestureRecognizer(tap2)
        tap2.id = 1
        let tap3 = ratingGesture(target: self, action: #selector(RateABathroomVC.handleTap(_:)))
        ratingthreeImage.addGestureRecognizer(tap3)
        tap3.id = 2
        let tap4 = ratingGesture(target: self, action: #selector(RateABathroomVC.handleTap(_:)))
        ratingfourImage.addGestureRecognizer(tap4)
        tap4.id = 3
        
        /////// for accessabilities
        
        let tap5 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        let tap55 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        wheelchairimage.addGestureRecognizer(tap5)
        wheelchairLabel.addGestureRecognizer(tap55)
        tap5.id = 4
        tap55.id = 4
        
        
        let tap6 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        let tap66 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        
        changingstationimage.addGestureRecognizer(tap6)
        changingStationLabel.addGestureRecognizer(tap66)
        tap6.id = 5
        tap66.id = 5
        
        let tap7 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        let tap77 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        waterfountainimage.addGestureRecognizer(tap7)
        waterFountainLabel.addGestureRecognizer(tap77)
        tap7.id = 6
        tap77.id = 6
        
        let tap8 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        let tap88 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        wifiaccessimage.addGestureRecognizer(tap8)
        wifiLabel.addGestureRecognizer(tap88)
        tap8.id = 7
        tap88.id = 7
        
        let tap9 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        thumbsUpImageView.addGestureRecognizer(tap9)
        tap9.id = 8
        
        let tap10 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        thumbsDownImageView.addGestureRecognizer(tap10)
        tap10.id = 9
        
        let tap11 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        let tap111 = ratingGesture(target: self, action: #selector(RefineSearchVC.handleTap(_:)))
        familybathroomimage.addGestureRecognizer(tap11)
        familyLabel.addGestureRecognizer(tap111)
        tap11.id = 10
        tap111.id = 10
        
    }
    
    @objc func handleTap(_ sender: ratingGesture) {
        let id = sender.id!
        
        if id == 0 {
            self.currentUserRating = 2.0
            ratingoneImage.image = UIImage(named: "checkmark")
            ratingtwoImage.image = UIImage(named: "")
            ratingthreeImage.image = UIImage(named: "")
            ratingfourImage.image = UIImage(named: "")
        }
        else if id == 1
        {
            self.currentUserRating = 3.0
            ratingoneImage.image = UIImage(named: "")
            ratingtwoImage.image = UIImage(named: "checkmark")
            ratingthreeImage.image = UIImage(named: "")
            ratingfourImage.image = UIImage(named: "")
        }
        else if id == 2{
            self.currentUserRating = 4.0
            ratingoneImage.image = UIImage(named: "")
            ratingtwoImage.image = UIImage(named: "")
            ratingthreeImage.image = UIImage(named: "checkmark")
            ratingfourImage.image = UIImage(named: "")
        }
        else if id == 3{
            self.currentUserRating = 5.0
            ratingoneImage.image = UIImage(named: "")
            ratingtwoImage.image = UIImage(named: "")
            ratingthreeImage.image = UIImage(named: "")
            ratingfourImage.image = UIImage(named: "checkmark")
        }
            
        else if id == 4{
            if wheelchairimage.image == UIImage(named: "checkmark"){
                wheelchairimage.image = UIImage(named: "")
                services["WheelChair"] = false
            }
            else{
                wheelchairimage.image = UIImage(named: "checkmark")
                services["WheelChair"] = true
            }
            
        }
        else if id == 5{
            
            
            if changingstationimage.image == UIImage(named: "checkmark"){
                changingstationimage.image = UIImage(named: "")
                services["Stations"] = false
            }
            else{
                changingstationimage.image = UIImage(named: "checkmark")
                services["Stations"] = true
            }
            
        }
        else if id == 6{
            
            
            if waterfountainimage.image == UIImage(named: "checkmark"){
                waterfountainimage.image = UIImage(named: "")
                services["Fontain"] = false
            }
            else{
                waterfountainimage.image = UIImage(named: "checkmark")
                services["Fontain"] = true
            }
            
            
        }
        else if id == 7{
            if wifiaccessimage.image == UIImage(named: "checkmark"){
                wifiaccessimage.image = UIImage(named: "")
                services["Wifi"] = false
            }
            else{
                wifiaccessimage.image = UIImage(named: "checkmark")
                services["Wifi"] = true
            }
            
        }
        else if id == 10
        {
            if familybathroomimage.image == UIImage(named: "checkmark"){
                familybathroomimage.image = UIImage(named: "")
                services["Family"] = false
            }
            else{
                familybathroomimage.image = UIImage(named: "checkmark")
                services["Family"] = true
            }
        }
        else if id == 8 // Thumbs up
        {
            
            thumbsDownImageView.tintColor = UIColor.white
            if answers[questionNumber] == "Yes"
            {
                answers[questionNumber] = "Skip"
                thumbsUpImageView.tintColor = UIColor.white
            }
            else
            {
                thumbsUpImageView.tintColor = greenColor
                answers[questionNumber] = "Yes"
            }
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (t) in
                self.next();
                print(self.questionNumber)
            })
            
        }
        else //thumbs down
        {
            thumbsUpImageView.tintColor = UIColor.white
            if answers[questionNumber] == "No"
            {
                answers[questionNumber] = "Skip"
                thumbsDownImageView.tintColor = UIColor.white
            }
            else
            {
                thumbsDownImageView.tintColor = redColor
                answers[questionNumber] = "No"
            }
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (t) in
                self.next();
                print(self.questionNumber)
            })
            
        }
        print(services)
    }
}
//class ratingGesture: UITapGestureRecognizer {
//    var id:Int?
//}
////////////Calculating and submit the rating to the database
extension RateABathroomVC{
    func calculateRating(){
        var totaluser = 0
        var newRatings = 0.0
        if let NOU = numberofuser
        {
            totaluser = NOU + 1
            newRatings = ((ratings!*Double(NOU)) + currentUserRating)/Double((totaluser))
        }
        else
        {
            totaluser = 1;
            newRatings = currentUserRating
        }
        
        
        addNewRating(newrating: newRatings, newtotaluser: totaluser)
    }
    
    func addNewRating(newrating:Double,newtotaluser:Int){
        if currentUserRating == 0.0{
            UIAlertView(title: "", message: "Rating Required", delegate: self, cancelButtonTitle: "Okay").show()
        }
        else{
            ref.child("Ratings").child(bathroomID).child("Total_Number_of_USer").setValue(newtotaluser)
            ref.child("Ratings").child(bathroomID).child("rating").setValue(newrating)
            ref.child("Ratings").child(bathroomID).child("Services").setValue(services)
            ref.child("Ratings").child(bathroomID).child("Answers").setValue(answers)
            UIAlertView(title: "Thank You", message: "Review Submitted", delegate: self, cancelButtonTitle: "Okay").show()
            self.navigationController?.popViewController(animated: true)
        }
    }
    func gettingDataById(){
        ref.child("Ratings").child(self.bathroomid!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.rating = value?["rating"] as? Double ?? 0.0
            self.totatRatedUser = value?["Total_Number_of_USer"] as? Int ?? 0
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
//// collection view datasourse and delegate
extension RateABathroomVC:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return uploadingImagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! RateABathroomCollectionViewCell
        cell.uploadedImage.image = uploadingImagesArray[indexPath.row]
        return cell
    }
    
}

//////// uploading image from gallery as well as camera
extension RateABathroomVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func Action_Sheet()
    {
        
        let actionsheet = UIAlertController(title: "", message: "Please Select Image Sourse", preferredStyle: .actionSheet)
        
        actionsheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
            
            self.Selected_choise(choise: "gallery")
            
        }))
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            
            self.Selected_choise(choise: "camera")
            
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionsheet,animated: true,completion: nil)
        
    }
    
    func Selected_choise(choise:String)
    {
        
        let image = UIImagePickerController()
        
        if choise == "gallery"
        {
            
            
            image.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            image.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        else
        {
            if  UIImagePickerController.isSourceTypeAvailable(.camera)
            {
                image.sourceType = UIImagePickerController.SourceType.camera
                camera()
                
            }
            else
            {
                self.AlertMessage(message: "Sorry Camera is not avilable in Simulator..")
            }
            
        }
        
        image.allowsEditing = false
        self.present(image, animated: true)
    }
    func camera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            DispatchQueue.global(qos: .userInteractive).async {
                DispatchQueue.main.async {
                    self.uploadingImage = image
                    self.uploadingImagesArray.append(self.uploadingImage!)
                    self.uploadedphotoCollectionView.reloadData()
                    self.newuploading()
                }
            }
        }
        else
        {
            if let image = info[.editedImage] as? UIImage
            {
                self.uploadingImagesArray.append(image)
                self.uploadedphotoCollectionView.reloadData()
            }
            else
            {
                print("nil \n no photo")
            }
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func AlertMessage(message:String)
    {
        
        let alert = UIAlertController.init(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert,animated: true,completion: nil)
    }
}

////////////uploading image on firebase
////////////uploading image on firebase
extension RateABathroomVC{
    
    
    /////resizing image
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height *  heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func newuploading(){
        // Data in memory
        self.showAndicator()
        if self.uploadingImage != nil{
            let image = resizeImage(image: self.uploadingImage!, targetSize: CGSize(width: 100, height: 100))
            let randomnumber = Int.random(in: 1000...10000000)
            
            var data = Data()
            data = image.pngData()!
            // Create a reference to the file you want to upload
            let riversRef = storageRef.child("BathroomImages/\(self.bathroomID)/\(randomnumber).jpg")
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                // You can also access to download URL after upload.
                riversRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    
                    Database.database().reference().child("Ratings").child("\(self.bathroomID)").child("imageUrls").child("\(randomnumber)").setValue(url!.absoluteString)
                    
                    self.removeAndicator()
                    self.AlertMessage(message: "Uploaded Successfully")
                }
            }
            
        }
        else{
            
        }
    }
    
}
extension RateABathroomVC {
    
    func settingOnReviewTextView(){
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
extension RateABathroomVC{
    func showAndicator(){
        
        self.addChild(popVC)
        popVC.view.frame = self.view.frame
        self.view.addSubview(popVC.view)
        popVC.didMove(toParent: self)
    }
    func removeAndicator(){
        // popVC.removeFromParentViewController()
        popVC.view.removeFromSuperview()
    }
}

class RateABathroomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var uploadedImage: UIImageView!
    override func awakeFromNib() {
        uploadedImage.customCheckBoxs()
    }
}
struct questions{
    var Question = String();
    
}

