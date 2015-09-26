//
//  AvatarCache.swift
//  Navi
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

func ==(lhs: AvatarCache.Request, rhs: AvatarCache.Request) -> Bool {
    return lhs.hashValue == rhs.hashValue // TODO
}

public class AvatarCache {

    static let sharedInstance = AvatarCache()

    let cache = NSCache()

    public typealias Completion = UIImage -> Void

    struct Request: Hashable {

        let avatar: Avatar
        let completion: Completion

        var key: String {
            return avatar.URL.absoluteString
        }

        var hashValue: Int {
            return avatar.URL.hashValue // TODO
        }
    }

    struct RequestPool {

        private var requests: [Request]

        init() {

            self.requests = [Request]()
        }

        mutating func addRequest(request: Request) {

            requests.append(request)
            print("requestSet.count: \(requests.count)")
        }

        func requestsWithURL(URL: NSURL) -> [Request] {

            return requests.filter({ $0.avatar.URL == URL })
        }

        mutating func removeRequestsWithKey(key: String) {

            let requestsToRemove = requests.filter({ $0.key == key })
            print("remove requests.count: \(requests.count), key: \(key)")

            requestsToRemove.forEach({
                if let index = requests.indexOf($0) {
                    requests.removeAtIndex(index)
                }
            })
        }

        mutating func removeRequestsWithURL(URL: NSURL) {

            let requestsToRemove = requests.filter({ $0.avatar.URL == URL })
            print("remove requests.count: \(requests.count), URL: \(URL)")

            //requests.forEach({ requestSet.remove($0) })
            requestsToRemove.forEach({
                if let index = requests.indexOf($0) {
                    requests.removeAtIndex(index)
                }
            })
        }
    }

    var requestPool = RequestPool()

    private func completeRequestsWithURL(URL: NSURL, image: UIImage) {

        dispatch_async(dispatch_get_main_queue()) {

            let requests = self.requestPool.requestsWithURL(URL)

            requests.forEach({

                let avatarImage = image // TODO, style

                $0.completion(avatarImage)

                self.cache.setObject(avatarImage, forKey: $0.key)

                // save image to local

                $0.avatar.saveImage(image)
            })

            self.requestPool.removeRequestsWithURL(URL)
        }
    }

    public class func retrieveAvatar(avatar: Avatar, completion: Completion) {

        let request = Request(avatar: avatar, completion: completion)

        let key = request.key

        if let image = sharedInstance.cache.objectForKey(key) as? UIImage {
            completion(image)

        } else {
            dispatch_async(dispatch_get_main_queue()) {

                // 缓存失效，移除对应 key 的请求
                //sharedInstance.requestPool.removeRequestsWithKey(key)

                sharedInstance.requestPool.addRequest(request)

                let URL = avatar.URL

                if sharedInstance.requestPool.requestsWithURL(URL).count > 1 {
                    // Do nothing
                    print("do nothing")

                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {

                        if let image = avatar.localImage {
                            sharedInstance.completeRequestsWithURL(URL, image: image)

                        } else {
                            if let data = NSData(contentsOfURL: URL), image = UIImage(data: data) {
                                sharedInstance.completeRequestsWithURL(URL, image: image)
                                print("download")
                            }
                        }
                    }
                }
            }
        }
    }
}

