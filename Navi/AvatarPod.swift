//
//  AvatarPod.swift
//  Navi
//
//  Created by NIX on 15/9/26.
//  Copyright © 2015年 nixWork. All rights reserved.
//

import UIKit

open class AvatarPod {

    fileprivate static let sharedInstance = AvatarPod()

    fileprivate let cache = NSCache()

    fileprivate lazy var session = URLSession(configuration: URLSessionConfiguration.default)

    public enum CacheType {
        case memory
        case disk
        case cloud
    }

    public typealias Completion = (_ finished: Bool, _ image: UIImage, _ cacheType: CacheType) -> Void

    fileprivate struct Request {

        let avatar: Avatar
        let completion: Completion

        var URL: Foundation.URL? {
            return avatar.URL as URL?
        }

        var key: String {
            return avatar.key
        }
    }

    fileprivate class RequestTank {

        let URL: Foundation.URL
        var requests: [Request] = []

        init(URL: Foundation.URL) {
            self.URL = URL
        }
    }

    fileprivate class RequestPool {

        fileprivate var requestTanks = [URL: RequestTank]()

        func addRequest(_ request: Request) {

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

        func requestsWithURL(_ URL: Foundation.URL) -> [Request] {

            guard let requestTank = requestTanks[URL] else {
                return []
            }

            return requestTank.requests
        }

        func removeRequestsWithURL(_ URL: Foundation.URL) {

            requestTanks.removeValue(forKey: URL)
        }

        func removeAllRequests() {
            requestTanks.removeAll()
        }
    }

    fileprivate var requestPool = RequestPool()

    fileprivate let requestQueue = DispatchQueue(label: "com.nixWork.Navi.requestQueue", attributes: [])
    fileprivate let cacheQueue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background)

    fileprivate func completeRequest(_ request: Request, withStyledImage styledImage: UIImage, cacheType: CacheType) {

        DispatchQueue.main.async {
            request.completion(true, styledImage, cacheType)
        }

        cache.setObject(styledImage, forKey: request.key)
    }

    fileprivate func completeRequestsWithURL(_ URL: Foundation.URL, image: UIImage, cacheType: CacheType) {

        requestQueue.async {

            let requests = self.requestPool.requestsWithURL(URL)

            self.cacheQueue.async {

                requests.forEach({ request in

                    // if can find styledImage in cache, no need to generate it again or save

                    if let styledImage = self.cache.object(forKey: request.key) as? UIImage {
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

    open class func wakeAvatar(_ avatar: Avatar, completion: @escaping Completion) {

        guard let URL = avatar.URL else {
            completion(false, avatar.placeholderImage ?? UIImage(), .memory)
            return
        }

        let request = Request(avatar: avatar, completion: completion)

        let key = request.key

        if let image = sharedInstance.cache.object(forKey: key) as? UIImage {
            completion(finished: true, image: image, cacheType: .memory)

        } else {
            if let placeholderImage = avatar.placeholderImage {
                completion(false, placeholderImage, .memory)
            }

            sharedInstance.cacheQueue.async {

                if let styledImage = avatar.localStyledImage {
                    sharedInstance.completeRequest(request, withStyledImage: styledImage, cacheType: .disk)

                } else {
                    sharedInstance.requestQueue.async {

                        sharedInstance.requestPool.addRequest(request)

                        if sharedInstance.requestPool.requestsWithURL(URL as URL).count > 1 {
                            // do nothing

                        } else {
                            sharedInstance.cacheQueue.async {

                                if let image = avatar.localOriginalImage {
                                    sharedInstance.completeRequestsWithURL(URL as URL, image: image, cacheType: .disk)

                                } else {
                                    let task = sharedInstance.session.dataTask(with: URL, completionHandler: { data, response, error in

                                        guard error == nil, let data = data, let image = UIImage(data: data) else {
                                            sharedInstance.requestQueue.async {
                                                sharedInstance.requestPool.removeRequestsWithURL(URL)
                                            }

                                            return
                                        }

                                        sharedInstance.completeRequestsWithURL(URL, image: image, cacheType: .cloud)
                                    }) 
                                    
                                    task.resume()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    open class func clear() {
        
        sharedInstance.requestPool.removeAllRequests()
        
        sharedInstance.cache.removeAllObjects()
    }
}

