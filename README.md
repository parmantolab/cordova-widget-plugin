# cordova-widget-plugin


## install 
```bash
cordova plugin add https://github.com/parmantolab/cordova-widget-plugin
```

## usage

* saveText(name:string,value:string,success:function,error:function): 
save value for a text field. The name can be the following:
    * ```Medical Condition```
    * ```Medical Notes```
    * ```Allergeies & Reactions```
    * ```Medications```
    * ```Blood Type```
    * ```Weight```
    * ```Height```
* addContact({id:string,relationship:string,name:string,phone:string,phoneType:string},success:function,error:function): add a new emergency contact
* removeContact(id:string,success:function,error:function): remove a emergency contact by index
* updateContact({index:string,relationship:string?,name:string?,phone:string?,phoneType:string?}, success:function, error:function): update an existing emergency contact information by its index. The field for emergency contact is optional, if you give it null, it won't be update.
* clearAllContact(success:function,error:function): clear all contacts information

