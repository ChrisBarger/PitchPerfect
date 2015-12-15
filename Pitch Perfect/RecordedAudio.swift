//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Christopher Barger on 12/9/15.
//  Copyright © 2015 State Farm. All rights reserved.
//

import Foundation

class RecordedAudio {
    var filePathUrl: NSURL!
    var title: String!
    
    init(filePathUrl:NSURL, title:String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}