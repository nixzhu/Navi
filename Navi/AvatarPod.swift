//
//  AvatarPod.swift
//  Navi
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

public class AvatarPod {

    private static let sharedInstance = AvatarPod()

    private let cache = NSCache()

    private lazy var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    public enum CacheType {
        case Memory
        case Disk
        case Cloud
    }

    public typealias Completion = (finished: Bool, image: UIImage, cacheType: CacheType) -> Void

    private struct Request {

        let avatar: Avatar
        let completion: Completion

        var URL: NSURL? {
            return avatar.URL
        }

        var key: String {
            return avatar.key
        }
    }

    private class RequestTank {

        let URL: NSURL
        var requests: [Request] = []

        init(URL: NSURL) {
            self.URL = URL
        }
    }

    private class RequestPool {

        private var requestTanks = [NSURL: RequestTank]()

        func addRequest(request: Request) {

            guard let URL = request.URL else {
                return
            }

            if let requestTank = requestTanks[URL] {
                requestTank.requests.append(request)

            } else {
                let requestTank = RequestTank(URL: URL)
                requestTanks[URL] = requestTank
                requestTank.requests.append(request)
            }
        }

        func requestsWithURL(URL: NSURL) -> [Request] {

            guard let requestTank = requestTanks[URL] else {
                return []
            }

            return requestTank.requests
        }

        func removeRequestsWithURL(URL: NSURL) {

            requestTanks.removeValueForKey(URL)
        }

        func removeAllRequests() {
            requestTanks.removeAll()
        }
    }

    private var requestPool = RequestPool()

    private let requestQueue = dispatch_queue_create("com.nixWork.Navi.requestQueue", DISPATCH_QUEUE_SERIAL)
    private let cacheQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)

    private func completeRequest(request: Request, withStyledImage styledImage: UIImage, cacheType: CacheType) {

        dispatch_async(dispatch_get_main_queue()) {
            request.completion(finished: true, image: styledImage, cacheType: cacheType)
        }

        cache.setObject(styledImage, forKey: request.key)
    }

    private func completeRequestsWithURL(URL: NSURL, image: UIImage, cacheType: CacheType) {

        dispatch_async(requestQueue) {

            let requests = self.requestPool.requestsWithURL(URL)

            dispatch_async(self.cacheQueue) {

                requests.forEach({ request in

                    // if can find styledImage in cache, no need to generate it again or save

                    if let styledImage = self.cache.objectForKey(request.key) as? UIImage {
                        self.completeRequest(request, withStyledImage: styledImage, cacheType: cacheType)

                    } else {
                        let styledImage = image.navi_avatarImageWithStyle(request.avatar.style)

                        self.completeRequest(request, withStyledImage: styledImage, cacheType: cacheType)

                        // save images to local

                        request.avatar.saveOriginalImage(image, styledImage: styledImage)
                    }
                })
            }

            self.requestPool.removeRequestsWithURL(URL)
        }
    }

    // MARK: - API

    public class func wakeAvatar(avatar: Avatar, completion: Completion) {

        guard let URL = avatar.URL else {
            completion(finished: false, image: avatar.placeholderImage ?? UIImage(), cacheType: .Memory)
            return
        }

        let request = Request(avatar: avatar, completion: completion)

        let key = request.key

        if let image = sharedInstance.cache.objectForKey(key) as? UIImage {
            completion(finished: true, image: image, cacheType: .Memory)

        } else {
            if let placeholderImage = avatar.placeholderImage {
                completion(finished: false, image: placeholderImage, cacheType: .Memory)
            }

            dispatch_async(sharedInstance.cacheQueue) {

                if let styledImage = avatar.localStyledImage {
                    sharedInstance.completeRequest(request, withStyledImage: styledImage, cacheType: .Disk)

                } else {
                    dispatch_async(sharedInstance.requestQueue) {

                        sharedInstance.requestPool.addRequest(request)

                        if sharedInstance.requestPool.requestsWithURL(URL).count > 1 {
                            // do nothing

                        } else {
                            dispatch_async(sharedInstance.cacheQueue) {

                                if let image = avatar.localOriginalImage {
                                    sharedInstance.completeRequestsWithURL(URL, image: image, cacheType: .Disk)

                                } else {
                                    let task = sharedInstance.session.dataTaskWithURL(URL) { data, response, error in

                                        guard error == nil, let data = data, image = UIImage(data: data) else {
                                            dispatch_async(sharedInstance.requestQueue) {
                                                sharedInstance.requestPool.removeRequestsWithURL(URL)
                                            }

                                            return
                                        }

                                        sharedInstance.completeRequestsWithURL(URL, image: image, cacheType: .Cloud)
                                    }
                                    
                                    task.resume()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public class func clear() {
        
        sharedInstance.requestPool.removeAllRequests()
        
        sharedInstance.cache.removeAllObjects()
    }
}

