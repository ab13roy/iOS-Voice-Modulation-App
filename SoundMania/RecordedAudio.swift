//
//  RecordedAudio.swift
//  SoundMania
//

import Foundation

/**
 class that provides an object for the recorded Audio
 */

class RecordedAudio: NSObject {
    fileprivate let filePathUrl: URL!
    fileprivate let title: String?
    
    //initializer to set the filepath and name
    init(filePathUrl: URL, title: String?)
    {
        self.filePathUrl = filePathUrl
        self.title = title
    }
    
    //func to return the filepath
    func getFilePathUrl() -> URL
    {
        return filePathUrl
    }
    
    //func to return the file name
    func getTitle() -> String
    {
        if title != nil
        {
            return title!
        }
        else
        {
            return "none"
        }
    }
}
