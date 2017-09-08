let GROUP_NAME:String = "group.tony.app-widget-e1"

@objc(ModusEchoSwift) class ModusEchoSwift : CDVPlugin {



    @objc(saveText:)
    func saveText(command: CDVInvokedUrlCommand) {
        var pluginResult:CDVPluginResult

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
            let phone = command.arguments[2] as? String, let phoneType = command.arguments[3] as? String, let id = command.arguments[4] as? String{
            var contacts = defaults?.object(forKey: EMERGENCY_CONTACT) as? [Any]
            if contacts == nil {
                contacts = []
            }
            contacts?.append([
                "id":id,
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
        if let id = command.arguments[0] as? String{
            let relationship = command.arguments[1] as? String
            let name = command.arguments[2] as? String
            let phone = command.arguments[3] as? String
            let phoneType = command.arguments[4] as? String
            var contacts = defaults?.object(forKey: EMERGENCY_CONTACT) as! [Any]


            for i in 0 ..< contacts.count{
                var contact = contacts[i] as! [String:String]
                if contact["id"] == id{
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


                    contacts[i] = contact
                    break
                }
            }




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
        if let id = command.arguments[0] as? String{
            var contacts = defaults?.object(forKey: EMERGENCY_CONTACT) as! [Any]

            for i in 0 ..< contacts.count{
                let contact = contacts[i] as! [String:String]
                if contact["id"] == id{
                    contacts.remove(at: i)
                    break
                }
            }


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

    @objc(clearAllContact:)
    func clearAllContact(command: CDVInvokedUrlCommand){
        let EMERGENCY_CONTACT = "Emergency Contact"
        var pluginResult:CDVPluginResult
        let defaults = UserDefaults(suiteName: GROUP_NAME)
        defaults?.removeObject(forKey: EMERGENCY_CONTACT)
        defaults?.synchronize()

        pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK)

        self.commandDelegate!.send(
            pluginResult,
            callbackId: command.callbackId
        )

    }




}
