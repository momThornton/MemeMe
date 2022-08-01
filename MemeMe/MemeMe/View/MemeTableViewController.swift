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
//        cell.memeImageView.image = UIImage(systemName: "hare")
        cell.memeImageView.image = meme.memedImage
        return cell
    }
    
    // MARK: MemeStoreObserver
    
    func didUpdate(memeStore: MemeStore) {
        self.tableView.reloadData()
    }
    
}
