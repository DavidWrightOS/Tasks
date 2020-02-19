//
//  TaskRepresentation.swift
//  Tasks
//
//  Created by David Wright on 2/17/20.
//  Copyright © 2020 Steven Berard. All rights reserved.
//

import Foundation

struct TaskRepresentation: Codable {
    var name: String
    var notes: String?
    var priority: String
    var identifier: String?
}
