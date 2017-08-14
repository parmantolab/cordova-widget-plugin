let GROUP_NAME:String = "group.tony.app-widget-e1"

@objc(ModusEchoSwift) class ModusEchoSwift : CDVPlugin {

    
//  @objc(save:)
//  func save(command: CDVInvokedUrlCommand) {
//    var pluginResult:CDVPluginResult
//    let defaults = UserDefaults(suiteName: GROUP_NAME)
//    if let name = command.arguments[0] as? String, let relation = command.arguments[1] as? String, let phone = command.arguments[2] as? String {
//      defaults?.set(name, forKey: "name")
//      defaults?.set(relation, forKey: "relationship")
//      defaults?.set(phone, forKey: "phone")
//      defaults?.synchronize()
//      pluginResult = CDVPluginResult(
//        status: CDVCommandStatus_OK)
//    }
//    else{
//        pluginResult = CDVPluginResult(
//            status: CDVCommandStatus_ERROR
//        )
//    }
//
//    self.commandDelegate!.send(
//      pluginResult,
//      callbackId: command.callbackId
//    )
//  }
//    
    
    @objc(saveText:)
    func saveText(command: CDVInvokedUrlCommand) {
        var pluginResult:CDVPluginResult
        let t = GROUP_NAME
        let defaults = UserDefaults(suiteName: GROUP_NAME)
        if let name = command.arguments[0] as? String, let value = command.arguments[1] as? String{
            defaults?.set(value, forKey: name)
            
            defaults?.synchronize()
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK)
        }
        else{
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR
            )
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    
    @objc(addContact:)
    func addContact(command: CDVInvokedUrlCommand) {
        let EMERGENCY_CONTACT = "Emergency Contact"
        var pluginResult:CDVPluginResult
        let defaults = UserDefaults(suiteName: GROUP_NAME)
        if let relationship = command.arguments[0] as? String, let name = command.arguments[1] as? String,
            let phone = command.arguments[2] as? String, let phoneType = command.arguments[3] as? String{
            var contacts = defaults?.object(forKey: EMERGENCY_CONTACT) as? [Any]
            if contacts == nil {
                contacts = []
            }
            contacts?.append([
                "relationship":relationship,
                "name":name,
                "phone":phone,
                "phone_type":phoneType
            ])
            
            defaults?.set(contacts, forKey: EMERGENCY_CONTACT)
            
            defaults?.synchronize()
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK)
        }
        else{
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR
            )
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    
    
    @objc(updateContact:)
    func updateContact(command: CDVInvokedUrlCommand) {
        let EMERGENCY_CONTACT = "Emergency Contact"
        var pluginResult:CDVPluginResult
        let defaults = UserDefaults(suiteName: GROUP_NAME)
        if let index = command.arguments[0] as? Int{
            let relationship = command.arguments[1] as? String
            let name = command.arguments[2] as? String
            let phone = command.arguments[3] as? String
            let phoneType = command.arguments[4] as? String
            var contacts = defaults?.object(forKey: EMERGENCY_CONTACT) as! [Any]
            var contact = contacts[index] as! [String:String]
            if let relationship = relationship {
                contact.updateValue(relationship, forKey: "relationship")
            }
            
            if let name = name {
                contact.updateValue(name, forKey: "name")
            }
            
            if let phone = phone {
                contact.updateValue(phone, forKey: "phone")
            }
            
            if let phoneType = phoneType {
                contact.updateValue(phoneType, forKey: "phone_type")
            }
            
            contacts[index] = contact
            defaults?.set(contacts, forKey: EMERGENCY_CONTACT)
            
            defaults?.synchronize()
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK)
        }
        else{
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR
            )
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }
    

    
    
    @objc(removeContact:)
    func removeContact(command: CDVInvokedUrlCommand) {
        let EMERGENCY_CONTACT = "Emergency Contact"
        var pluginResult:CDVPluginResult
        let defaults = UserDefaults(suiteName: GROUP_NAME)
        if let index = command.arguments[0] as? Int{
            var contacts = defaults?.object(forKey: EMERGENCY_CONTACT) as! [Any]
            contacts.remove(at: index)
            defaults?.set(contacts, forKey: EMERGENCY_CONTACT)
            
            defaults?.synchronize()
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_OK)
        }
        else{
            pluginResult = CDVPluginResult(
                status: CDVCommandStatus_ERROR
            )
        }
        
        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )
    }




}
