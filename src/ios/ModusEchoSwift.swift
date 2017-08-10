@objc(ModusEchoSwift) class ModusEchoSwift : CDVPlugin {



  @objc(save:)
  func save(command: CDVInvokedUrlCommand) {
    var pluginResult:CDVPluginResult
    let defaults = UserDefaults(suiteName: "group.tony.app-widget-e1")
    if let name = command.arguments[0] as? String, let relation = command.arguments[1] as? String, let phone = command.arguments[2] as? String {
      defaults?.set(name, forKey: "name")
      defaults?.set(relation, forKey: "relationship")
      defaults?.set(phone, forKey: "phone")
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
