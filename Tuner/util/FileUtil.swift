//
//  FileUtil.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/13.
//

import Foundation

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}
