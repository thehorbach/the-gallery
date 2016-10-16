//
//  ViewController.swift
//  TheGallery
//
//  Created by Vyacheslav Horbach on 14/10/16.
//  Copyright © 2016 Homework Tutor LTD. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var gallery = [Art]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        updateGallery()
        
        if gallery.count == 0 {
            createArt(title: "hello", productIdentifier: "", imageName: "", purchased: true)
            createArt(title: "hello", productIdentifier: "", imageName: "", purchased: true)
            createArt(title: "hello", productIdentifier: "", imageName: "", purchased: true)
            
            updateGallery()
            self.collectionView.reloadData()
        }
    }
    
    func createArt(title: String, productIdentifier: String, imageName: String, purchased: Bool) {
        let context = getContext()
        
        if let entity = NSEntityDescription.entity(forEntityName: "Art", in: context) {
            
            let art = NSManagedObject(entity: entity, insertInto: context)
            
            art.setValue(title, forKey: "title")
            art.setValue(productIdentifier, forKey: "productIdentifier")
            art.setValue(imageName, forKey: "imageName")
            art.setValue(purchased.hashValue, forKey: "purchased")
            
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func updateGallery() {
        let context = getContext()
        
        let fetchRequest: NSFetchRequest<Art> = Art.fetchRequest()
        
        do {
            let searchResults = try context.fetch(fetchRequest)
            self.gallery = searchResults
        } catch {
            print(error)
        }
        
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.size.width - 80, height: self.collectionView.bounds.size.height - 40)
    }
}

