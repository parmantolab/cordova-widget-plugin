# cordova-widget-plugin


## install 
```bash
cordova plugin add https://github.com/parmantolab/cordova-widget-plugin
```

## usage

* medicalWidget.saveText(name:string,value:string,success:function,error:function): 
save value for a text field. The name can be the following:
    * ```Medical Condition```
    * ```Medical Notes```
    * ```Allergeies & Reactions```
    * ```Medications```
    * ```Blood Type```
    * ```Weight```
    * ```Height```
* medicalWidget.addContact({id:string,relationship:string,name:string,phone:string,phoneType:string},success:function,error:function): add a new emergency contact
* medicalWidget.removeContact(id:string,success:function,error:function): remove a emergency contact by index
* medicalWidget.updateContact({index:string,relationship:string?,name:string?,phone:string?,phoneType:string?}, success:function, error:function): update an existing emergency contact information by its index. The field for emergency contact is optional, if you give it null, it won't be update.
* medicalWidget.clearAllContact(success:function,error:function): clear all contacts information

