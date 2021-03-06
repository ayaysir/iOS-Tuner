//
//  InAppProduct.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/18.
//

import Foundation

public struct InAppProducts {
    public static let product = "com.bgsmm.Tuner.removeAllAds"
    private static let productIdentifiers: Set<ProductIdentifier> = [InAppProducts.product]
    public static let store = IAPHelper(productIds: InAppProducts.productIdentifiers)
}
