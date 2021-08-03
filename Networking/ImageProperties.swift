//
//  ImageProperties.swift
//  Networking
//
//  Created by Valera Vasilevich on 3.08.21.
//

import UIKit

struct ImageProperties {
    
    let key: String
    let data: Data
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        guard let data = image.pngData() else { return nil }
        self.data = data
    }
}
