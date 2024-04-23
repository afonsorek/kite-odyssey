//
//  PurchaseManager.swift
//  Pave
//
//  Created by Lucas Cavalherie on 28/11/23.
//

import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {

    private var productIds:[String] = []

    @Published private(set) var products: [Product] = []
    private var productsLoaded = false
    
    private var updates: Task<Void, Never>? = nil
    
    @Published private(set) var purchasedProductIDs = Set<String>()

    init() {
        for i in SkinsModel.shared.skins{
            productIds.append(i.adsID)
        }
        updates = observeTransactionUpdates()
    }

    deinit {
        updates?.cancel()
    }

    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            await transaction.finish()
            await self.updatePurchasedProducts()
        case .success(.unverified(_, _)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }

    func updatePurchasedProducts() async {
        print(self.purchasedProductIDs)
              
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }

            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
                
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
        
        print(self.purchasedProductIDs)
    }
}
