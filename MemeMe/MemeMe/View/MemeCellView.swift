//
//  MemeCellView.swift
//  MemeMe
//
//  Created by Ashley Thornton on 8/1/22.
//

import Foundation
import UIKit

class MemeTableCellView: UITableViewCell, Identifiable {
    
    static let id = "memeTableViewCell"
    
    @IBOutlet weak var memeImageView: UIImageView!
    
}

class MemeCollectionViewCell: UICollectionViewCell, Identifiable {
    
    static let id = "memeCollectionViewCell"
    
    
}
