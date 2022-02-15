//
//  GalleryVC.swift
//  DrawPad
//
//  Created by abdul on 30/05/2019.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//

import UIKit

class GalleryVC: UIViewController {
 var image = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()

//      var data =  UserDefaults.standard.object(forKey: "image") as! Data
//      image = UIImage(data: data)!
    
     var  imagenames =  UserDefaults.standard.string(forKey: "imagenames")!
      var names = imagenames.split(separator: " ")
      print(imagenames)
      for a in names
      {
        var data =  UserDefaults.standard.object(forKey: String(a)) as! Data
        image.append(UIImage(data: data)!)
      }
      
        // Do any additional setup after loading the view.
    }
    
  @IBAction func backbtn(_ sender: Any) {
    self.dismiss(animated: false, completion: nil)
  }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension GalleryVC : UICollectionViewDelegate , UICollectionViewDataSource
{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return image.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionviewcell", for: indexPath ) as! collectionviewcell
    cell.img.image = image[indexPath.row]
    return cell
  }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageVC") as! ImageVC
        vc.imagearry = image
        vc.imageindexnumber = indexPath.row
        self.present(vc, animated: true, completion: nil)
    }
  
  
}
class collectionviewcell : UICollectionViewCell
{
  
  @IBOutlet weak var img: UIImageView!
  
  
}
