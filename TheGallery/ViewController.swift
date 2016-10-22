//
//  ViewController.swift
//  TheGallery
//
//  Created by Vyacheslav Horbach on 14/10/16.
//  Copyright © 2016 Homework Tutor LTD. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var gallery = [Art]()
    var products = [SKProduct]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        updateGallery()
        
        if gallery.count == 0 {
            
            createArt(title: "City", productIdentifier: "", imageName: "pic-3.jpeg", purchased: true)
            createArt(title: "Animal", productIdentifier: "com.gethomeworktutor.TheGallery.tigerart", imageName: "pic-1.jpeg", purchased: false)
            createArt(title: "Forest", productIdentifier: "com.gethomeworktutor.TheGallery.natureart", imageName: "pic-2.jpeg", purchased: false)
            
            updateGallery()
            self.collectionView.reloadData()
        }
        
        requestProducts()
    }
    
    func createArt(title: String, productIdentifier: String, imageName: String, purchased: Bool) {
        let context = getContext()
        
        if let entity = NSEntityDescription.entity(forEntityName: "Art", in: context) {
            
            let art = NSManagedObject(entity: entity, insertInto: context)
            
            art.setValue(title, forKey: "title")
            art.setValue(productIdentifier, forKey: "productIdentifier")
            art.setValue(imageName, forKey: "imageName")
            art.setValue(purchased, forKey: "purchased")
            
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
    
    func unlockArt(productIdentifier: String) {
        for art in self.gallery {
            if art.productIdentifier == productIdentifier {
                art.purchased = true
                
                let context = getContext()
                
                do {
                    try context.save()
                } catch {
                    print(error)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    @IBAction func restoreButtonDidTouch( _sender: AnyObject) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension ViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    // 1. Request products
    func requestProducts() {
        let IDs: Set<String> = ["com.gethomeworktutor.TheGallery.tigerart",  "com.gethomeworktutor.TheGallery.natureart"]
        let productsRequest = SKProductsRequest(productIdentifiers: IDs)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    // 2. Handle response after request - successful x unsuccessful request of products
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Products ready: \(response.products.count)")
        print("Products notready: \(response.invalidProductIdentifiers.count)")
        self.products = response.products
        self.collectionView.reloadData()
    }
    
    // 5. Receive response from Apple what was it about the product
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("purchased")
                unlockArt(productIdentifier: transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                return
            case .failed:
                print("failed")
                SKPaymentQueue.default().finishTransaction(transaction)
                return
            case .restored:
                print("restored")
                unlockArt(productIdentifier: transaction.payment.productIdentifier)
                SKPaymentQueue.default().finishTransaction(transaction)
                return
                
            case .purchasing:
                print("purchasing")
                return
            case .deferred:
                print("deferred")
                return
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let art = gallery[indexPath.item]
        
        guard art.purchased == false else {
            return
        }
        
        for product in products {
            if product.productIdentifier == art.productIdentifier {
                
                //4. Add product to the queue to purchase it
                SKPaymentQueue.default().add(self)
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gallery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ArtCollectionViewCell
        
        let art = gallery[indexPath.item]
        
        
        for subview in cell.artImageView.subviews {
            subview.removeFromSuperview()
        }
        
        switch art.purchased {
        case true:
            cell.purchaseLabel.isHidden = true
            
        case false:
            cell.purchaseLabel.isHidden = false
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            cell.layoutIfNeeded()
            blurView.frame = cell.artImageView.bounds
            cell.artImageView.addSubview(blurView)
            
            for product in self.products {
                if product.productIdentifier == art.productIdentifier {
                    
                    //3. Show products for purchase
                    let formatter = NumberFormatter()
                    formatter.numberStyle = NumberFormatter.Style.currency
                    formatter.locale = product.priceLocale
                    let price = formatter.string(from: product.price)!
                    
                    cell.purchaseLabel.text = "Buy for \(price)"
                }
            }
        }
        
        cell.artImageView.image = UIImage(named: art.imageName!)
        cell.artLabel.text = art.title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.size.width - 80, height: self.collectionView.bounds.size.height - 40)
    }
}

