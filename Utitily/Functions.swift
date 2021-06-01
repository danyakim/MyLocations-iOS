//
//  Functions.swift
//  MyLocations
//
//  Created by Daniil Kim on 28.05.2021.
//

import Foundation

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

let coreDataSaveFailedNotification = Notification.Name(rawValue: "CoreDataSaveFailedNotification")

func afterDelay(_ seconds: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: ", error)
    NotificationCenter.default.post(name: coreDataSaveFailedNotification, object: nil)
}
