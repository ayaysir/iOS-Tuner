//
//  CoreData.swift
//  Tuner
//
//  Created by yoonbumtae on 2021/08/12.
//

import Foundation
import UIKit
import CoreData

enum CDError: Error {
    case appDelegateNotExist
}

func saveCoreData(record: TunerRecord) throws {
    // App Delegate 호출
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { throw CDError.appDelegateNotExist  }
    
    // App Delegate 내부에 있는 viewContext 호출
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // managedContext 내부에 있는 entity 호출
    let entity = NSEntityDescription.entity(forEntityName: "Record", in: managedContext)!
    
    // entity 객체 생성
    let object = NSManagedObject(entity: entity, insertInto: managedContext)
    
    // 값 설정
    object.setValue(record.id, forKey: "id")
    object.setValue(record.date, forKey: "date")
    object.setValue(record.avgFreq, forKey: "avgFreq")
    object.setValue(record.stdFreq, forKey: "stdFreq")
    object.setValue(record.standardFreq, forKey: "standardFreq")
    object.setValue(record.centDist, forKey: "centDist")
    object.setValue(record.noteIndex, forKey: "noteIndex")
    object.setValue(record.octave, forKey: "octave")
    
    do {
        // managedContext 내부의 변경사항 저장
        try managedContext.save()
    } catch {
        // 에러 발생시
        throw error
    }
    
}

func readCoreData() throws -> [NSManagedObject]? {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    // Entity의 fetchRequest 생성
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Record")
    
    // 정렬 또는 조건 설정
    //    let sort = NSSortDescriptor(key: "createDate", ascending: false)
    //    fetchRequest.sortDescriptors = [sort]
    //    fetchRequest.predicate = NSPredicate(format: "isFinished = %@", NSNumber(value: isFinished))
    
    do {
        // fetchRequest를 통해 managedContext로부터 결과 배열을 가져오기
        let resultCDArray = try managedContext.fetch(fetchRequest)
        return resultCDArray
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
        throw error
    }
}
