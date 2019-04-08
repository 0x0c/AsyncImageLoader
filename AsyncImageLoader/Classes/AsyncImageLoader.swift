
//
//  AsyncImageLoader.swift
//  MangaONE2
//
//  Created by Akira Matsuda on 2018/12/25.
//  Copyright © 2018 Link-U. All rights reserved.
//

import UIKit

@objcMembers
open class AsyncLoadOperation : NSObject {
    private let cancelOperation : () -> ()
    
    public init(cancelOperation: @escaping () -> ()) {
        self.cancelOperation = cancelOperation
        super.init()
    }
    
    open func cancel() {
        cancelOperation()
    }
}

private var AssociatedObjectKey: UInt8 = 0
@objc public extension UIImageView {
    
    private var currentOperation: AsyncLoadOperation? {
        get {
            guard let object = objc_getAssociatedObject(self, &AssociatedObjectKey) as? AsyncLoadOperation else {
                return nil
            }
            return object
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func loadAsync(asyncLoader: @escaping ((_ loadCompletionHandler: @escaping ((UIImage) -> Void)) -> AsyncLoadOperation), completionHandler: @escaping (UIImage, UIImageView?) -> Void) -> AsyncLoadOperation {
        if let operation = currentOperation {
            operation.cancel()
        }
        currentOperation = asyncLoader { [weak self] (image) in
            if let weakSelf = self {
                DispatchQueue.main.async {
                    weakSelf.image = image
                    completionHandler(image, weakSelf)
                }
            }
        }
        
        return currentOperation!
    }
}
