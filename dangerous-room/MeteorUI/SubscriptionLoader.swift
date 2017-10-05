// Copyright (c) 2014-2015 Martijn Walraven
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Meteor

protocol SubscriptionLoaderDelegate: class {
    func subscriptionLoader(subscriptionLoader: SubscriptionLoader, subscription: METSubscription, didFailWithError error: NSError)
}

class SubscriptionLoader {
    weak var delegate: SubscriptionLoaderDelegate? = nil
    private var subscriptions: [METSubscription] = []
    
    deinit {
        removeAllSubscriptions()
    }
    
    func addSubscriptionWithName(name: String, parameters: AnyObject...) -> METSubscription {
        let subscription = Meteor.addSubscription(withName: name, parameters: parameters)
        subscription.whenDone { (error) -> Void in
            if let error = error {
                self.delegate?.subscriptionLoader(subscriptionLoader: self, subscription: subscription, didFailWithError: error as NSError)
            }
        }
        subscriptions.append(subscription)
        return subscription
    }
    
    func removeAllSubscriptions() {
        for subscription in subscriptions {
            Meteor.remove(subscription)
        }
    }
    
    var isReady: Bool {
        return all(source: subscriptions, predicate: {$0.isReady})
    }
    
    func whenReady(handler: @escaping () -> Void) {
        // Invoke completion handler synchronously if we're ready now
        let dwi = DispatchWorkItem {
            print("DR: DispatchWorkItem")
            handler()
            return
        }

        if isReady {
            dwi.perform()
            return
        }
        
        let dg = DispatchGroup.init()
        
        for subscription in subscriptions {
            dg.enter()
            subscription.whenDone { (error) -> Void in
                dg.leave()
            }
        }
        
        dg.notify(queue: DispatchQueue.main, work: dwi)
    }
}
