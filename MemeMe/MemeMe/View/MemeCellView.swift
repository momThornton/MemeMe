//
//  MemeCellView.swift
//  MemeMe
//
//  Created by Ashley Thornton on 8/1/22.
//

import Foundation
import UIKit

class MemeTableCellView: UITableViewCell, Identifiable {
    
    static let id = "MemeTableCellView"
    
    @IBOutlet weak var memeImageView: UIImageView!
    
}

class MemeCollectionCellView: UICollectionViewCell, Identifiable {
    
    static let id = "MemeCollectionCellView"
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    
}
