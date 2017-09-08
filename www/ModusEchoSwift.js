var exec = require('cordova/exec');

exports.saveText = function(name,value, success, error) {
    exec(success, error, "ModusEchoSwift", "saveText", [name,value]);
};

exports.addContact = function({id,relationship,name,phone,phoneType}, success, error) {
    exec(success, error, "ModusEchoSwift", "addContact", [relationship,name,phone,phoneType,id]);
};

exports.removeContact = function(id, success, error) {
    exec(success, error, "ModusEchoSwift", "removeContact", [id]);
};

exports.updateContact = function({id,relationship,name,phone,phoneType}, success, error) {
    exec(success, error, "ModusEchoSwift", "updateContact", [id, relationship,name,phone,phoneType]);
};

exports.clearAllContact = function(success, error) {
  exec(success, error, "ModusEchoSwift", "clearAllContact", []);
};
