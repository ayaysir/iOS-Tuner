//
//  InAppProduct.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/18.
//

import Foundation

public struct InAppProducts {
    private init() {}
    
    public static let product = "IAP.Tuner.Basic.1"
    private static let productIdentifiers: Set<ProductIdentifier> = [InAppProducts.product]
    public static let store = IAPHelper(productIds: InAppProducts.productIdentifiers)
}
