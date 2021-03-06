//
//  ASProtocol+Query.swift
//  ActiveSQLite
//
//  Created by kai zhou on 2018/5/29.
//  Copyright © 2018 wumingapie@gmail.com. All rights reserved.
//

import Foundation
import SQLite

public extension ASProtocol where Self:ASModel{
    //    public static var dbName:String?{
    //        return nil
    //    }
    //
    //    static var db:Connection{
    //        get{
    //            if let name = dbName {
    //                return ASConfigration.getDB(name: name)
    //            }else{
    //                return ASConfigration.getDefaultDB()
    //            }
    //
    //        }
    //    }
    //
    //    public static var CREATE_AT_KEY:String{
    //        return  "created_at"
    //    }
    //    public static var created_at:Expression<NSNumber>{
    //        return Expression<Int64>(CREATE_AT_KEY)
    //    }
    //
    //    public static var isSaveDefaulttimestamp:Bool {
    //        return false
    //    }
    //
    //    public static var nameOfTable: String{
    //        return NSStringFromClass(self).components(separatedBy: ".").last!
    //    }
    //
    //    public static func getTable() -> Table{
    //        return Table(nameOfTable)
    //    }
    
    //MARK: - Find
    //MARK: - FindFirst
    static func findFirst(_ attribute: String, value:Any?)->Self?{
        return findAll(attribute, value: value).first
    }
    
    static func findFirst(_ attributeAndValueDic:Dictionary<String,Any?>)->Self?{
        return findAll(attributeAndValueDic).first
    }
    
    static func findFirst(orderColumn:String,ascending:Bool = true)->Self?{
        return findAll(orderColumn:orderColumn, ascending: ascending).first
    }
    
    static func findFirst(orders:[String:Bool]? = nil)->Self?{
        return findAll(orders:orders).first
    }
    
    static func findFirst(_ attribute: String, value:Any?,_ orderBy:String,ascending:Bool = true)->Self?{
        return findAll([attribute:value], [orderBy:ascending]).first
    }
    
    static func findFirst(_ attributeAndValueDic:Dictionary<String,Any?>?,_ orders:[String:Bool]? = nil)->Self?{
        return findAll(attributeAndValueDic, orders).first
    }
    
    static func findFirst(_ predicate: SQLite.Expression<Bool>,orders:[String:Bool])->Self?
    {
        return findAll(predicate,orders:orders).first
    }
    
    static func findFirst(_ predicate: SQLite.Expression<Bool?>,orders:[String:Bool])->Self?{
        return findAll(predicate,orders:orders).first
    }
    
    static func findFirst(_ predicate: SQLite.Expression<Bool>,orders: [Expressible]? = nil)->Self?
    {
        return findAll(predicate,orders:orders).first
    }
    
    static func findFirst(_ predicate: SQLite.Expression<Bool?>,orders: [Expressible]? = nil)->Self?{
        return findAll(predicate,orders:orders).first
    }
    
    
    //MARK: FindAll
    static func findAll(_ attribute: String, value:Any?)->Array<Self>{
        return findAll([attribute:value])
    }
    
    static func findAll(_ attributeAndValueDic:Dictionary<String,Any?>)->Array<Self>{
        return findAll(attributeAndValueDic, nil)
    }
    
    
    static func findAll(orderColumn:String,ascending:Bool = true)->Array<Self>{
        return findAll(nil, [orderColumn:ascending])
    }
    
    static func findAll(orders:[String:Bool]? = nil)->Array<Self>{
        return findAll(nil, orders)
        
    }
    
    static func findAll(_ attributeAndValueDic:Dictionary<String,Any?>,orders:[String:Bool])->Array<Self>{
        return findAll(attributeAndValueDic, orders: orders)
    }
    
    static func findAll(_ attributeAndValueDic:Dictionary<String,Any?>?,_ orders:[String:Bool]? = nil)->Array<Self>{
        
        
        var results:Array<Self> = Array<Self>()
        var query = getTable()
        
        if attributeAndValueDic != nil {
            if let expression = self.init().buildExpression(attributeAndValueDic!) {
                query = query.where(expression)
            }
        }
        
        if orders != nil {
            query = query.order(self.init().buildExpressiblesForOrder(orders!))
        }
        
        do{
            for row in try db.prepare(query) {
                let model = self.init()
                model.buildFromRow(row: row) //TODO:codable
                results.append(model)
            }
        }catch{
            LogError(error)
        }
        
        
        return results
    }
    
    static func findAll(_ predicate: SQLite.Expression<Bool>,orders:[String:Bool])->Array<Self>{
        
        return findAll(Expression<Bool?>(predicate),orders:self.init().buildExpressiblesForOrder(orders))
        
    }
    
    static func findAll(_ predicate: SQLite.Expression<Bool?>,orders:[String:Bool])->Array<Self>{
        
        return findAll(predicate,orders:self.init().buildExpressiblesForOrder(orders))
        
    }
    
    static func findAll(_ predicate: SQLite.Expression<Bool>,order: Expressible)->Array<Self>{
        
        return findAll(Expression<Bool?>(predicate),orders:[order])
    }
    
    static func findAll(_ predicate: SQLite.Expression<Bool>,orders: [Expressible])->Array<Self>{
        
        return findAll(Expression<Bool?>(predicate),orders:orders)
    }
    
    
    static func findAll(_ predicate: SQLite.Expression<Bool>,orders: [Expressible]? = nil)->Array<Self>{
        
        return findAll(Expression<Bool?>(predicate),orders:orders)
    }
    
    
    static func findAll(order: Expressible)->Array<Self>{
        
        return findAll(orders:[order])
    }
    
    public static func findAll(_ predicate: SQLite.Expression<Bool?>? = nil,orders: [Expressible]? = nil)->Array<Self>{
        
        var results:Array<Self> = Array<Self>()
        var query = getTable()
        if predicate != nil {
            query = query.where(predicate!)
        }
        
        if orders != nil && orders!.count > 0 {
            query = query.order(orders!)
        }else{
            if isSaveDefaulttimestamp {
                query = query.order(created_at.desc)
            }
        }
        
        
        do{
            for row in try db.prepare(query) {
                
                let model = self.init()
                model.buildFromRow(row: row) //TODO:Codable
                
                results.append(model)
            }
        }catch{
            LogError("Find all for \(nameOfTable) failure: \(error)")
        }
        
        
        return results
    }
    
    func run()->Array<Self>{
        
        var results:Array<Self> = Array<Self>()
        do{
            for row in try type(of: self).db.prepare(query!) {
                
                let model = type(of: self).init()
                model.buildFromRow(row: row) //TODO:Codable
                
                results.append(model)
            }
        }catch{
            LogError("Execute run() from \(nameOfTable) failure。\(error)")
        }
        
        
        query = nil
        
        LogInfo("Execute Query run() function from \(nameOfTable)  success")
        
        return results
        
    }
    
    
    //MARK: - Query
    var query:QueryType?{ //TODO:Codable
        set{
            _query = newValue
        }
        get{
            if _query == nil {
                _query =  getTable()
            }
            return _query
//            return nil
        }
    }
    
    
    public func join(_ table: QueryType, on condition: Expression<Bool>) -> Self {
        query = query?.join(table, on: condition)
        return self
    }
    
    public func join(_ table: QueryType, on condition: Expression<Bool?>) -> Self {
        query = query?.join(table, on: condition)
        return self
    }
    
    public func join(_ type: JoinType, _ table: QueryType, on condition: Expression<Bool>) -> Self {
        query = query?.join(type, table, on: condition)
        return self
    }
    
    
    public func join(_ type: JoinType, _ table: QueryType, on condition: Expression<Bool?>) -> Self {
        query = query?.join(type, table, on: condition)
        return self
    }
    
    
    public func `where`(_ attribute: String, value:Any?)->Self{
        
        if let expression = buildExpression(attribute, value: value) {
            return self.where(expression)
        }
        return self
    }
    
    public func `where`(_ attributeAndValueDic:Dictionary<String,Any?>)->Self{
        
        if let expression = buildExpression(attributeAndValueDic) {
            return self.where(expression)
        }
        return self
    }
    
    public func `where`(_ predicate: SQLite.Expression<Bool>)->Self{
        query = query?.where(predicate)
        return self
    }
    
    public func `where`(_ predicate: SQLite.Expression<Bool?>)->Self{
        query = query?.where(predicate)
        return self
    }
    
    public func group(_ by: Expressible...) -> Self {
        query = query?.group(by)
        return self
    }
    
    public func group(_ by: [Expressible]) -> Self {
        query = query?.group(by)
        return self
    }
    
    public func group(_ by: Expressible, having: Expression<Bool>) -> Self {
        query = query?.group(by, having: having)
        return self
    }
    public func group(_ by: Expressible, having: Expression<Bool?>) -> Self {
        query = query?.group(by, having: having)
        return self
    }
    
    public func group(_ by: [Expressible], having: Expression<Bool>) -> Self {
        query = query?.group(by, having: having)
        return self
    }
    
    public func group(_ by: [Expressible], having: Expression<Bool?>) -> Self {
        query = query?.group(by, having: having)
        return self
    }
    
    public func orderBy(_ sorted:String, asc:Bool = true)->Self{
        query = query?.order(buildExpressiblesForOrder([sorted:asc]))
        return self
    }
    
    public func orderBy(_ sorted:[String:Bool])->Self{
        query = query?.order(buildExpressiblesForOrder(sorted))
        return self
    }
    
    public func order(_ by: Expressible...) -> Self {
        query = query?.order(by)
        return self
    }
    
    public func order(_ by: [Expressible]) -> Self {
        query = query?.order(by)
        return self
    }
    
    public func limit(_ length: Int?) -> Self {
        query = query?.limit(length)
        return self
    }
    
    public func limit(_ length: Int, offset: Int) -> Self {
        query = query?.limit(length, offset: offset)
        return self
    }
    
    
    //MARK: delete
    //MARK: - Delete
    func runDelete()throws{
        
        do {
            if try type(of: self).db.run(query!.delete()) > 0 {
                LogInfo("Delete rows of \(nameOfTable) success")
                
            } else {
                LogWarn("Delete rows of \(nameOfTable) failure。")
                
            }
        } catch {
            LogError("Delete rows of \(nameOfTable) failure。")
            throw error
        }
    }
    
    func delete() throws{
        guard let id = id else {
            return
        }
        
        let query = getTable().where(type(of: self).id == id)
        do {
            if try db.run(query.delete()) > 0 {
                LogInfo("Delete  \(nameOfTable)，id:\(id)  success")
                
            } else {
                LogWarn("Delete \(nameOfTable) failure，haven't found id:\(id) 。")
                
            }
        } catch {
            LogError("Delete failure: \(error)")
            throw error
        }
    }
    
    static func deleteBatch(_ models:[Self]) throws{
        
        do{
            
            try db!.savepoint("savepointname_\(nameOfTable)_deleteBatch\(NSDate().timeIntervalSince1970 * 1000)", block: {
                
                var ids = Array<NSNumber>()
                for model in models{
                    if model.id == nil {
                        continue
                    }
                    ids.append(model.id!)
                }
                
                let query = getTable().where(ids.contains(id))
                
                try db!.run(query.delete())
                
                LogInfo("Delete batch rows of \(nameOfTable) success")
            })
        }catch{
            LogError("Delete batch rows of \(nameOfTable) failure: \(error)")
            throw error
        }
    }
    
    static func deleteAll() throws{
        do{
            try db.run(getTable().delete())
            LogInfo("Delete all rows of \(nameOfTable) success")
            
        }catch{
            LogError("Delete all rows of \(nameOfTable) failure: \(error)")
            throw error
        }
    }
}
