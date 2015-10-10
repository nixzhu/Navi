//
//  AvatarPod.swift
//  Navi
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

func ==(lhs: AvatarPod.Request, rhs: AvatarPod.Request) -> Bool {
    return lhs.key == rhs.key
}

public class AvatarPod {

    static let sharedInstance = AvatarPod()

    let cache = NSCache()

    public typealias Completion = UIImage -> Void

    struct Request: Equatable {

        let avatar: Avatar
        let completion: Completion

        var key: String {
            return avatar.key
        }
    }

    private struct RequestPool {

        private var requests: [Request]

        init() {

            self.requests = [Request]()
        }

        mutating func addRequest(request: Request) {

            requests.append(request)
        }

        func requestsWithURL(URL: NSURL) -> [Request] {

            return requests.filter({ $0.avatar.URL == URL })
        }

        mutating func removeRequestsWithURL(URL: NSURL) {

            let requestsToRemove = requests.filter({ $0.avatar.URL == URL })

            requestsToRemove.forEach({
                if let index = requests.indexOf($0) {
                    requests.removeAtIndex(index)
                }
            })
        }
    }

    private var requestPool = RequestPool()

    private func completeRequestsWithURL(URL: NSURL, image: UIImage) {

        dispatch_async(dispatch_get_main_queue()) {

            let requests = self.requestPool.requestsWithURL(URL)

            requests.forEach({ request in

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {

                    let avatarImage = image.avatarImageWithStyle(request.avatar.style)

                    dispatch_async(dispatch_get_main_queue()) {

                        request.completion(avatarImage)
                    }

                    self.cache.setObject(avatarImage, forKey: request.key)

                    // save images to local

                    request.avatar.saveOriginalImage(image, styledImage: avatarImage)
                }
            })

            self.requestPool.removeRequestsWithURL(URL)
        }
    }

    // MARK: - API

    public class func wakeAvatar(avatar: Avatar, completion: Completion) {

        guard let URL = avatar.URL else {

            if let placeholderImage = avatar.placeholderImage {
                completion(placeholderImage)
            } else {
                completion(UIImage())
            }

            return
        }

        let request = Request(avatar: avatar, completion: completion)

        let key = request.key

        if let image = sharedInstance.cache.objectForKey(key) as? UIImage {
            completion(image)

        } else {
            if let placeholderImage = avatar.placeholderImage {
                completion(placeholderImage)
            }

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {

                if let image = avatar.localStyledImage {

                    dispatch_async(dispatch_get_main_queue()) {
                        completion(image)
                    }

                } else {
                    dispatch_async(dispatch_get_main_queue()) {

                        sharedInstance.requestPool.addRequest(request)

                        if sharedInstance.requestPool.requestsWithURL(URL).count > 1 {
                            // do nothing

                        } else {
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {

                                if let image = avatar.localOriginalImage {
                                    sharedInstance.completeRequestsWithURL(URL, image: image)

                                } else {
                                    if let data = NSData(contentsOfURL: URL), image = UIImage(data: data) {
                                        sharedInstance.completeRequestsWithURL(URL, image: image)

                                    } else {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            sharedInstance.requestPool.removeRequestsWithURL(URL)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

