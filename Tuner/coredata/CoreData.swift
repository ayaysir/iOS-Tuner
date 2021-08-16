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
//    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { throw CDError.appDelegateNotExist  }
    
    // App Delegate 내부에 있는 viewContext 호출
    let managedContext = AppDelegate.viewContext
    
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

func readCoreData() throws -> [TunerRecord] {
    let managedContext = AppDelegate.viewContext
    
    // Entity의 fetchRequest 생성
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Record")
    
    // 정렬 또는 조건 설정
    let sort = NSSortDescriptor(key: "date", ascending: false)
    fetchRequest.sortDescriptors = [sort]
//    fetchRequest.predicate = NSPredicate(format: "isFinished = %@", NSNumber(value: isFinished))
    
    do {
        // fetchRequest를 통해 managedContext로부터 결과 배열을 가져오기
        let resultCDArray = try managedContext.fetch(fetchRequest)
        return resultCDArray.map { obj in
            let id: UUID = obj.value(forKey: "id") as! UUID
            let date: Date = obj.value(forKey: "date") as! Date
            let avgFreq: Float = obj.value(forKey: "avgFreq") as! Float
            let stdFreq: Float = obj.value(forKey: "stdFreq") as! Float
            let standardFreq: Float = obj.value(forKey: "standardFreq") as! Float
            let centDist: Float = obj.value(forKey: "centDist") as! Float
            let noteIndex: Int = obj.value(forKey: "noteIndex") as! Int
            let octave: Int = obj.value(forKey: "octave") as! Int
            return TunerRecord(id: id, date: date, avgFreq: avgFreq, stdFreq: stdFreq, standardFreq: standardFreq, centDist: centDist, noteIndex: noteIndex, octave: octave)
        }
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
        throw error
    }
}

func deleteCoreData(id: UUID) throws {
    let managedContext = AppDelegate.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Record")
    
    // 아이디를 삭제 기준으로 설정
    fetchRequest.predicate = NSPredicate(format: "id = %@", id.uuidString)
    
    do {
        let result = try managedContext.fetch(fetchRequest)
        let objectToDelete = result[0] as! NSManagedObject
        managedContext.delete(objectToDelete)
        try managedContext.save()
    } catch let error as NSError {
        print("Could not update. \(error), \(error.userInfo)")
    }
}
