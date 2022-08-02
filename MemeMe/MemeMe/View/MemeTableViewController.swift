//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Ashley Thornton on 8/1/22.
//

import Foundation
import UIKit

class MemeTableViewController: UITableViewController, MemeStoreObserver {
   
    private let memeStore = MemeStore.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memeStore.register(observer: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        memeStore.unregister(observer: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { memeStore.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemeTableCellView.id, for: indexPath) as? MemeTableCellView,
              let meme = self.memeStore.meme(at: indexPath.row)
        else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        cell.memeImageView.image = meme.memedImage
        return cell
    }
    
    // MARK: MemeStoreObserver
    
    func didUpdate(memeStore: MemeStore) {
        self.tableView.reloadData()
    }
    
}

class MemeCollectionViewController: UICollectionViewController, MemeStoreObserver {
    
    private let memeStore = MemeStore.shared
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure(flowLayout: flowLayout)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memeStore.register(observer: self)
        collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        memeStore.unregister(observer: self)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { memeStore.count }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MemeCollectionCellView.id, for: indexPath) as? MemeCollectionCellView,
              let meme = self.memeStore.meme(at: indexPath.row)
        else {
            return UICollectionViewCell()
        }
        cell.memeImageView.image = meme.memedImage
        return cell
    }
    
    private func configure(flowLayout: UICollectionViewFlowLayout) {
        let spacing: (row: CGFloat, col: CGFloat) = (row: 3, col: 3)
        let (width, height) = (self.view.frame.size.width, self.view.frame.size.height)
        let shorterDimension = min(width, height)
        let dimension = (shorterDimension - (2 * spacing.row)) / spacing.col
        
        flowLayout.minimumInteritemSpacing = spacing.col
        flowLayout.minimumLineSpacing = spacing.col
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    // MARK: MemeStoreObserver
    
    func didUpdate(memeStore: MemeStore) {
        self.collectionView.reloadData()
    }
}
