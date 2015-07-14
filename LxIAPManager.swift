//
//  LxIAPManager.swift
//  LxIAPManagerDemo
//

import StoreKit

@objc

protocol LxIAPManagerDelegate: NSObjectProtocol {

    optional func iapManager(iapManager: LxIAPManager, didFetchedProductArray productArray: [SKProduct])
    optional func iapManager(iapManager: LxIAPManager, fetchProductsFailedForInvalidProductIdentifiers invalidProductIdentifiers: [String])
    optional func iapManager(iapManager: LxIAPManager, didBeginTransaction transaction: SKPaymentTransaction)
    optional func iapManager(iapManager: LxIAPManager, purchaseSuccessForTransaction transaction: SKPaymentTransaction)
    optional func iapManager(iapManager: LxIAPManager, purchaseFailedForTransaction transaction: SKPaymentTransaction?)
    optional func iapManager(iapManager: LxIAPManager, hasBeenPurchasedForTransaction transaction: SKPaymentTransaction)
}

class LxIAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
   
    var delegate: LxIAPManagerDelegate?
    
    static private let _defaultManager = LxIAPManager()
    
    class func defaultManager() -> LxIAPManager {
    
        return _defaultManager
    }
    
    override init() {
        super.init()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    class func iapEnable() -> Bool {
    
        return SKPaymentQueue.canMakePayments()
    }
    
    class func transactionReceipt() -> NSData? {
        
        if let appStoreReceiptURL = NSBundle.mainBundle().appStoreReceiptURL {
            return NSData(contentsOfURL: appStoreReceiptURL)
        }
        else {
            return nil
        }
    }

//  MARK: - fetch products
    func fetchProductsByIdentifiers(productIdentifiers: [String]) {
    
        if productIdentifiers.count == 0 {
        
            delegate?.iapManager?(self, fetchProductsFailedForInvalidProductIdentifiers: [String]())
        }
        
        let productsRequest = SKProductsRequest(productIdentifiers: NSSet(array: productIdentifiers) as! Set)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        if response.products.count == 0 {
        
            delegate?.iapManager?(self, fetchProductsFailedForInvalidProductIdentifiers: [String]())
        }
        else {
            delegate?.iapManager?(self, didFetchedProductArray: response.products as! [SKProduct])
        }
    }
    
//  MARK: - purchase product
    
    func purchaseProductWithIdentifier(productIdentifier: String) {
    
        var hasUnfinishedTransactions = false
        
        for paymentTransaction in SKPaymentQueue.defaultQueue().transactions {
        
            switch paymentTransaction.transactionState! {
            
            case .Purchasing:
                break
            case .Purchased:
                hasUnfinishedTransactions = true
                SKPaymentQueue.defaultQueue().finishTransaction(paymentTransaction as! SKPaymentTransaction)
            case .Failed:
                hasUnfinishedTransactions = true
                SKPaymentQueue.defaultQueue().finishTransaction(paymentTransaction as! SKPaymentTransaction)
            case .Restored:
                hasUnfinishedTransactions = true
                SKPaymentQueue.defaultQueue().finishTransaction(paymentTransaction as! SKPaymentTransaction)
            case .Deferred:
                break
            }
        }
        
        if hasUnfinishedTransactions == true {
        
            delegate?.iapManager?(self, purchaseFailedForTransaction: nil)
        }
        
        let payment = SKMutablePayment()
        payment.productIdentifier = productIdentifier
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        for paymentTransaction in transactions {
         
            switch paymentTransaction.transactionState! {
                
            case .Purchasing:
                println("LxIAPManager: Transaction is being added to the server queue.")
                delegate?.iapManager?(self, didBeginTransaction: paymentTransaction as! SKPaymentTransaction)
            case .Purchased:
                println("LxIAPManager: Transaction is in queue, user has been charged.  Client should complete the transaction.")
                delegate?.iapManager?(self, purchaseSuccessForTransaction: paymentTransaction as! SKPaymentTransaction)
                SKPaymentQueue.defaultQueue().finishTransaction(paymentTransaction as! SKPaymentTransaction)
            case .Failed:
                println("LxIAPManager: Transaction was cancelled or failed before being added to the server queue.")
                delegate?.iapManager?(self, purchaseFailedForTransaction: paymentTransaction as? SKPaymentTransaction)
                SKPaymentQueue.defaultQueue().finishTransaction(paymentTransaction as! SKPaymentTransaction)
            case .Restored:
                println("LxIAPManager: Transaction was restored from user's purchase history.  Client should complete the transaction.")
                delegate?.iapManager?(self, hasBeenPurchasedForTransaction: paymentTransaction as! SKPaymentTransaction)
                SKPaymentQueue.defaultQueue().finishTransaction(paymentTransaction as! SKPaymentTransaction)
            case .Deferred:
                println("LxIAPManager: The transaction is in the queue, but its final status is pending external action.")
            }
        }
    }
}
