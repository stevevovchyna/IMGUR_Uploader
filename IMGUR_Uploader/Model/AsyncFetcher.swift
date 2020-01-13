//
//  AsyncFetcher.swift
//  IMGUR_Uploader
//
//  Created by Steve Vovchyna on 12.01.2020.
//  Copyright © 2020 Steve Vovchyna. All rights reserved.
//

import Foundation
import UIKit

class AsyncFetcher {

    private let serialAccessQueue = OperationQueue()
    private let fetchQueue = OperationQueue()
    private var completionHandlers = [String: [(DisplayData?) -> Void]]()
    private var cache = NSCache<NSString, DisplayData>()

    init() {
        serialAccessQueue.maxConcurrentOperationCount = 1
        cache.totalCostLimit = 1024 * 1024 * 300
        cache.countLimit = 10000
    }

    func fetchAsync(_ identifier: String, with size: CGSize, completion: ((DisplayData?) -> Void)? = nil) {
        serialAccessQueue.addOperation {
            if let completion = completion {
                let handlers = self.completionHandlers[identifier, default: []]
                self.completionHandlers[identifier] = handlers + [completion]
            }
            self.fetchData(for: identifier, with: size)
        }
    }

//     Returns the previously fetched data for a specified `ID`.
    func fetchedData(for identifier: String) -> DisplayData? {
        return cache.object(forKey: identifier as NSString)
    }


//     Cancels any enqueued asychronous fetches for a specified `ID`. Completion handlers are not called if a fetch is canceled.
    func cancelFetch(_ identifier: String) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }

            self.operation(for: identifier)?.cancel()
            self.completionHandlers[identifier] = nil
        }
    }

    // MARK: Convenience
    
//     Begins fetching data for the provided `identifier` invoking the associated completion handler when complete.
    private func fetchData(for identifier: String, with size: CGSize) {
        guard operation(for: identifier) == nil else { return }
        
        if let data = fetchedData(for: identifier) {
            invokeCompletionHandlers(for: identifier, with: data)
        } else {
            let operation = AsyncFetcherOperation(identifier: identifier, with: size)

            operation.completionBlock = { [weak operation] in
                guard let fetchedData = operation?.fetchedData else { return }
                self.cache.setObject(fetchedData, forKey: identifier as NSString)
                
                self.serialAccessQueue.addOperation {
                    self.invokeCompletionHandlers(for: identifier, with: fetchedData)
                }
            }
            fetchQueue.addOperation(operation)
        }
    }

//     Returns any enqueued `ObjectFetcherOperation` for a specified `ID`.
     private func operation(for identifier: String) -> AsyncFetcherOperation? {
        for case let fetchOperation as AsyncFetcherOperation in fetchQueue.operations
            where !fetchOperation.isCancelled && fetchOperation.identifier == identifier {
            return fetchOperation
        }
        return nil
    }

    private func invokeCompletionHandlers(for identifier: String, with fetchedData: DisplayData) {
        let completionHandlers = self.completionHandlers[identifier, default: []]
        self.completionHandlers[identifier] = nil

        for completionHandler in completionHandlers {
            completionHandler(fetchedData)
        }
    }
}
