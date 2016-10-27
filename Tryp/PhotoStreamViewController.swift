//
//  PhotoStreamViewController.swift
//  RWDevCon
//
//  Created by Mic Pringle on 26/02/2015.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
import AVFoundation

var imagesDirectoryPath:String!
var images:[UIImage]!
var titles:[String]!

class PhotoStreamViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  var photos = Photo.allPhotos()
  
    @IBAction func addPhoto(_ sender: AnyObject) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true, completion: nil)
    }
    
    @IBAction func myTrips(_ sender: AnyObject) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // Save image to Document directory
        var imagePath = Date().description
        imagePath = imagePath.replacingOccurrences(of: " ", with: "")
        imagePath = imagesDirectoryPath + "/\(imagePath).png"
        let data = UIImagePNGRepresentation(image)
        let success = FileManager.default.createFile(atPath: imagePath, contents: data, attributes: nil)
        dismiss(animated: true) { () -> Void in
            self.refreshTable()
        }
    }

    func refreshTable(){
        do{
            images.removeAll()
            titles = try FileManager.default.contentsOfDirectory(atPath: imagesDirectoryPath)
            for image in titles{
                let data = FileManager.default.contents(atPath: imagesDirectoryPath + "/\(image)")
                let image = UIImage(data: data!)
                images.append(image!)
            }
            self.collectionView?.reloadData()
        }catch{
            print("Error")
        }
    }
    
    
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
    
    override func viewWillAppear(_ animated: Bool) {
        images = []
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        imagesDirectoryPath = documentDirectorPath + "/ImagePicker"
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory:&objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }

        
        self.refreshTable()
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    // Set the PinterestLayout delegate
    if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
      layout.delegate = self
    }
    collectionView!.backgroundColor = UIColor.clear
    collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
  }
  
}

extension PhotoStreamViewController {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnnotatedPhotoCell", for: indexPath) as! AnnotatedPhotoCell
    
    let photo = Photo(caption: titles[(indexPath as NSIndexPath).item], comment: "", image: images[(indexPath as NSIndexPath).item])
    photo.image = images[(indexPath as NSIndexPath).item]
    photo.caption = titles[(indexPath as NSIndexPath).item]
    
    cell.photo = photo
    return cell
  }
  
}

extension PhotoStreamViewController : PinterestLayoutDelegate {
  // 1. Returns the photo height
  func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath , withWidth width:CGFloat) -> CGFloat {
    let photo = photos[(indexPath as NSIndexPath).item]
    let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
    let rect  = AVMakeRect(aspectRatio: photo.image.size, insideRect: boundingRect)
    return rect.size.height
  }
  
  // 2. Returns the annotation size based on the text
  func collectionView(_ collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
    let annotationPadding = CGFloat(4)
    let annotationHeaderHeight = CGFloat(17)
    
    let photo = photos[(indexPath as NSIndexPath).item]
    let font = UIFont(name: "AvenirNext-Regular", size: 10)!
    let commentHeight = photo.heightForComment(font, width: width)
    let height = annotationPadding + annotationHeaderHeight + commentHeight + annotationPadding
    return height
  }
}

