# LxIAPManager
*	Apple IAP capsulation.

### Installation
    You only need drag LxIAPManager.swift to your project.

### Support
    Minimum support iOS version: iOS 7.0

### Usage

	//	First, implement LxIAPManager protocol in your class.

	let iapEnable = LxIAPManager.iapEnable()
    let transactionReceipt = LxIAPManager.transactionReceipt()
        
    LxIAPManager.defaultManager().delegate = self
	LxIAPManager.defaultManager().fetchProductsByIdentifiers([PRODUCT_IDENTIFIER_1, PRODUCT_IDENTIFIER_2]);
	LxIAPManager.defaultManager().purchaseProductWithIdentifier(PRODUCT_IDENTIFIER_2)
    
    //MARK: - protocol method
    
    func iapManager(iapManager: LxIAPManager, didFetchedProductArray productArray: [SKProduct]) {
        //  fetched valid product info.
    }
    
    func iapManager(iapManager: LxIAPManager, fetchProductsFailedForInvalidProductIdentifiers invalidProductIdentifiers: [String]) {
        //  fetched product info failed.
    }
    
    func iapManager(iapManager: LxIAPManager, didBeginTransaction transaction: SKPaymentTransaction) {
        //  a transaction did begin.
    }
    
    func iapManager(iapManager: LxIAPManager, purchaseSuccessForTransaction transaction: SKPaymentTransaction) {
        //  a transaction paid successful.
        //  next, verify it by apple server.
    }
    
    func iapManager(iapManager: LxIAPManager, purchaseFailedForTransaction transaction: SKPaymentTransaction?) {
        //  a transaction paid failed.
    }
    
    func iapManager(iapManager: LxIAPManager, hasBeenPurchasedForTransaction transaction: SKPaymentTransaction) {
        //  the product has purchased, recover it.
    }
	
### License
    LxIAPManager is available under the Apache License 2.0. See the LICENSE file for more info.