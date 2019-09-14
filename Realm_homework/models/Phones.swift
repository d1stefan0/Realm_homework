import Foundation
import RealmSwift

class Phones: Object {
    @objc dynamic var model: String?
    @objc dynamic var price: String?
//    let price: RealmOptional<Int> = RealmOptional()
//
    
//    override static func primaryKey() -> String? {
//        return "model"
//    }
}
