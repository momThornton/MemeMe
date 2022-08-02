//
//  Meme.swift
//  MemeMe
//
//  Created by Ashley Thornton on 3/7/22.
//

import Foundation
import UIKit

struct Meme {
    let topText: String
    let bottomText: String
    let originalImage: UIImage
    let memedImage: UIImage
}


class MemeStore {
    
    static let shared: MemeStore = .init()
    
    private var observers = [MemeStoreObserver]()
    
    private var memes = [Meme]()
    
    // MARK: View Modifiers
    
    var count: Int { memes.count }
    
    func save(meme: Meme) {
        self.memes.append(meme)
        self.notifyUpdated()
    }
    
    func meme(at index: Int) -> Meme? {
        guard !memes.isEmpty, count > index else {
            print("meme(at: \(index)) is invalid, count: \(count)")
            return nil
        }
        return self.memes[index]
    }
    
    // MARK: Observer
    
    func register(observer: MemeStoreObserver) {
        self.observers.append(observer)
    }
    
    func unregister(observer: MemeStoreObserver) {
        guard let index = observers.firstIndex(where: { $0 === observer }) else { return }
        observers.remove(at: index)
    }
    
    private func notifyUpdated() {
        observers.forEach { $0.didUpdate(memeStore: self) }
    }
    
}

protocol MemeStoreObserver: AnyObject {
    func didUpdate(memeStore: MemeStore)
}



